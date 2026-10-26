import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/theme/app_feedback_palette.dart';

/// How a choice of a word problem step looks.
enum ProblemChoiceState {
  /// Not touched.
  none,

  /// Picked, waiting for its place.
  selected,

  /// Picked wrongly: red with a cross, and said so to a screen reader.
  wrong,
}

/// A big number or sign to touch; once wrong it turns red with a cross, so
/// the meaning never relies on color alone.
class ProblemChoiceButton extends StatelessWidget {
  /// Creates the button showing [label], said [semanticLabel].
  const ProblemChoiceButton({
    required this.label,
    required this.semanticLabel,
    required this.state,
    required this.onTap,
    super.key,
  });

  static const double _size = 64;

  /// The number or the sign.
  final String label;

  /// What a screen reader says for [label].
  final String semanticLabel;

  /// How the button looks.
  final ProblemChoiceState state;

  /// Called when touched; `null` disables the button.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppFeedbackPalette feedback = context.feedbackPalette;
    final bool isWrong = state == ProblemChoiceState.wrong;
    final bool isSelected = state == ProblemChoiceState.selected;
    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: isSelected,
      label: isWrong
          ? context.l10n.quizProblemChoiceWrong(semanticLabel)
          : semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: isWrong
            ? feedback.wrong
            : isSelected
            ? colors.primary
            : context.palette.tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: _size,
              minHeight: _size,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space16,
                vertical: AppSizes.space8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSizes.space4,
                children: <Widget>[
                  if (isWrong)
                    Icon(Icons.close_rounded, color: colors.onPrimary),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isWrong || isSelected
                          ? colors.onPrimary
                          : context.palette.primaryText,
                    ),
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
