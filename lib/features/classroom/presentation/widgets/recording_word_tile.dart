import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/classroom/domain/entities/teacher_recordings.dart';

/// One word on the page of the teacher's recordings: its text, what
/// plays now (the teacher's voice, the pack's, or nothing), and the
/// buttons to record, listen and delete.
class RecordingWordTile extends StatelessWidget {
  /// Creates the tile of [word], written [label].
  const RecordingWordTile({
    required this.word,
    required this.label,
    required this.isEnabled,
    required this.onRecord,
    required this.onListen,
    required this.onDelete,
    super.key,
  });

  /// The word.
  final RecordingWord word;

  /// Its text, such as « il reste ».
  final String label;

  /// Whether the buttons work (not while recording another word).
  final bool isEnabled;

  /// Records it.
  final VoidCallback onRecord;

  /// Plays what the children hear.
  final VoidCallback onListen;

  /// Deletes the teacher's recording.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String status = word.hasTeacherAudio
        ? context.l10n.classroomRecordingsTeacher
        : word.hasPackAudio
        ? context.l10n.classroomRecordingsPack
        : context.l10n.classroomRecordingsNone;
    return Row(
      spacing: AppSizes.space4,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: textTheme.titleMedium),
              Text(
                status,
                style: textTheme.bodySmall?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.mic_rounded),
          tooltip: context.l10n.classroomRecordingsRecord(label),
          onPressed: isEnabled ? onRecord : null,
        ),
        if (word.hasTeacherAudio || word.hasPackAudio)
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: context.l10n.classroomRecordingsListen(label),
            onPressed: isEnabled ? onListen : null,
          ),
        if (word.hasTeacherAudio)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: context.l10n.classroomRecordingsDelete(label),
            onPressed: isEnabled ? onDelete : null,
          ),
      ],
    );
  }
}
