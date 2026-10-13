import 'package:flutter/material.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/theme/app_colors.dart';

/// The colors that change from one [AppColorTheme] to another.
///
/// The reward, answer and avatar colors stay the same in every theme.
/// Every text and background pair meets the WCAG AA contrast ratio,
/// checked by `test/core/theme/app_theme_contrast_test.dart`.
@immutable
final class AppThemeColors {
  /// Creates the colors of a theme.
  const AppThemeColors({
    required this.brightness,
    required this.ground,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.primary,
    required this.primaryDepth,
    required this.primaryText,
    required this.tint,
    required this.border,
    required this.strongBorder,
    required this.softBorder,
    required this.lockedFace,
    required this.lockedDepth,
    required this.lockedSurface,
    required this.warmTint,
  });

  /// Lavender and violet, the colors of the design.
  static const AppThemeColors lavender = AppThemeColors(
    brightness: Brightness.light,
    ground: AppColors.ground,
    surface: AppColors.white,
    ink: AppColors.ink,
    muted: AppColors.muted,
    primary: AppColors.violet,
    primaryDepth: AppColors.violetDepth,
    primaryText: AppColors.violetText,
    tint: AppColors.violetTint,
    border: AppColors.violetBorder,
    strongBorder: AppColors.violetStrongBorder,
    softBorder: AppColors.violetSoftBorder,
    lockedFace: AppColors.lockedFace,
    lockedDepth: AppColors.lockedDepth,
    lockedSurface: AppColors.lockedSurface,
    warmTint: AppColors.yellowTint,
  );

  /// Blues of the sea.
  static const AppThemeColors ocean = AppThemeColors(
    brightness: Brightness.light,
    ground: Color(0xFFEEF6FF),
    surface: AppColors.white,
    ink: Color(0xFF10284A),
    muted: Color(0xFF4B5E78),
    primary: Color(0xFF0B63C4),
    primaryDepth: Color(0xFF074A94),
    primaryText: Color(0xFF0A57AD),
    tint: Color(0xFFDCEBFF),
    border: Color(0xFFCFE2FA),
    strongBorder: Color(0xFF8DB4E8),
    softBorder: Color(0xFFB5D0F2),
    lockedFace: Color(0xFFDDE6F3),
    lockedDepth: Color(0xFFC6D3E6),
    lockedSurface: Color(0xFFE6EDF7),
    warmTint: AppColors.yellowTint,
  );

  /// Greens of the woods.
  static const AppThemeColors forest = AppThemeColors(
    brightness: Brightness.light,
    ground: Color(0xFFEFF7F0),
    surface: AppColors.white,
    ink: Color(0xFF15301E),
    muted: Color(0xFF4D6355),
    primary: Color(0xFF1E7A3E),
    primaryDepth: Color(0xFF135A2C),
    primaryText: Color(0xFF17693A),
    tint: Color(0xFFD9F0DF),
    border: Color(0xFFCBE6D2),
    strongBorder: Color(0xFF8CC39C),
    softBorder: Color(0xFFB2D9BD),
    lockedFace: Color(0xFFDCE8DF),
    lockedDepth: Color(0xFFC5D6CA),
    lockedSurface: Color(0xFFE5EEE7),
    warmTint: AppColors.yellowTint,
  );

  /// Oranges of a sunset.
  static const AppThemeColors sunset = AppThemeColors(
    brightness: Brightness.light,
    ground: Color(0xFFFFF3EC),
    surface: AppColors.white,
    ink: Color(0xFF3A1A12),
    muted: Color(0xFF6E4F45),
    primary: Color(0xFFC2410C),
    primaryDepth: Color(0xFF8F2F08),
    primaryText: Color(0xFFA8380A),
    tint: Color(0xFFFFE1D1),
    border: Color(0xFFF8D5C3),
    strongBorder: Color(0xFFE8A47F),
    softBorder: Color(0xFFF2C2A6),
    lockedFace: Color(0xFFF1E1D8),
    lockedDepth: Color(0xFFE2CCC0),
    lockedSurface: Color(0xFFF5E8E1),
    warmTint: AppColors.yellowTint,
  );

  /// A dark theme: light text on a deep blue night.
  static const AppThemeColors night = AppThemeColors(
    brightness: Brightness.dark,
    ground: Color(0xFF120F2A),
    surface: Color(0xFF231D4A),
    ink: AppColors.white,
    muted: Color(0xFFC9C2EE),
    primary: AppColors.violet,
    primaryDepth: Color(0xFF2A1A8F),
    primaryText: Color(0xFFB9ABFF),
    tint: Color(0xFF3A2F73),
    border: Color(0xFF3A3270),
    strongBorder: Color(0xFF7A6CD0),
    softBorder: Color(0xFF5A4FA8),
    lockedFace: Color(0xFF2E2858),
    lockedDepth: Color(0xFF1C1840),
    lockedSurface: Color(0xFF2C2656),
    warmTint: Color(0xFF4A3A10),
  );

  /// Whether the theme is light or dark.
  final Brightness brightness;

  /// Ground of every screen.
  final Color ground;

  /// Surface of cards and controls.
  final Color surface;

  /// Text and icons on [ground] and [surface].
  final Color ink;

  /// Secondary text.
  final Color muted;

  /// Main action color, under white text.
  final Color primary;

  /// Raised edge under [primary] controls.
  final Color primaryDepth;

  /// Primary color for text on [ground], [surface] and [tint].
  final Color primaryText;

  /// Background of selected or highlighted elements.
  final Color tint;

  /// Outline of [surface] controls.
  final Color border;

  /// Stronger outline: text fields and the "new player" card.
  final Color strongBorder;

  /// Soft outline of the dashed hint boxes.
  final Color softBorder;

  /// Face of a locked node of the learning path.
  final Color lockedFace;

  /// Raised edge of a locked node, and badge of a locked stage.
  final Color lockedDepth;

  /// Background of a locked stage card.
  final Color lockedSurface;

  /// Background of reward elements.
  final Color warmTint;

  /// Returns the colors of [theme].
  static AppThemeColors of(AppColorTheme theme) {
    return switch (theme) {
      AppColorTheme.lavender => lavender,
      AppColorTheme.ocean => ocean,
      AppColorTheme.forest => forest,
      AppColorTheme.sunset => sunset,
      AppColorTheme.night => night,
    };
  }
}
