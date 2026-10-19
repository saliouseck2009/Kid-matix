import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/answer_feedback.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/compare_answers.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_answer_button.dart';

/// The four answers of a multiple choice question, two by two: numbers,
/// or operations for a "find the operation" question.
class MultipleChoiceAnswers extends StatelessWidget {
  /// Creates the grid of [choices].
  const MultipleChoiceAnswers({
    required this.choices,
    required this.feedbackOf,
    required this.onPicked,
    super.key,
  });

  static const int _columnCount = 2;
  static const double _gap = AppSizes.space12;

  /// Answers to pick from, in display order.
  final List<Answer> choices;

  /// Look of the button of each answer.
  final AnswerFeedback Function(Answer answer) feedbackOf;

  /// Called with the picked answer; `null` once the answer is judged.
  final ValueChanged<Answer>? onPicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: _gap,
      children: <Widget>[
        for (int start = 0; start < choices.length; start += _columnCount)
          Row(
            spacing: _gap,
            children: <Widget>[
              for (final Answer choice
                  in choices.skip(start).take(_columnCount))
                Expanded(
                  child: QuizAnswerButton(
                    label: describeAnswer(choice),
                    semanticLabel: switch (choice) {
                      OperationAnswer(:final operation) =>
                        operation.toSpokenText(context.l10n),
                      OperatorAnswer(:final operator) => <PromptToken>[
                        OperatorToken(operator),
                      ].toSpokenText(context.l10n),
                      _ => null,
                    },
                    feedback: feedbackOf(choice),
                    onTap: onPicked == null ? null : () => onPicked!(choice),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// Text of an answer button: `35`, `4 × 6` or a sign such as `<`.
  static String describeAnswer(Answer answer) {
    return switch (answer) {
      NumberAnswer(:final int value) => '$value',
      OperationAnswer(:final operation) => operation.toDisplayText(),
      ComparisonAnswer(:final comparison) => CompareAnswers.signOf(comparison),
      OperatorAnswer(:final operator) => <PromptToken>[
        OperatorToken(operator),
      ].toDisplayText(),
      WordAnswer(:final String text) => text,
      BooleanAnswer() || PairsAnswer() => '',
    };
  }
}
