import 'package:flutter/material.dart';
import 'package:kid_matix/core/theme/app_colors.dart';

/// Design colors that Material's `ColorScheme` has no slot for.
@immutable
final class AppPalette extends ThemeExtension<AppPalette> {
  /// Creates a palette from its role colors.
  const AppPalette({
    required this.primaryDepth,
    required this.primaryText,
    required this.tint,
    required this.border,
    required this.mutedText,
    required this.warmTint,
  });

  /// Palette of the light theme, the only theme of version 1.0.
  static const AppPalette light = AppPalette(
    primaryDepth: AppColors.violetDepth,
    primaryText: AppColors.violetText,
    tint: AppColors.violetTint,
    border: AppColors.violetBorder,
    mutedText: AppColors.muted,
    warmTint: AppColors.yellowTint,
  );

  /// Raised edge under a primary button.
  final Color primaryDepth;

  /// Primary color dark enough for text on a light surface.
  final Color primaryText;

  /// Background of selected or highlighted elements.
  final Color tint;

  /// Outline and raised edge of white controls.
  final Color border;

  /// Secondary text.
  final Color mutedText;

  /// Background of reward elements.
  final Color warmTint;

  @override
  AppPalette copyWith({
    Color? primaryDepth,
    Color? primaryText,
    Color? tint,
    Color? border,
    Color? mutedText,
    Color? warmTint,
  }) {
    return AppPalette(
      primaryDepth: primaryDepth ?? this.primaryDepth,
      primaryText: primaryText ?? this.primaryText,
      tint: tint ?? this.tint,
      border: border ?? this.border,
      mutedText: mutedText ?? this.mutedText,
      warmTint: warmTint ?? this.warmTint,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primaryDepth: Color.lerp(primaryDepth, other.primaryDepth, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      border: Color.lerp(border, other.border, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      warmTint: Color.lerp(warmTint, other.warmTint, t)!,
    );
  }
}
