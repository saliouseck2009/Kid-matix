import 'package:flutter/material.dart';
import 'package:kid_matix/core/theme/app_colors.dart';

/// Colors of a right or wrong answer, and of the timer running out.
///
/// Color never carries meaning alone: the screens also show a check or a
/// cross, and a title.
@immutable
final class AppFeedbackPalette extends ThemeExtension<AppFeedbackPalette> {
  /// Creates the palette from its role colors.
  const AppFeedbackPalette({
    required this.right,
    required this.rightDepth,
    required this.rightTint,
    required this.wrong,
    required this.wrongDepth,
    required this.wrongTint,
    required this.onFeedback,
  });

  /// Palette of the light theme.
  static const AppFeedbackPalette light = AppFeedbackPalette(
    right: AppColors.green,
    rightDepth: AppColors.greenDepth,
    rightTint: AppColors.greenTint,
    wrong: AppColors.red,
    wrongDepth: AppColors.redDepth,
    wrongTint: AppColors.redTint,
    onFeedback: AppColors.white,
  );

  /// Right answer.
  final Color right;

  /// Raised edge under a right answer, and its text on [rightTint].
  final Color rightDepth;

  /// Background of the right-answer message.
  final Color rightTint;

  /// Wrong answer, and the timer in its last seconds.
  final Color wrong;

  /// Raised edge under a wrong answer, and its text on [wrongTint].
  final Color wrongDepth;

  /// Background of the wrong-answer message.
  final Color wrongTint;

  /// Text and icons on [right] or [wrong].
  final Color onFeedback;

  @override
  AppFeedbackPalette copyWith({
    Color? right,
    Color? rightDepth,
    Color? rightTint,
    Color? wrong,
    Color? wrongDepth,
    Color? wrongTint,
    Color? onFeedback,
  }) {
    return AppFeedbackPalette(
      right: right ?? this.right,
      rightDepth: rightDepth ?? this.rightDepth,
      rightTint: rightTint ?? this.rightTint,
      wrong: wrong ?? this.wrong,
      wrongDepth: wrongDepth ?? this.wrongDepth,
      wrongTint: wrongTint ?? this.wrongTint,
      onFeedback: onFeedback ?? this.onFeedback,
    );
  }

  @override
  AppFeedbackPalette lerp(
    ThemeExtension<AppFeedbackPalette>? other,
    double t,
  ) {
    if (other is! AppFeedbackPalette) return this;
    return AppFeedbackPalette(
      right: Color.lerp(right, other.right, t)!,
      rightDepth: Color.lerp(rightDepth, other.rightDepth, t)!,
      rightTint: Color.lerp(rightTint, other.rightTint, t)!,
      wrong: Color.lerp(wrong, other.wrong, t)!,
      wrongDepth: Color.lerp(wrongDepth, other.wrongDepth, t)!,
      wrongTint: Color.lerp(wrongTint, other.wrongTint, t)!,
      onFeedback: Color.lerp(onFeedback, other.onFeedback, t)!,
    );
  }
}
