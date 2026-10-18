import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/widgets/word_picture/word_picture_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/answer_feedback.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_answer_button.dart';

/// The four drawings of a "Listen and tap" question, two by two. Each is a
/// button; a screen reader says the word of its drawing.
class WordPictureChoices extends StatelessWidget {
  /// Creates the grid of [choices], each a [WordAnswer].
  const WordPictureChoices({
    required this.choices,
    required this.feedbackOf,
    required this.onPicked,
    super.key,
  });

  static const int _columnCount = 2;
  static const double _gap = AppSizes.space12;

  /// Words to pick from, in display order.
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
                    label: '',
                    semanticLabel: choice is WordAnswer ? choice.text : null,
                    height: QuizAnswerButton.defaultHeight * 1.5,
                    feedback: feedbackOf(choice),
                    onTap: onPicked == null ? null : () => onPicked!(choice),
                    child: choice is WordAnswer
                        ? WordPictureView(wordKey: choice.wordKey)
                        : null,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
