import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/theme/app_feedback_palette.dart';

/// How an answer button of the duel looks after a mistake.
enum DuelAnswerMark {
  /// Not judged.
  none,

  /// The right answer, shown after a mistake.
  right,

  /// The wrong answer the player tapped.
  wrong,
}

/// A raised answer button of a duel half: a number, then a check or a
/// cross once judged, so color never speaks alone.
class DuelAnswerButton extends StatelessWidget {
  /// Creates the button of [value].
  const DuelAnswerButton({
    required this.value,
    required this.borderColor,
    required this.onTap,
    this.mark = DuelAnswerMark.none,
    super.key,
  });

  static const double _height = 70;
  static const double _depth = 6;
  static const double _radius = 18;
  static const double _fontSize = 30;
  static const double _iconSize = 26;

  /// Number shown.
  final int value;

  /// Border and edge of an unjudged button.
  final Color borderColor;

  /// Called when tapped; `null` while the player is blocked.
  final VoidCallback? onTap;

  /// Look once judged.
  final DuelAnswerMark mark;

  @override
  Widget build(BuildContext context) {
    final AppFeedbackPalette feedback = context.feedbackPalette;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final (Color face, Color edge, Color content) = switch (mark) {
      DuelAnswerMark.none => (colors.surface, borderColor, colors.onSurface),
      DuelAnswerMark.right => (
        feedback.right,
        feedback.rightDepth,
        feedback.onFeedback,
      ),
      DuelAnswerMark.wrong => (
        feedback.wrong,
        feedback.wrongDepth,
        feedback.onFeedback,
      ),
    };
    final BorderRadius radius = BorderRadius.circular(_radius);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: switch (mark) {
        DuelAnswerMark.none => '$value',
        DuelAnswerMark.right => context.l10n.duelAnswerRight(value),
        DuelAnswerMark.wrong => context.l10n.duelAnswerWrong(value),
      },
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: _height),
        padding: const EdgeInsets.only(bottom: _depth),
        decoration: BoxDecoration(color: edge, borderRadius: radius),
        child: Material(
          color: face,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: edge, width: AppSizes.borderWidth),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(borderRadius: radius),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSizes.space8,
                children: <Widget>[
                  if (mark == DuelAnswerMark.right)
                    Icon(Icons.check_rounded, color: content, size: _iconSize),
                  if (mark == DuelAnswerMark.wrong)
                    Icon(Icons.close_rounded, color: content, size: _iconSize),
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: content, fontSize: _fontSize),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
