import 'package:flutter/material.dart';

/// Colors of the provisional drawings of the math words, and the ring that
/// circles what a word is about.
abstract final class ScenePalette {
  static const Color ink = Color(0xFF221A4D);
  static const Color accent = Color(0xFFF27BC0);
  static const Color mango = Color(0xFFFF9F43);
  static const Color leaf = Color(0xFF4CAF50);
  static const Color coin = Color(0xFFFFC531);
  static const Color coinEdge = Color(0xFFE0A100);
  static const Color biscuit = Color(0xFFE6B87A);
  static const Color wood = Color(0xFFB7794A);
  static const Color plate = Color(0xFFE9E4FF);
  static const List<Color> marbles = <Color>[
    Color(0xFF6FB7FF),
    Color(0xFFFF8A75),
    Color(0xFF7FD3A8),
  ];
  static const Color bar = Color(0xFF8E78FF);

  /// Circles [cell] in the accent color.
  static void paintRing(Canvas canvas, Rect cell) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(cell.inflate(3), const Radius.circular(14)),
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
