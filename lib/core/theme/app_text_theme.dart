import 'package:flutter/material.dart';

/// Type scale of the design: Fredoka for display text, Nunito for body text.
///
/// Both families are bundled variable fonts, so each style selects its weight
/// through the `wght` axis as well as through `fontWeight`.
abstract final class AppTextTheme {
  /// Rounded display family used for titles, numbers and buttons.
  static const String displayFontFamily = 'Fredoka';

  /// Body family used for labels and running text.
  static const String bodyFontFamily = 'Nunito';

  static const String _weightAxis = 'wght';
  static const int _displayWeight = 600;
  static const int _weightStep = 100;
  static const double _displayLineHeight = 1.15;
  static const double _bodyLineHeight = 1.3;

  /// Builds the text theme with every style painted in [color].
  static TextTheme build({required Color color}) {
    final TextTheme textTheme = TextTheme(
      displaySmall: _display(36),
      headlineMedium: _display(30),
      headlineSmall: _display(26),
      titleLarge: _display(22),
      titleMedium: _display(18),
      bodyLarge: _body(size: 17, weight: 700),
      bodyMedium: _body(size: 16, weight: 700),
      bodySmall: _body(size: 14, weight: 700),
      labelLarge: _body(size: 15, weight: 800),
      labelMedium: _body(size: 13, weight: 800),
    );
    return textTheme.apply(bodyColor: color, displayColor: color);
  }

  static TextStyle _display(double size) {
    return TextStyle(
      fontFamily: displayFontFamily,
      fontSize: size,
      height: _displayLineHeight,
      fontWeight: _toFontWeight(_displayWeight),
      fontVariations: _toVariations(_displayWeight),
    );
  }

  static TextStyle _body({required double size, required int weight}) {
    return TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: size,
      height: _bodyLineHeight,
      fontWeight: _toFontWeight(weight),
      fontVariations: _toVariations(weight),
    );
  }

  static FontWeight _toFontWeight(int weight) {
    return FontWeight.values[weight ~/ _weightStep - 1];
  }

  static List<FontVariation> _toVariations(int weight) {
    return <FontVariation>[FontVariation(_weightAxis, weight.toDouble())];
  }
}
