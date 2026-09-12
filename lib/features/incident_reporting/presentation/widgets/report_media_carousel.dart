import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/features/incident_reporting/data/report_providers.dart';
import 'package:obserba/features/incident_reporting/domain/report.dart';

/// Renders whichever of photos/video a report has (FR-20.2 — never both).
/// Shared by ReportFeedPost and the detail screen so a report's media only
/// has one rendering path. Multiple photos (FR-1.2) page through a
/// PageView with dot indicators, Facebook-album style; a single photo
/// renders the same way, just without dots.
class ReportMediaCarousel extends StatelessWidget {
  const ReportMediaCarousel({required this.media, this.height = 240, super.key});

  final ReportMedia media;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (media.hasVideo) {
      return _VideoPlaceholder(
        seconds: media.citizenVideoDurationSeconds ?? 0,
        height: height,
      );
    }
    if (media.hasPhotos) {
      return _PhotoPager(paths: media.citizenPhotoPaths, height: height);
    }
    return const SizedBox.shrink();
  }
}

class _PhotoPager extends StatefulWidget {
  const _PhotoPager({required this.paths, required this.height});

  final List<String> paths;
  final double height;

  @override
  State<_PhotoPager> createState() => _PhotoPagerState();
}

class _PhotoPagerState extends State<_PhotoPager> {
  final _pageController = PageController();
  var _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.paths.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => _ResolvedPhoto(path: widget.paths[index]),
          ),
        ),
        if (widget.paths.length > 1) ...[
          Positioned(
            top: ObsSpace.sm,
            right: ObsSpace.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(ObsRadius.pill),
              ),
              child: Text(
                '${_page + 1}/${widget.paths.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Positioned(
            bottom: ObsSpace.sm,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.paths.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: i == _page ? 8 : 6,
                    height: i == _page ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ResolvedPhoto extends ConsumerWidget {
  const _ResolvedPhoto({required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: ref.read(reportRepositoryProvider).resolveMediaUrl(path),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: ObsColors.line,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }
        final resolved = snapshot.data!;
        return resolved.startsWith('http')
            ? Image.network(resolved, fit: BoxFit.cover, width: double.infinity)
            : Image.file(File(resolved), fit: BoxFit.cover, width: double.infinity);
      },
    );
  }
}

/// Static placeholder, not inline playback — full autoplay-in-feed video is
/// explicitly out of scope (FR-20.5), and there's no thumbnail-extraction
/// step yet to show a real frame.
class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.seconds, required this.height});

  final int seconds;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: ObsColors.ink,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
          const SizedBox(height: ObsSpace.xs),
          Text(
            '${seconds}s video',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
