import 'package:flutter/material.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/theme/app_feedback_palette.dart';
import 'package:kid_matix/core/theme/app_palette.dart';
import 'package:kid_matix/core/theme/app_text_theme.dart';

/// Material theme of the app, built from the design tokens.
abstract final class AppTheme {
  /// Light theme of the app.
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: AppColors.ground,
    textTheme: AppTextTheme.build(color: AppColors.ink),
    extensions: const <ThemeExtension<Object?>>[
      AppPalette.light,
      AppFeedbackPalette.light,
    ],
  );

  /// Dark theme of the boss fight screen: light text and keys on the deep
  /// indigo ground.
  static final ThemeData boss = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme.copyWith(
      brightness: Brightness.dark,
      surface: AppColors.bossSurface,
      onSurface: AppColors.white,
      onSurfaceVariant: AppColors.violetSoftBorder,
    ),
    scaffoldBackgroundColor: AppColors.ink,
    textTheme: AppTextTheme.build(color: AppColors.white),
    extensions: const <ThemeExtension<Object?>>[
      AppPalette.boss,
      AppFeedbackPalette.light,
    ],
  );

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.violet,
    onPrimary: AppColors.white,
    secondary: AppColors.yellow,
    onSecondary: AppColors.ink,
    error: AppColors.red,
    onError: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    outline: AppColors.violetBorder,
  );
}
