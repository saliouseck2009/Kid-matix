import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Asks the player to confirm leaving the quiz; resolves to `true` when
/// they leave.
Future<bool> confirmQuitQuiz(BuildContext context) async {
  final bool? isConfirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => const QuitQuizDialog(),
  );
  return isConfirmed ?? false;
}

/// Confirmation dialog of leaving a quiz.
class QuitQuizDialog extends StatelessWidget {
  /// Creates the dialog.
  const QuitQuizDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.quizQuitTitle),
      content: Text(context.l10n.quizQuitMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.quizQuitCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(context.l10n.quizQuitConfirm),
        ),
      ],
    );
  }
}
