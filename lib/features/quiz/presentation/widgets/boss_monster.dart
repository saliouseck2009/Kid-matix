import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/monster_painter.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';

/// The monster of the fight, playing a short animation for each blow:
/// it shakes when hit, shakes and shrinks on a critical hit, lunges when
/// it strikes back, falls when defeated and runs away when it flees.
///
/// When the system asks for reduced motion, the monster stays still, or
/// shows the end of the fight at once.
class BossMonster extends StatelessWidget {
  /// Creates the monster [number].
  const BossMonster({
    required this.number,
    this.blow,
    this.outcome,
    super.key,
  });

  static const double _width = 248;
  static const Duration _blowDuration = Duration(milliseconds: 450);
  static const Duration _endDuration = Duration(milliseconds: 900);

  /// Number of the monster.
  final int number;

  /// What the last answer did, or `null`.
  final BossBlow? blow;

  /// How the fight ended, or `null`.
  final BossOutcome? outcome;

  @override
  Widget build(BuildContext context) {
    final Widget monster = MonsterIllustration(number: number, width: _width);
    final bool isStill =
        MediaQuery.disableAnimationsOf(context) ||
        (blow == null && outcome == null);
    if (isStill) return _pose(monster, outcome == null ? 0 : 1);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: outcome == null ? _blowDuration : _endDuration,
      curve: Curves.easeOut,
      child: monster,
      builder: (BuildContext context, double t, Widget? child) =>
          _pose(child!, t),
    );
  }

  /// The monster at the time [t] of its animation, from 0 to 1.
  Widget _pose(Widget monster, double t) {
    final double wave = sin(t * pi * 4) * (1 - t);
    final (double dx, double scale, double angle, double opacity) = switch ((
      outcome,
      blow,
    )) {
      (BossOutcome.defeated, _) => (0, 1 - 0.5 * t, t * 0.6, 1 - 0.7 * t),
      (BossOutcome.fled, _) => (t * 400, 1, 0, 1 - t),
      (null, BossBlow.hit) => (wave * 12, 1, 0, 1),
      (null, BossBlow.criticalHit) => (wave * 18, 1 - 0.15 * sin(t * pi), 0, 1),
      (null, BossBlow.strikeBack) => (0, 1 + 0.15 * sin(t * pi), 0, 1),
      (null, null) => (0, 1, 0, 1),
    };
    return Opacity(
      opacity: opacity.clamp(0, 1),
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Transform.rotate(
          angle: angle,
          child: Transform.scale(scale: scale, child: monster),
        ),
      ),
    );
  }
}
