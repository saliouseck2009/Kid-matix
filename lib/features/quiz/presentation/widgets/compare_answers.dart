import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/comparison.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/answer_feedback.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_answer_button.dart';

/// The three signs of a comparison, `<`, `=` and `>`, each with its word
/// under it.
class CompareAnswers extends StatelessWidget {
  /// Creates the three buttons.
  const CompareAnswers({
    required this.feedbackOf,
    required this.onPicked,
    super.key,
  });

  /// Look of the button of each answer.
  final AnswerFeedback Function(Answer answer) feedbackOf;

  /// Called with the picked answer; `null` once the answer is judged.
  final ValueChanged<Answer>? onPicked;

  /// Sign shown for [comparison].
  static String signOf(Comparison comparison) {
    return switch (comparison) {
      Comparison.less => '<',
      Comparison.equal => '=',
      Comparison.greater => '>',
    };
  }

  /// Word of [comparison], under its sign and for screen readers.
  static String wordOf(BuildContext context, Comparison comparison) {
    return switch (comparison) {
      Comparison.less => context.l10n.quizCompareLess,
      Comparison.equal => context.l10n.quizCompareEqual,
      Comparison.greater => context.l10n.quizCompareGreater,
    };
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? captionStyle = Theme.of(context).textTheme.labelLarge
        ?.copyWith(color: context.palette.mutedText);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSizes.space12,
      children: <Widget>[
        for (final ComparisonAnswer answer in ComparisonAnswer.all)
          Expanded(
            child: Column(
              spacing: AppSizes.space4,
              children: <Widget>[
                QuizAnswerButton(
                  label: signOf(answer.comparison),
                  semanticLabel: wordOf(context, answer.comparison),
                  feedback: feedbackOf(answer),
                  onTap: onPicked == null ? null : () => onPicked!(answer),
                ),
                ExcludeSemantics(
                  child: Text(
                    wordOf(context, answer.comparison),
                    textAlign: TextAlign.center,
                    style: captionStyle,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
