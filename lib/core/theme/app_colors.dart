import 'package:flutter/material.dart';

/// Raw colors of the design.
///
/// Widgets never read these directly: they go through `ThemeData` and
/// `AppPalette`, which map each color to a role. Every text and background
/// pair used by the theme meets the WCAG AA contrast ratio.
abstract final class AppColors {
  /// Lavender ground of every screen.
  static const Color ground = Color(0xFFF4F1FF);

  /// Deep indigo used for text and for the boss screens.
  static const Color ink = Color(0xFF221A4D);

  /// Muted indigo for secondary text.
  static const Color muted = Color(0xFF5D567A);

  /// Surface of cards and controls.
  static const Color white = Color(0xFFFFFFFF);

  /// Main action color.
  static const Color violet = Color(0xFF5B3DF5);

  /// Raised edge under violet controls.
  static const Color violetDepth = Color(0xFF3A22B8);

  /// Violet dark enough for text on a light ground.
  static const Color violetText = Color(0xFF4A2FD6);

  /// Light violet behind selected or highlighted elements.
  static const Color violetTint = Color(0xFFE4DEFF);

  /// Outline of white controls.
  static const Color violetBorder = Color(0xFFDDD6FF);

  /// Reward color: stars, crowns, streaks.
  static const Color yellow = Color(0xFFFFC531);

  /// Raised edge under yellow controls.
  static const Color yellowDepth = Color(0xFFE0A100);

  /// Light yellow behind reward elements.
  static const Color yellowTint = Color(0xFFFFF3CF);

  /// Right answer.
  static const Color green = Color(0xFF137A4B);

  /// Raised edge under green controls.
  static const Color greenDepth = Color(0xFF0C5A36);

  /// Light green behind a right-answer message.
  static const Color greenTint = Color(0xFFDDF3E6);

  /// Wrong answer and destructive actions.
  static const Color red = Color(0xFFC8321F);

  /// Raised edge under red controls.
  static const Color redDepth = Color(0xFF8F2114);

  /// Light red behind a wrong-answer message.
  static const Color redTint = Color(0xFFFBE3DF);
}
