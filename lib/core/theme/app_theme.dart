import 'package:flutter/material.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/theme/app_feedback_palette.dart';
import 'package:kid_matix/core/theme/app_palette.dart';
import 'package:kid_matix/core/theme/app_text_theme.dart';
import 'package:kid_matix/core/theme/app_theme_colors.dart';

/// Material theme of the app, built from the design tokens.
abstract final class AppTheme {
  /// Light theme of the app, in the lavender colors of the design.
  static final ThemeData light = _build(AppThemeColors.lavender);

  /// Blue theme of the shop.
  static final ThemeData ocean = _build(AppThemeColors.ocean);

  /// Green theme of the shop.
  static final ThemeData forest = _build(AppThemeColors.forest);

  /// Orange theme of the shop.
  static final ThemeData sunset = _build(AppThemeColors.sunset);

  /// Dark theme of the shop.
  static final ThemeData night = _build(AppThemeColors.night);

  /// Dark theme of the boss fight screen: light text and keys on the deep
  /// indigo ground.
  static final ThemeData boss = ThemeData(
    useMaterial3: true,
    colorScheme: _schemeOf(AppThemeColors.lavender).copyWith(
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

  /// Returns the theme a player applied, [light] by default.
  static ThemeData of(AppColorTheme theme) {
    return switch (theme) {
      AppColorTheme.lavender => light,
      AppColorTheme.ocean => ocean,
      AppColorTheme.forest => forest,
      AppColorTheme.sunset => sunset,
      AppColorTheme.night => night,
    };
  }

  static ThemeData _build(AppThemeColors colors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _schemeOf(colors),
      scaffoldBackgroundColor: colors.ground,
      textTheme: AppTextTheme.build(color: colors.ink),
      extensions: <ThemeExtension<Object?>>[
        AppPalette.of(colors),
        AppFeedbackPalette.light,
      ],
    );
  }

  static ColorScheme _schemeOf(AppThemeColors colors) {
    return ColorScheme(
      brightness: colors.brightness,
      primary: colors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.yellow,
      onSecondary: AppColors.ink,
      error: AppColors.red,
      onError: AppColors.white,
      surface: colors.surface,
      onSurface: colors.ink,
      onSurfaceVariant: colors.muted,
      outline: colors.border,
    );
  }
}
