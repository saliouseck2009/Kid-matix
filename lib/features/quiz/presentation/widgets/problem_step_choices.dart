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

  @override
  Widget build(BuildContext context) {
    return switch (progress.step) {
      ProblemStep.model => _TileChoices(progress: progress, onTile: onTile),
      ProblemStep.operation => _ChoiceWrap(
        children: <Widget>[
          for (final OperatorAnswer answer in OperatorAnswer.all)
            _OperatorChoice(
              progress: progress,
              operator: answer.operator,
              onOperator: onOperator,
            ),
        ],
      ),
      ProblemStep.compute => _ComputeChoices(
        progress: progress,
        results: results,
        onNumber: onNumber,
      ),
      ProblemStep.listen || ProblemStep.check => const SizedBox.shrink(),
    };
  }
}

/// Choices side by side, wrapping on a narrow screen.
class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSizes.space12,
      runSpacing: AppSizes.space12,
      children: children,
    );
  }
}

/// The numbers of the story still to put on the model.
class _TileChoices extends StatelessWidget {
  const _TileChoices({required this.progress, required this.onTile});

  final ProblemBoardProgress progress;
  final ValueChanged<int> onTile;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSizes.space12,
      children: <Widget>[
        _ChoiceWrap(
          children: <Widget>[
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
          ],
        ),
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
}

/// One of the four signs.
class _OperatorChoice extends StatelessWidget {
  const _OperatorChoice({
    required this.progress,
    required this.operator,
    required this.onOperator,
  });

  final ProblemBoardProgress progress;
  final MathOperator operator;
  final ValueChanged<MathOperator> onOperator;

  @override
  Widget build(BuildContext context) {
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
}

/// The calculation to finish and the results to pick from.
class _ComputeChoices extends StatelessWidget {
  const _ComputeChoices({
    required this.progress,
    required this.results,
    required this.onNumber,
  });

  /// Part of the calculation shown before its result: `12 − 5 =`.
  static const int calculationStart = 4;

  final ProblemBoardProgress progress;
  final List<Answer> results;
  final ValueChanged<int> onNumber;

  @override
  Widget build(BuildContext context) {
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
        _ChoiceWrap(
          children: <Widget>[
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
          ],
        ),
      ],
    );
  }
}
