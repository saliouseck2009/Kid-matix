import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/bar_model_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/problem_board_progress.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/problem_statement.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/problem_step_choices.dart';

/// A word problem solved on its bar model (F30-03), or step by step from
/// the statement to the check (F30-04).
///
/// The child puts the numbers of the story on the model, picks the
/// operation, then the result. A wrong touch never ends the problem: the
/// message sends the child back to the story and the drawing, and the
/// mistake is counted (see [ProblemBoardProgress]). The problem is answered
/// once its last step is done, with the number of mistakes: right when
/// there was none.
class ProblemBoard extends StatefulWidget {
  /// Creates the board of [question]; [isGuided] adds the listening and
  /// the check steps.
  const ProblemBoard({
    required this.question,
    required this.isGuided,
    required this.languageCode,
    required this.onSolved,
    this.listenButton,
    super.key,
  });

  /// The problem, whose picture is a [BarModelPicture].
  final Question question;

  /// Whether the problem is solved in five steps instead of three.
  final bool isGuided;

  /// Language of the statement, which the voice speaks.
  final String languageCode;

  /// Called with the [ProblemAnswer] when the last step is done.
  final ValueChanged<Answer> onSolved;

  /// The button that reads the statement aloud, or `null` without a voice.
  final Widget? listenButton;

  @override
  State<ProblemBoard> createState() => _ProblemBoardState();
}

class _ProblemBoardState extends State<ProblemBoard> {
  late final ProblemBoardProgress _progress = ProblemBoardProgress(
    model: widget.question.picture! as BarModelPicture,
    isGuided: widget.isGuided,
  );

  /// Applies [move] to the progress and tells the screen; the answer goes
  /// out once the last step is done.
  void _update(VoidCallback move) {
    setState(move);
    if (_progress.isFinished) widget.onSolved(_progress.answer);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ProblemStep step = _progress.step;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            Expanded(
              child: Text(
                widget.isGuided
                    ? context.l10n.quizProblemSolveLabel
                    : context.l10n.quizBarModelQuestionLabel,
                style: textTheme.headlineSmall,
              ),
            ),
            ?widget.listenButton,
          ],
        ),
        Expanded(
          child: _ProblemPage(
            question: widget.question,
            languageCode: widget.languageCode,
            progress: _progress,
            onPlace: (BarRole role) =>
                _update(() => _progress.placeSelected(role)),
          ),
        ),
        ProblemStepChoices(
          progress: _progress,
          results: widget.question.choices,
          onTile: (int index) => _update(() => _progress.selectTile(index)),
          onOperator: (MathOperator operator) =>
              _update(() => _progress.pickOperator(operator)),
          onNumber: (int value) => _update(() => _progress.pickNumber(value)),
        ),
        if (step == ProblemStep.listen || step == ProblemStep.check)
          DepthButton(
            label: step == ProblemStep.listen
                ? context.l10n.quizProblemListened
                : context.l10n.quizProblemChecked,
            onPressed: () => _update(_progress.advance),
          ),
      ],
    );
  }
}

/// The statement, the instruction of the step and the model.
class _ProblemPage extends StatelessWidget {
  const _ProblemPage({
    required this.question,
    required this.languageCode,
    required this.progress,
    required this.onPlace,
  });

  final Question question;
  final String languageCode;
  final ProblemBoardProgress progress;
  final ValueChanged<BarRole> onPlace;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ProblemStep step = progress.step;
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
              isCompact: step != ProblemStep.listen,
            ),
            Text(
              context.l10n.quizProblemStepCounter(
                progress.stepIndex + 1,
                progress.steps.length,
              ),
              style: textTheme.labelLarge?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
            Text(_instruction(context, step), style: textTheme.titleMedium),
            if (step != ProblemStep.listen)
              BarModelView(
                picture: progress.model,
                placed: progress.placed,
                showsAnswer: progress.isComputed || step == ProblemStep.check,
                wrongRole: progress.wrongRole,
                wrongCount: progress.mistakeCount,
                onSlotTap: step == ProblemStep.model ? onPlace : null,
              ),
            if (progress.lastTouchWasWrong)
              Semantics(
                liveRegion: true,
                child: Text(
                  context.l10n.quizProblemTryAgain,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.feedbackPalette.wrong,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            if (step == ProblemStep.check)
              Text(progress.model.check, style: textTheme.titleLarge),
          ],
        ),
      ),
    );
  }

  String _instruction(BuildContext context, ProblemStep step) {
    return switch (step) {
      ProblemStep.listen => context.l10n.quizProblemStepListen,
      ProblemStep.model => context.l10n.quizProblemStepModel,
      ProblemStep.operation => context.l10n.quizProblemStepOperation,
      ProblemStep.compute => context.l10n.quizProblemStepCompute,
      ProblemStep.check => context.l10n.quizProblemStepCheck,
    };
  }
}
