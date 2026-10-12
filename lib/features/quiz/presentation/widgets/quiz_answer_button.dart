import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/theme/app_feedback_palette.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/answer_feedback.dart';

/// Big raised answer button: a number, "Vrai", "Faux" or a keypad key.
///
/// Once judged it turns green with a check or red with a cross, so the
/// meaning never relies on color alone.
class QuizAnswerButton extends StatelessWidget {
  /// Creates a button showing [label], led by [icon] if given.
  const QuizAnswerButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.feedback = AnswerFeedback.none,
    this.height = defaultHeight,
    this.semanticLabel,
    this.isSelected = false,
    super.key,
  });

  /// Height of an answer button of the mockups.
  static const double defaultHeight = 84;

  static const double _depth = 7;
  static const double _radius = 22;
  static const double _iconSize = 30;
  static const double _selectedBorderWidth = 4;

  /// Text of the button; may be empty for an icon-only key.
  final String label;

  /// Called when tapped; `null` disables the button.
  final VoidCallback? onTap;

  /// Icon shown before [label].
  final IconData? icon;

  /// Look of the button once the answer is judged.
  final AnswerFeedback feedback;

  /// Total height, raised edge included.
  final double height;

  /// Label for screen readers when [label] alone is not enough.
  final String? semanticLabel;

  /// Whether the player picked the button and the next tap completes the
  /// choice, as the first side of a pair: tinted with a thick border.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final _ButtonColors colors = _resolveColors(context);
    final BorderRadius radius = BorderRadius.circular(_radius);
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      // The label replaces the button's own semantics, its tap included.
      onTap: semanticLabel == null ? null : onTap,
      excludeSemantics: semanticLabel != null,
      child: Container(
        height: height,
        padding: const EdgeInsets.only(bottom: _depth),
        decoration: BoxDecoration(color: colors.edge, borderRadius: radius),
        child: Material(
          color: colors.face,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: colors.edge,
              width: isSelected ? _selectedBorderWidth : AppSizes.borderWidth,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(borderRadius: radius),
            child: _ButtonContent(
              label: label,
              icon: _resolveIcon(),
              color: colors.content,
            ),
          ),
        ),
      ),
    );
  }

  IconData? _resolveIcon() {
    return switch (feedback) {
      AnswerFeedback.none => icon,
      AnswerFeedback.right => Icons.check_rounded,
      AnswerFeedback.wrong => Icons.close_rounded,
    };
  }

  _ButtonColors _resolveColors(BuildContext context) {
    final AppFeedbackPalette palette = context.feedbackPalette;
    return switch (feedback) {
      AnswerFeedback.none when isSelected => (
        face: context.palette.tint,
        edge: Theme.of(context).colorScheme.primary,
        content: Theme.of(context).colorScheme.onSurface,
      ),
      AnswerFeedback.none => (
        face: Theme.of(context).colorScheme.surface,
        edge: context.palette.border,
        content: Theme.of(context).colorScheme.onSurface,
      ),
      AnswerFeedback.right => (
        face: palette.right,
        edge: palette.rightDepth,
        content: palette.onFeedback,
      ),
      AnswerFeedback.wrong => (
        face: palette.wrong,
        edge: palette.wrongDepth,
        content: palette.onFeedback,
      ),
    };
  }
}

typedef _ButtonColors = ({Color face, Color edge, Color content});

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final IconData? shownIcon = icon;
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.space8,
          children: <Widget>[
            if (shownIcon != null)
              Icon(shownIcon, size: QuizAnswerButton._iconSize, color: color),
            if (label.isNotEmpty)
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(color: color),
              ),
          ],
        ),
      ),
    );
  }
}
