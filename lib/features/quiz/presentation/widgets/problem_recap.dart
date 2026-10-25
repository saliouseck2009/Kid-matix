import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/bar_model_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/problem_statement.dart';

/// What a word problem shows once it is answered, right or wrong: the
/// statement and the finished bar model, answer included. It is the
/// correction of a mistake: the drawing shows what happens in the story,
/// whatever the words of the statement suggested.
class ProblemRecap extends StatelessWidget {
  /// Creates the recap of [question], whose picture is a bar model.
  const ProblemRecap({
    required this.question,
    required this.languageCode,
    super.key,
  });

  /// The question answered.
  final Question question;

  /// Language of the statement.
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final MathPicture? picture = question.picture;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSizes.space16,
          children: <Widget>[
            ProblemStatement(
              sentence: question.sentence,
              languageCode: languageCode,
              recordingKey: question.recordingKey,
            ),
            Text(
              context.l10n.quizProblemRecapTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (picture is BarModelPicture)
              BarModelView(picture: picture, showsAnswer: true),
          ],
        ),
      ),
    );
  }
}
