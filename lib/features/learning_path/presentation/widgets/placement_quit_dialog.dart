import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Asks the player to confirm leaving the placement test; resolves to
/// `true` when they leave.
/// [isAssessment] says the class assessment stays pending.
Future<bool> confirmQuitPlacement(
  BuildContext context, {
  bool isAssessment = false,
}) async {
  final bool? isConfirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) =>
        PlacementQuitDialog(isAssessment: isAssessment),
  );
  return isConfirmed ?? false;
}

/// Confirmation dialog of leaving the placement test: the tables already
/// found stay open.
class PlacementQuitDialog extends StatelessWidget {
  /// Creates the dialog; [isAssessment] for a class assessment.
  const PlacementQuitDialog({this.isAssessment = false, super.key});

  /// Whether the test is part of a class assessment, which then stays
  /// pending.
  final bool isAssessment;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.placementQuitTitle),
      content: Text(
        isAssessment
            ? context.l10n.placementQuitAssessmentMessage
            : context.l10n.placementQuitMessage,
      ),
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
