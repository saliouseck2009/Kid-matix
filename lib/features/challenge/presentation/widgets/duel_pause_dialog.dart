import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Opens the pause of the duel; resolves to `true` when the players stop
/// it.
Future<bool> showDuelPause(BuildContext context) async {
  final bool? isStopped = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => const DuelPauseDialog(),
  );
  return isStopped ?? false;
}

/// The pause of the duel: go on, or stop without XP.
class DuelPauseDialog extends StatelessWidget {
  /// Creates the dialog.
  const DuelPauseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.duelPauseTitle),
      content: Text(context.l10n.duelPauseMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.duelResume),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(context.l10n.duelStop),
        ),
      ],
    );
  }
}
