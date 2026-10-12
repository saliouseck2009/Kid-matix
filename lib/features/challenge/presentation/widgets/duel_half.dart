import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_contender.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_answer_button.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_avatar.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_avatar_builder.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_player_name.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_side_style.dart';

/// One half of the duel: the player, their score, their question and
/// their 4 answers (mockup 15).
class DuelHalf extends StatelessWidget {
  /// Creates the half of [contender].
  const DuelHalf({
    required this.contender,
    required this.winningScore,
    required this.style,
    required this.avatarOf,
    required this.onAnswer,
    super.key,
  });

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(20, 20, 20, 28);

  /// The player and their progress.
  final DuelContender contender;

  /// Right answers that win.
  final int winningScore;

  /// Colors of the half.
  final DuelSideStyle style;

  /// Draws the avatar of a profile.
  final DuelAvatarBuilder avatarOf;

  /// Called with the answer tapped.
  final ValueChanged<Answer> onAnswer;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: style.ground,
      child: Padding(
        padding: _padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ScoreHeader(
              contender: contender,
              winningScore: winningScore,
              style: style,
              avatarOf: avatarOf,
            ),
            Flexible(child: _Prompt(contender: contender)),
            _Answers(contender: contender, style: style, onAnswer: onAnswer),
          ],
        ),
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({
    required this.contender,
    required this.winningScore,
    required this.style,
    required this.avatarOf,
  });

  static const double _avatarSize = 40;
  static const double _barHeight = 12;
  static const double _fontSize = 20;

  final DuelContender contender;
  final int winningScore;
  final DuelSideStyle style;
  final DuelAvatarBuilder avatarOf;

  @override
  Widget build(BuildContext context) {
    final TextStyle? text = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontSize: _fontSize);
    final String name = contender.player.nameIn(context.l10n);
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusPill);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space8,
      children: <Widget>[
        Row(
          spacing: 10,
          children: <Widget>[
            DuelAvatar(
              player: contender.player,
              avatarOf: avatarOf,
              guestColor: style.accent,
              size: _avatarSize,
            ),
            Expanded(
              child: Text(name, style: text, overflow: TextOverflow.ellipsis),
            ),
            ExcludeSemantics(
              child: Text(
                context.l10n.duelScore(contender.score, winningScore),
                style: text?.copyWith(color: style.scoreText),
              ),
            ),
          ],
        ),
        Semantics(
          label: context.l10n.duelScoreSpoken(
            name,
            contender.score,
            winningScore,
          ),
          child: Container(
            height: _barHeight,
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: radius,
            ),
            child: FractionallySizedBox(
              widthFactor: (contender.score / winningScore).clamp(0, 1),
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: style.accent,
                  borderRadius: radius,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Prompt extends StatelessWidget {
  const _Prompt({required this.contender});

  static const double _fontSize = 46;

  final DuelContender contender;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppSizes.space8,
      children: <Widget>[
        Semantics(
          label: contender.question.prompt.toSpokenText(context.l10n),
          excludeSemantics: true,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              contender.question.prompt.toDisplayText(),
              maxLines: 1,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontSize: _fontSize),
            ),
          ),
        ),
        Visibility(
          visible: contender.isBlocked,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Semantics(
            liveRegion: true,
            child: Text(
              context.l10n.duelBlocked,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.feedbackPalette.wrong,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Answers extends StatelessWidget {
  const _Answers({
    required this.contender,
    required this.style,
    required this.onAnswer,
  });

  static const double _gap = 10;
  static const int _perRow = 2;

  final DuelContender contender;
  final DuelSideStyle style;
  final ValueChanged<Answer> onAnswer;

  DuelAnswerMark _markOf(Answer choice) {
    if (!contender.isBlocked) return DuelAnswerMark.none;
    if (choice == contender.wrongAnswer) return DuelAnswerMark.wrong;
    if (choice == contender.question.expectedAnswer) {
      return DuelAnswerMark.right;
    }
    return DuelAnswerMark.none;
  }

  @override
  Widget build(BuildContext context) {
    final List<Answer> choices = contender.question.choices;
    return Column(
      spacing: _gap,
      children: <Widget>[
        for (int row = 0; row * _perRow < choices.length; row++)
          Row(
            spacing: _gap,
            children: <Widget>[
              for (final Answer choice
                  in choices
                      .skip(row * _perRow)
                      .take(
                        _perRow,
                      ))
                Expanded(
                  child: DuelAnswerButton(
                    value: choice is NumberAnswer ? choice.value : 0,
                    borderColor: style.buttonBorder,
                    mark: _markOf(choice),
                    onTap: contender.isBlocked ? null : () => onAnswer(choice),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
