import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/answer_feedback.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_answer_button.dart';

/// The "Vrai" and "Faux" buttons of a true or false question.
class TrueFalseAnswers extends StatelessWidget {
  /// Creates the two buttons.
  const TrueFalseAnswers({
    required this.feedbackOf,
    required this.onPicked,
    super.key,
  });

  static const double _height = 140;

  /// Look of the button of each answer.
  final AnswerFeedback Function(Answer answer) feedbackOf;

  /// Called with the picked answer; `null` once the answer is judged.
  final ValueChanged<Answer>? onPicked;

  @override
  Widget build(BuildContext context) {
    const Answer trueAnswer = BooleanAnswer(value: true);
    const Answer falseAnswer = BooleanAnswer(value: false);
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        Expanded(
          child: QuizAnswerButton(
            label: context.l10n.quizTrue,
            icon: Icons.check_rounded,
            height: _height,
            feedback: feedbackOf(trueAnswer),
            onTap: onPicked == null ? null : () => onPicked!(trueAnswer),
          ),
        ),
        Expanded(
          child: QuizAnswerButton(
            label: context.l10n.quizFalse,
            icon: Icons.close_rounded,
            height: _height,
            feedback: feedbackOf(falseAnswer),
            onTap: onPicked == null ? null : () => onPicked!(falseAnswer),
          ),
        ),
      ],
    );
  }
}
