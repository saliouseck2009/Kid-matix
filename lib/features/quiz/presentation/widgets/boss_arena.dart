import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/boss_monster.dart';

/// Middle of the boss fight: the monster with its bubble, then the
/// operation with the answer box.
class BossArena extends StatelessWidget {
  /// Creates the arena.
  const BossArena({
    required this.monsterNumber,
    required this.prompt,
    required this.blowCount,
    this.blow,
    this.outcome,
    this.blankText,
    this.blankColor,
    super.key,
  });

  static const double _promptFontSize = 52;

  /// Number of the monster, the number of the table.
  final int monsterNumber;

  /// Operation asked.
  final List<PromptToken> prompt;

  /// Answers given so far; a new value replays the blow animation.
  final int blowCount;

  /// What the last answer did, or `null` while the player answers.
  final BossBlow? blow;

  /// How the fight ended, or `null` while it goes on.
  final BossOutcome? outcome;

  /// Digits typed in place of the blank, if any.
  final String? blankText;

  /// Color of the typed digits.
  final Color? blankColor;

  @override
  Widget build(BuildContext context) {
    final String? bubble = _bubbleText(context);
    return Column(
      spacing: AppSizes.space12,
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              Center(
                child: BossMonster(
                  key: ValueKey<int>(blowCount),
                  number: monsterNumber,
                  blow: blow,
                  outcome: outcome,
                ),
              ),
              if (bubble != null)
                Positioned(
                  right: AppSizes.space4,
                  top: AppSizes.space16,
                  child: _Bubble(text: bubble),
                ),
            ],
          ),
        ),
        Semantics(
          label: prompt.toSpokenText(context.l10n),
          excludeSemantics: true,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _BossPrompt(
              prompt: prompt,
              blankText: blankText,
              blankColor: blankColor,
              fontSize: _promptFontSize,
            ),
          ),
        ),
      ],
    );
  }

  String? _bubbleText(BuildContext context) {
    final BossOutcome? end = outcome;
    if (end != null) {
      return switch (end) {
        BossOutcome.defeated => context.l10n.quizBossDefeated,
        BossOutcome.fled => context.l10n.quizBossFled,
      };
    }
    return switch (blow) {
      BossBlow.hit => context.l10n.quizBossHit(BossFight.hitDamage),
      BossBlow.criticalHit => context.l10n.quizBossCriticalHit(
        BossFight.criticalDamage,
      ),
      BossBlow.strikeBack => context.l10n.quizBossStrikeBack,
      null => null,
    };
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text});

  static const double _tilt = 0.1;

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Transform.rotate(
        angle: _tilt,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.secondary,
            borderRadius: BorderRadius.circular(AppSizes.space16),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: scheme.onSecondary),
          ),
        ),
      ),
    );
  }
}

/// `5 × 9 =` followed by a white box holding the typed digits.
class _BossPrompt extends StatelessWidget {
  const _BossPrompt({
    required this.prompt,
    required this.blankText,
    required this.blankColor,
    required this.fontSize,
  });

  static const double _boxBorder = 4;
  static const double _boxMinWidth = 116;
  static const double _boxRadius = 20;

  final List<PromptToken> prompt;
  final String? blankText;
  final Color? blankColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(
      context,
    ).textTheme.displaySmall?.copyWith(fontSize: fontSize);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<String> parts = prompt.toDisplayParts(blankText: blankText);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSizes.space12,
      children: <Widget>[
        for (int index = 0; index < prompt.length; index++)
          if (prompt[index] is BlankToken)
            Container(
              constraints: const BoxConstraints(minWidth: _boxMinWidth),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.onPrimary,
                border: Border.all(color: scheme.secondary, width: _boxBorder),
                borderRadius: BorderRadius.circular(_boxRadius),
              ),
              child: Text(
                parts[index],
                style: style?.copyWith(
                  color: blankColor ?? scheme.onSecondary,
                ),
              ),
            )
          else
            Text(parts[index], style: style),
      ],
    );
  }
}
