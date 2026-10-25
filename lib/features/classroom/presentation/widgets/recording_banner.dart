import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';

/// The card shown while a word is recorded: « Enregistrement de « il
/// reste »… », « Arrêter et garder » and « Recommencer plus tard ».
class RecordingBanner extends StatelessWidget {
  /// Creates the card of [word].
  const RecordingBanner({
    required this.word,
    required this.seconds,
    required this.maxSeconds,
    required this.onKeep,
    required this.onCancel,
    super.key,
  });

  /// The word recorded.
  final String word;

  /// Seconds recorded so far.
  final int seconds;

  /// Seconds after which the recording stops and is kept.
  final int maxSeconds;

  /// Stops and keeps the recording.
  final VoidCallback onKeep;

  /// Stops and throws it away.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space12,
        children: <Widget>[
          Semantics(
            liveRegion: true,
            child: Text(
              context.l10n.classroomRecordingsRecording(word),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          AppProgressBar(
            value: seconds / maxSeconds,
            semanticLabel: context.l10n.classroomRecordingsTime(
              seconds,
              maxSeconds,
            ),
          ),
          ExcludeSemantics(
            child: Text(
              context.l10n.classroomRecordingsTime(seconds, maxSeconds),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          DepthButton(
            label: context.l10n.classroomRecordingsKeep,
            icon: Icons.stop_rounded,
            onPressed: onKeep,
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(context.l10n.classroomRecordingsCancel),
          ),
        ],
      ),
    );
  }
}
