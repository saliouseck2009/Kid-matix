import 'package:flutter/material.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/theme/app_palette.dart';
import 'package:kid_matix/core/theme/app_text_theme.dart';

/// Material theme of the app, built from the design tokens.
abstract final class AppTheme {
  /// Light theme, the only theme of version 1.0.
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: AppColors.ground,
    textTheme: AppTextTheme.build(color: AppColors.ink),
    extensions: const <ThemeExtension<AppPalette>>[AppPalette.light],
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
