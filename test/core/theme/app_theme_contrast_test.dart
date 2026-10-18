import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/theme/app_palette.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/core/theme/app_theme_colors.dart';

/// WCAG AA ratio for normal text.
const double _textRatio = 4.5;

/// WCAG AA ratio for large text and controls.
const double _controlRatio = 3;

double _contrast(Color first, Color second) {
  final double lighter = max(
    first.computeLuminance(),
    second.computeLuminance(),
  );
  final double darker = min(
    first.computeLuminance(),
    second.computeLuminance(),
  );
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Color themes', () {
    for (final AppColorTheme theme in AppColorTheme.values) {
      test('${theme.name} meets the AA contrast ratios', () {
        // Arrange
        final AppThemeColors colors = AppThemeColors.of(theme);
        final Map<String, (Color, Color)> textPairs = <String, (Color, Color)>{
          'ink on ground': (colors.ink, colors.ground),
          'ink on surface': (colors.ink, colors.surface),
          'ink on tint': (colors.ink, colors.tint),
          'ink on locked surface': (colors.ink, colors.lockedSurface),
          'ink on warm tint': (colors.ink, colors.warmTint),
          'muted on ground': (colors.muted, colors.ground),
          'muted on surface': (colors.muted, colors.surface),
          'muted on locked surface': (colors.muted, colors.lockedSurface),
          'primary text on ground': (colors.primaryText, colors.ground),
          'primary text on surface': (colors.primaryText, colors.surface),
          'primary text on tint': (colors.primaryText, colors.tint),
          'white on primary': (AppColors.white, colors.primary),
          'ink on yellow': (AppColors.ink, AppColors.yellow),
        };
        // Act and assert
        for (final MapEntry<String, (Color, Color)> pair in textPairs.entries) {
          expect(
            _contrast(pair.value.$1, pair.value.$2),
            greaterThanOrEqualTo(_textRatio),
            reason: pair.key,
          );
        }
        expect(
          _contrast(colors.primary, colors.ground),
          greaterThanOrEqualTo(_controlRatio),
          reason: 'primary control on ground',
        );
      });
    }

    test('builds one Material theme per color theme', () {
      // Act
      final ThemeData actualNight = AppTheme.of(AppColorTheme.night);
      // Assert
      expect(AppTheme.of(AppColorTheme.lavender), same(AppTheme.light));
      expect(AppTheme.of(AppColorTheme.ocean), same(AppTheme.ocean));
      expect(AppTheme.of(AppColorTheme.forest), same(AppTheme.forest));
      expect(AppTheme.of(AppColorTheme.sunset), same(AppTheme.sunset));
      expect(actualNight.colorScheme.brightness, Brightness.dark);
      expect(actualNight.colorScheme.onSurface, AppColors.white);
      expect(
        actualNight.extension<AppPalette>()!.tint,
        AppThemeColors.night.tint,
      );
      expect(
        AppTheme.light.extension<AppPalette>()!.primaryText,
        AppPalette.light.primaryText,
      );
    });
  });
}
