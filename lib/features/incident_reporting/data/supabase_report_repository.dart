import 'dart:io';
import 'dart:typed_data';

import 'package:fixmytown_citizen/features/incident_reporting/domain/report.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_reaction.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backed by the schema in .test_folder/supabase-setup-guide.md. A few
/// deliberate simplifications, matching the same "stand-in until it's worth
/// building for real" spirit as InMemoryReportRepository:
/// - `current_state_code` is written/read directly rather than going through
///   the generic workflow_instance/workflow_event machinery the DB guide
///   also models — wiring that up is its own pass.
/// - Guest submission isn't wired up: RLS's organization_id trigger only
///   fills in a value for a signed-in user (see the setup guide's insert
///   trigger note) — FR-1.1 needs its own follow-up here.
///
/// watchNearby/watchMine are one-shot fetches wrapped in a Stream, not a
/// realtime subscription — Supabase's realtime `.stream()` can't embed the
/// report_attachment join or aggregate reaction counts a social-feed card
/// actually needs to render (photo/video, support/dispute counts), and a
/// feed showing neither isn't the point of this screen anymore (FR-20.1).
/// Traded deliberately: pull-to-refresh (`ref.invalidate` on the provider,
/// re-running this) replaces instant live updates. Most real feeds work
/// this way anyway — polling/realtime for a feed's *own* new posts is a
/// nice-to-have, not the baseline.
class SupabaseReportRepository implements ReportRepository {
  SupabaseReportRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'report';
  static const _bucket = 'report-photos';
  static const _attachmentSelect =
      '*, report_attachment(kind, blob_url, media_type, duration_seconds, sequence)';

  @override
  Stream<List<Report>> watchNearby() => Stream.fromFuture(_fetchReports());

