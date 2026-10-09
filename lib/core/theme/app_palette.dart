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
    required this.secondaryDepth,
    required this.strongBorder,
    required this.avatarBackgrounds,
  });

  /// Palette of the light theme, the only theme of version 1.0.
  static const AppPalette light = AppPalette(
    primaryDepth: AppColors.violetDepth,
    primaryText: AppColors.violetText,
    tint: AppColors.violetTint,
    border: AppColors.violetBorder,
    mutedText: AppColors.muted,
    warmTint: AppColors.yellowTint,
    secondaryDepth: AppColors.yellowDepth,
    strongBorder: AppColors.violetStrongBorder,
    avatarBackgrounds: <Color>[
      AppColors.violet,
      AppColors.green,
      AppColors.yellow,
      AppColors.avatarRed,
      AppColors.avatarBlue,
      AppColors.avatarPink,
    ],
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

  /// Raised edge and shadow of secondary (yellow) elements.
  final Color secondaryDepth;

  /// Outline of text fields and dashed hint boxes.
  final Color strongBorder;

  /// Colors a player can pick for their avatar, in the order of the color
  /// picker: violet, green, yellow, red, blue, pink.
  final List<Color> avatarBackgrounds;

  @override
  AppPalette copyWith({
    Color? primaryDepth,
    Color? primaryText,
    Color? tint,
    Color? border,
    Color? mutedText,
    Color? warmTint,
    Color? secondaryDepth,
    Color? strongBorder,
    List<Color>? avatarBackgrounds,
  }) {
    return AppPalette(
      primaryDepth: primaryDepth ?? this.primaryDepth,
      primaryText: primaryText ?? this.primaryText,
      tint: tint ?? this.tint,
      border: border ?? this.border,
      mutedText: mutedText ?? this.mutedText,
      warmTint: warmTint ?? this.warmTint,
      secondaryDepth: secondaryDepth ?? this.secondaryDepth,
      strongBorder: strongBorder ?? this.strongBorder,
      avatarBackgrounds: avatarBackgrounds ?? this.avatarBackgrounds,
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
      secondaryDepth: Color.lerp(secondaryDepth, other.secondaryDepth, t)!,
      strongBorder: Color.lerp(strongBorder, other.strongBorder, t)!,
      avatarBackgrounds: t < 0.5 ? avatarBackgrounds : other.avatarBackgrounds,
    );
  }
}
