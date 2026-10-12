import 'package:flutter/material.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';

/// Colors of a half of the duel (mockup 15): green at the top, violet at
/// the bottom, so each player finds their half at a glance; the names
/// and the scores say it too.
@immutable
final class DuelSideStyle {
  const DuelSideStyle._({
    required this.ground,
    required this.accent,
    required this.scoreText,
    required this.buttonBorder,
  });

  /// Style of [side].
  factory DuelSideStyle.of(DuelSide side) => switch (side) {
    DuelSide.top => _top,
    DuelSide.bottom => _bottom,
  };

  static const DuelSideStyle _top = DuelSideStyle._(
    ground: AppColors.greenSurface,
    accent: AppColors.green,
    scoreText: AppColors.greenDepth,
    buttonBorder: AppColors.greenBorder,
  );

  static const DuelSideStyle _bottom = DuelSideStyle._(
    ground: AppColors.ground,
    accent: AppColors.violet,
    scoreText: AppColors.violetText,
    buttonBorder: AppColors.violetBorder,
  );

  /// Background of the half.
  final Color ground;

  /// Filled part of the score bar and the guest avatar.
  final Color accent;

  /// Color of the score.
  final Color scoreText;

  /// Border and raised edge of the answer buttons.
  final Color buttonBorder;
}