  @override
  Stream<List<Report>> watchMine() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value(const []);
    return Stream.fromFuture(_fetchReports(submittedByUserId: userId));
  }

  Future<List<Report>> _fetchReports({String? submittedByUserId}) async {
    var query = _client.from(_table).select(_attachmentSelect);
    if (submittedByUserId != null) {
      query = query.eq('submitted_by_user_id', submittedByUserId);
    }
    final rows = await query.order('created_at', ascending: false);
    final reports = [
      for (final row in rows) _toReport(row, withAttachments: true),
    ];
    return _withBatchedReactionCounts(reports);
  }

  /// One query for every report's reaction counts, not one query per report
  /// — the latter is what findById/_withReactionCounts does, fine for a
  /// single detail view, wasteful across a whole feed page.
  Future<List<Report>> _withBatchedReactionCounts(List<Report> reports) async {
    if (reports.isEmpty) return reports;
    final rows = await _client
        .from('report_reaction')
        .select('report_id, reaction_kind')
        .inFilter('report_id', reports.map((r) => r.id).toList());

    final support = <String, int>{};
    final dispute = <String, int>{};
    for (final row in rows) {
      final id = row['report_id'] as String;
      final counts = row['reaction_kind'] == 'support' ? support : dispute;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return [
      for (final report in reports)
        report.copyWith(
          supportCount: support[report.id] ?? 0,
          disputeCount: dispute[report.id] ?? 0,
        ),
    ];
  }

  @override
  Future<Report?> findById(String id) async {
    Map<String, dynamic>? row;
    try {
      row = await _client
          .from(_table)
          .select(_attachmentSelect)
          .eq('id', id)
          .maybeSingle();
    } on PostgrestException catch (error) {
      // 22P02 = invalid_text_representation — `id` is a `uuid` column, and
      // reportByAnyIdProvider always tries findById first regardless of
      // whether it was actually given a tracking ID (e.g. "FMT-3786ED")
      // rather than a real id. Postgres rejects that at the SQL level
      // instead of just finding no match, so this has to be treated the
      // same as "not found by id" — the ?? findByTrackingId(...) fallback
      // depends on that, not on this ever throwing.
      if (error.code == '22P02') return null;
      rethrow;
    }
    if (row == null) return null;
    return _withReactionCounts(_toReport(row, withAttachments: true));
  }

  @override
  Future<Report?> findByTrackingId(String trackingId) async {
    final row = await _client
        .from(_table)
        .select(_attachmentSelect)
        .eq('tracking_id', trackingId.trim().toUpperCase())
        .maybeSingle();
    if (row == null) return null;
    return _withReactionCounts(_toReport(row, withAttachments: true));
  }

  @override
  Future<Report> submit(NewReportDraft draft) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      // See the class doc — guest submission against this schema needs its
      // own pass (RLS's organization_id trigger has nothing to resolve a
      // guest against yet). Failing loudly here beats a confusing RLS
      // rejection with no context.
      throw StateError(
        'Guest report submission against Supabase is not wired up yet — '
        'sign in before submitting, or see the RLS notes in '
        '.test_folder/supabase-setup-guide.md before changing that.',
      );
    }

    final inserted = await _client
        .from(_table)
        .insert({
          'category_id': draft.categoryId,
          'description': draft.description,
          'address': draft.address,
          // Sent as EWKT text — Postgres/PostGIS parses this through
          // geography's own input function on insert. organization_id is
          // deliberately omitted: the report_before_insert trigger fills it
          // in server-side (see setup guide §6). barangay_id is the citizen's
          // self-selected home barangay (AppUser.barangayId) — sent directly
          // rather than left for the trigger's GPS-based resolve_barangay(),
          // since there's no barangay_boundary polygon data for that to
          // actually resolve against yet (see setup guide §8.1). The trigger
          // only fills barangay_id when it's still null, so this still works
          // once boundary data exists and a citizen hasn't picked one.
          if (draft.barangayId != null) 'barangay_id': draft.barangayId,
          'location': 'SRID=4326;POINT(${draft.longitude} ${draft.latitude})',
          'submitted_by_user_id': userId,
          'current_state_code': ReportStatus.submitted.name,
        })
        .select()
        .single();

    final reportId = inserted['id'] as String;
    final organizationId = inserted['organization_id'] as String;

    // FR-1.2/FR-20.2 — either photoPaths is non-empty or videoPath is set,
    // never both; NewReportController enforces that before submit() is ever
    // called, so no either/or branching on "which one wins" is needed here.
    final citizenPhotoPaths = <String>[];
    String? citizenVideoPath;
    for (var i = 0; i < draft.photoPaths.length; i++) {
      final path = '$organizationId/$reportId/citizen-$i.jpg';
      await _client.storage
          .from(_bucket)
          .upload(path, File(draft.photoPaths[i]));
      await _client.from('report_attachment').insert({
        'report_id': reportId,
        'kind': 'citizen',
        'media_type': 'photo',
        'blob_url': path,
        'sequence': i,
      });
      citizenPhotoPaths.add(path);
    }
    if (draft.videoPath != null) {
      final path = '$organizationId/$reportId/citizen.mp4';
      await _client.storage.from(_bucket).upload(path, File(draft.videoPath!));
      await _client.from('report_attachment').insert({
        'report_id': reportId,
        'kind': 'citizen',
        'media_type': 'video',
        'duration_seconds': draft.videoDurationSeconds,
        'blob_url': path,
      });
      citizenVideoPath = path;
    }

    return _toReport(
      inserted,
      media: ReportMedia(
        citizenPhotoPaths: citizenPhotoPaths,
        citizenVideoPath: citizenVideoPath,
        citizenVideoDurationSeconds: draft.videoDurationSeconds,
      ),
    );
  }

  @override
  Future<void> confirmResolved(String reportId) async {
    await _client
        .from(_table)
        .update({'current_state_code': ReportStatus.closed.name})
        .eq('id', reportId);
  }

  @override
  Future<void> dispute(String reportId) async {
    await _client
        .from(_table)
        .update({'current_state_code': ReportStatus.reopened.name})
        .eq('id', reportId);
  }

  @override
  Future<void> react(
    String reportId,
    ReactionKind kind, {
    String? reason,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in before reacting to a report.');
    }
    if (kind == ReactionKind.dispute &&
        (reason == null || reason.trim().isEmpty)) {
      throw ArgumentError('A reason is required to dispute a report.');
    }
    // Upsert on (report_id, user_id)'s unique constraint — one reaction per
    // user per report, casting again replaces it (FR-17.1).
    await _client.from('report_reaction').upsert({
      'report_id': reportId,
      'user_id': userId,
      'reaction_kind': kind.name,
      'dispute_reason': kind == ReactionKind.dispute ? reason!.trim() : null,
    }, onConflict: 'report_id,user_id');
  }

  @override
  Future<void> removeReaction(String reportId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from('report_reaction')
        .delete()
        .eq('report_id', reportId)
        .eq('user_id', userId);
  }

  @override
  Future<ReactionKind?> myReaction(String reportId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('report_reaction')
        .select('reaction_kind')
        .eq('report_id', reportId)
        .eq('user_id', userId)
        .maybeSingle();
    final kind = row?['reaction_kind'] as String?;
    return kind == null ? null : ReactionKind.values.byName(kind);
  }

  @override
  Future<String> resolveMediaUrl(String path) async {
    // A leading slash means this is already a local file path, not a
    // Storage object path (report-photos paths are always `<org>/<report>/
    // citizen.{jpg,mp4}`, no leading slash) — defensive, shouldn't happen in
    // practice since this repository only ever stores the latter.
    if (path.startsWith('/')) return path;
    return _client.storage.from(_bucket).createSignedUrl(path, 3600);
  }

  Report _toReport(
    Map<String, dynamic> row, {
    ReportMedia media = const ReportMedia(),
    bool withAttachments = false,
  }) {
    final point = _parsePoint(row['location'] as String?);
    final resolvedMedia = withAttachments
        ? _mediaFrom(row['report_attachment'] as List<dynamic>?)
        : media;
    final verifiedAtRaw = row['verified_at'] as String?;

    return Report(
      id: row['id'] as String,
      trackingId: row['tracking_id'] as String,
      categoryId: row['category_id'] as String,
      description: (row['description'] as String?) ?? '',
      latitude: point?.lat ?? 0,
      longitude: point?.lng ?? 0,
      address: (row['address'] as String?) ?? '',
      status: ReportStatus.values.byName(
        (row['current_state_code'] as String?) ?? ReportStatus.submitted.name,
      ),
      createdAt: DateTime.parse(row['created_at'] as String),
      media: resolvedMedia,
      confirmationCount: (row['confirmation_count'] as int?) ?? 0,
      verifiedAt: verifiedAtRaw == null ? null : DateTime.parse(verifiedAtRaw),
      // Reaction counts are populated by findById/findByTrackingId's caller
      // via _withReactionCounts below, not here — realtime .stream() (used
      // by watchNearby/watchMine) can't aggregate, so list-view cards show 0
      // for now. Known limitation, not silently pretended away: FR-17.2
      // technically wants counts on the feed too.
    );
  }

  Future<Report> _withReactionCounts(Report report) async {
    final rows = await _client
        .from('report_reaction')
        .select('reaction_kind')
        .eq('report_id', report.id);
    var support = 0;
    var dispute = 0;
    for (final row in rows) {
      if (row['reaction_kind'] == 'support') support++;
      if (row['reaction_kind'] == 'dispute') dispute++;
    }
    return report.copyWith(supportCount: support, disputeCount: dispute);
  }

  ReportMedia _mediaFrom(List<dynamic>? attachments) {
    if (attachments == null || attachments.isEmpty) return const ReportMedia();
    final typed = attachments.cast<Map<String, dynamic>>();

    Map<String, dynamic>? findKind(String kind) {
      for (final attachment in typed) {
        if (attachment['kind'] == kind) return attachment;
      }
      return null;
    }

    // FR-1.2 — a report can have several citizen photos, ordered by
    // `sequence` (the order they were captured in), but at most one citizen
    // video (FR-20.2's mutual exclusion).
    final citizenPhotos =
        typed
            .where((a) => a['kind'] == 'citizen' && a['media_type'] == 'photo')
            .toList()
          ..sort(
            (a, b) => ((a['sequence'] as int?) ?? 0).compareTo(
              (b['sequence'] as int?) ?? 0,
            ),
          );
    final citizenVideo = typed.firstWhere(
      (a) => a['kind'] == 'citizen' && a['media_type'] == 'video',
      orElse: () => const {},
    );

    return ReportMedia(
      citizenPhotoPaths: [
        for (final photo in citizenPhotos) photo['blob_url'] as String,
      ],
      citizenVideoPath: citizenVideo['blob_url'] as String?,
      citizenVideoDurationSeconds: citizenVideo['duration_seconds'] as int?,
      beforePhotoPath: findKind('before')?['blob_url'] as String?,
      afterPhotoPath: findKind('after')?['blob_url'] as String?,
    );
  }

  /// PostgREST/Realtime return PostGIS `geography` columns as hex EWKB text
  /// (the type's own text output format) — this decodes the fixed 2D
  /// point-with-SRID layout PostGIS always produces for this column
  /// (1-byte endianness + 4-byte type/SRID flag + 4-byte SRID + 2×8-byte
  /// float). Verify against a real row once connected — same "check before
  /// trusting" spirit as the uuidv7() helper in the setup guide.
  ({double lat, double lng})? _parsePoint(String? hexEwkb) {
    if (hexEwkb == null || hexEwkb.length < 50) return null;
    final bytes = Uint8List(hexEwkb.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(hexEwkb.substring(i * 2, i * 2 + 2), radix: 16);
    }
    final data = ByteData.sublistView(bytes);
    final endian = bytes[0] == 1 ? Endian.little : Endian.big;
    return (lat: data.getFloat64(17, endian), lng: data.getFloat64(9, endian));
  }
}
