import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// The discreet entry of the teacher area, at the bottom of « Qui
/// joue ? »: a small text button, so children are not drawn to it.
class TeacherEntryButton extends StatelessWidget {
  /// Creates the button.
  const TeacherEntryButton({required this.onOpen, super.key});

  /// Opens the door of the teacher area.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onOpen,
      icon: const Icon(Icons.school_rounded),
      label: Text(context.l10n.classroomTeacherArea),
      style: TextButton.styleFrom(foregroundColor: context.palette.mutedText),
    );
  }
}
