import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/problem_board_progress.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/problem_choice_button.dart';

/// What the child touches at the current step of a word problem: the
/// numbers of the story to put on the model, the four signs, or the
/// results of the calculation. The listening and the check steps have no
/// choice.
class ProblemStepChoices extends StatelessWidget {
  /// Creates the choices of the step of [progress].
  const ProblemStepChoices({
    required this.progress,
    required this.results,
    required this.onTile,
    required this.onOperator,
    required this.onNumber,
    super.key,
  });

  /// Where the child is.
  final ProblemBoardProgress progress;

  /// The results offered at the calculation step.
  final List<Answer> results;

  /// Called with the index of a tile.
  final ValueChanged<int> onTile;

  /// Called with a sign.
  final ValueChanged<MathOperator> onOperator;

  /// Called with a result.
  final ValueChanged<int> onNumber;

  /// Part of the calculation shown before its result: `12 − 5 =`.
  static const int calculationStart = 4;

  @override
  Widget build(BuildContext context) {
    return switch (progress.step) {
      ProblemStep.model => _tiles(context),
      ProblemStep.operation => _wrap(<Widget>[
        for (final OperatorAnswer answer in OperatorAnswer.all)
          _operator(context, answer.operator),
      ]),
      ProblemStep.compute => _compute(context),
      ProblemStep.listen || ProblemStep.check => const SizedBox.shrink(),
    };
  }

  Widget _wrap(List<Widget> children) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSizes.space12,
      runSpacing: AppSizes.space12,
      children: children,
    );
  }

  Widget _tiles(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSizes.space12,
      children: <Widget>[
        _wrap(<Widget>[
          for (int index = 0; index < progress.tiles.length; index++)
            if (!progress.usedTiles.contains(index))
              ProblemChoiceButton(
                key: ValueKey<String>('tile-$index'),
                label: '${progress.tiles[index]}',
                semanticLabel: '${progress.tiles[index]}',
                state: progress.selectedTile == index
                    ? ProblemChoiceState.selected
                    : ProblemChoiceState.none,
                onTap: () => onTile(index),
              ),
        ]),
        Text(
          context.l10n.quizProblemPickNumberFirst,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.palette.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _operator(BuildContext context, MathOperator operator) {
    final List<PromptToken> sign = <PromptToken>[OperatorToken(operator)];
    final bool isWrong = progress.wrongOperators.contains(operator);
    return ProblemChoiceButton(
      key: ValueKey<String>('operator-${operator.name}'),
      label: sign.toDisplayText(),
      semanticLabel: sign.toSpokenText(context.l10n),
      state: isWrong ? ProblemChoiceState.wrong : ProblemChoiceState.none,
      onTap: isWrong ? null : () => onOperator(operator),
    );
  }

  Widget _compute(BuildContext context) {
    final List<PromptToken> start = progress.model.calculation
        .take(calculationStart)
        .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSizes.space12,
      children: <Widget>[
        Text(
          '${start.toDisplayText()} ?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        _wrap(<Widget>[
          for (final Answer choice in results)
            if (choice is NumberAnswer)
              ProblemChoiceButton(
                key: ValueKey<String>('number-${choice.value}'),
                label: '${choice.value}',
                semanticLabel: '${choice.value}',
                state: progress.wrongNumbers.contains(choice.value)
                    ? ProblemChoiceState.wrong
                    : ProblemChoiceState.none,
                onTap: progress.wrongNumbers.contains(choice.value)
                    ? null
                    : () => onNumber(choice.value),
              ),
        ]),
      ],
    );
  }
}
