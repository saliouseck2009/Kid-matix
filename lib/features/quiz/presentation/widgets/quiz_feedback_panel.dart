import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/theme/app_feedback_palette.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_hint_box.dart';

/// Message after an answer: a title, a detail and "Continuer".
///
/// Green after a right answer, with "Éclair !" when it was fast; red
/// after a mistake, with the whole operation and, when it has one, the
/// same operation the other way round.
class QuizFeedbackPanel extends StatelessWidget {
  /// Creates the panel.
  const QuizFeedbackPanel({
    required this.isRight,
    required this.title,
    required this.detail,
    required this.onContinue,
    this.reminder,
    super.key,
  });

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSizes.space16,
    14,
    AppSizes.space16,
    AppSizes.space16,
  );

  /// Whether the answer was right.
  final bool isRight;

  /// "Bravo !", "Presque !" or "Temps écoulé !".
  final String title;

  /// "Éclair !" or the whole operation; may be empty.
  final String detail;

  /// "Retiens aussi : 8 × 7 = 56" after a mistake, or `null`.
  final String? reminder;

  /// Called by "Continuer".
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final AppFeedbackPalette palette = context.feedbackPalette;
    final Color textColor = isRight ? palette.rightDepth : palette.wrongDepth;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? reminder = this.reminder;
    return Container(
      constraints: const BoxConstraints(minHeight: QuizHintBox.height),
      padding: _padding,
      decoration: BoxDecoration(
        color: isRight ? palette.rightTint : palette.wrongTint,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space8,
        children: <Widget>[
          Semantics(
            liveRegion: true,
            container: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSizes.space4,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title,
                        style: textTheme.headlineSmall?.copyWith(
                          color: textColor,
                        ),
                      ),
                    ),
                    Text(
                      detail,
                      style: textTheme.titleLarge?.copyWith(color: textColor),
                    ),
                  ],
                ),
                if (reminder != null)
                  Text(
                    reminder,
                    style: textTheme.bodyLarge?.copyWith(color: textColor),
                  ),
              ],
            ),
          ),
          DepthButton(
            label: context.l10n.quizContinue,
            variant: isRight
                ? DepthButtonVariant.success
                : DepthButtonVariant.danger,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}
