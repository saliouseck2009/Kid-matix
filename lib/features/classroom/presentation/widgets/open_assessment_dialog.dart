import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_rules.dart';

/// Asks the teacher the name of the period of a new assessment; resolves
/// to the name, or `null` when cancelled.
Future<String?> askAssessmentLabel(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => const OpenAssessmentDialog(),
  );
}

/// The dialog of « Lancer une évaluation »: the name of the period.
/// No mockup: built with the design system (F31).
class OpenAssessmentDialog extends StatefulWidget {
  /// Creates the dialog.
  const OpenAssessmentDialog({super.key});

  @override
  State<OpenAssessmentDialog> createState() => _OpenAssessmentDialogState();
}

class _OpenAssessmentDialogState extends State<OpenAssessmentDialog> {
  final TextEditingController _label = TextEditingController();
  bool _isInvalid = false;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  void _submit() {
    final String? label = AssessmentRules.cleanLabel(_label.text);
    if (label == null) {
      setState(() => _isInvalid = true);
      return;
    }
    Navigator.of(context).pop(label);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.classroomAssessmentNew),
      content: TextField(
        controller: _label,
        autofocus: true,
        maxLength: AssessmentRules.maxLabelLength,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: context.l10n.classroomAssessmentLabelLabel,
          hintText: context.l10n.classroomAssessmentLabelHint,
          errorText: _isInvalid
              ? context.l10n.classroomAssessmentLabelError
              : null,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(context.l10n.classroomAssessmentStart),
        ),
      ],
    );
  }
}

/// Asks the teacher to confirm the closing of the assessment [label];
/// resolves to whether they confirmed.
Future<bool> confirmAssessmentClosing(
  BuildContext context,
  String label,
) async {
  final bool? isConfirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(context.l10n.classroomAssessmentCloseTitle(label)),
      content: Text(context.l10n.classroomAssessmentCloseMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.classroomAssessmentClose),
        ),
      ],
    ),
  );
  return isConfirmed ?? false;
}
