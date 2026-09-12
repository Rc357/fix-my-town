import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/widgets/obs_button.dart';

/// Guest-only path — a Guest has no account to list history against
/// (FR-1.1), only the tracking ID(s) issued at submission. See
/// docs-mobile/03-screens-and-navigation.md for why this exists separately
/// from My Reports (which requires a Verified account).
class TrackByIdScreen extends StatefulWidget {
  const TrackByIdScreen({super.key});

  @override
  State<TrackByIdScreen> createState() => _TrackByIdScreenState();
}

class _TrackByIdScreenState extends State<TrackByIdScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _track() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    context.push('/reports/$value');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track a report')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ObsSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter the tracking ID you received when you submitted your report.',
              ),
              const SizedBox(height: ObsSpace.md),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(hintText: 'e.g. ANG-2WK9F3'),
                onSubmitted: (_) => _track(),
              ),
              const SizedBox(height: ObsSpace.lg),
              PrimaryButton(label: 'Track', onPressed: _track),
            ],
          ),
        ),
      ),
    );
  }
}
