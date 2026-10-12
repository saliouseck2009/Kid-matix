import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Asks the player to confirm leaving the placement test; resolves to
/// `true` when they leave.
Future<bool> confirmQuitPlacement(BuildContext context) async {
  final bool? isConfirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => const PlacementQuitDialog(),
  );
  return isConfirmed ?? false;
}

/// Confirmation dialog of leaving the placement test: the tables already
/// found stay open.
class PlacementQuitDialog extends StatelessWidget {
  /// Creates the dialog.
  const PlacementQuitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.placementQuitTitle),
      content: Text(context.l10n.placementQuitMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.placementQuitCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.placementQuitConfirm),
        ),
      ],
    );
  }
}
