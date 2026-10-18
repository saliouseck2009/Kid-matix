import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';

/// Draws bundles of ten sticks tied with a band, five to a row, then the
/// loose sticks on their right. The sticks are a provisional drawing.
class TenBundlesPainter extends CustomPainter {
  /// Creates the painter of [tens] bundles and [ones] loose sticks.
  TenBundlesPainter({required this.tens, required this.ones});

  /// Bundles per row.
  static const int bundlesPerRow = 5;

  static const double _stickWidth = 5;
  static const double _stickGap = 1;
  static const double _stickHeight = 72;
  static const double _bundleGap = 14;
  static const double _looseGap = 9;
  static const double _groupGap = 28;
  static const double _rowGap = 14;
  static const double _bandHeight = 10;
  static const Color _wood = Color(0xFFC98B4A);
  static const Color _woodEdge = Color(0xFF8A5A2B);
  static const Color _band = Color(0xFFD9482F);

  /// Bundles of ten sticks.
  final int tens;

  /// Loose sticks.
  final int ones;

  static const int _sticksPerBundle = TenBundlesPicture.sticksPerBundle;

  double get _bundleWidth =>
      _sticksPerBundle * _stickWidth + (_sticksPerBundle - 1) * _stickGap;

  int get _rows => math.max(1, (tens + bundlesPerRow - 1) ~/ bundlesPerRow);

  double get _bundlesWidth {
    if (tens == 0) return 0;
    final int columns = math.min(tens, bundlesPerRow);
    return columns * _bundleWidth + (columns - 1) * _bundleGap;
  }

  double get _looseWidth {
    if (ones == 0) return 0;
    return ones * _stickWidth + (ones - 1) * _looseGap;
  }

  /// Size of the drawing in design units.
  Size get designSize {
    final double gap = tens > 0 && ones > 0 ? _groupGap : 0;
    return Size(
      math.max(_bundlesWidth + gap + _looseWidth, _stickWidth),
      _rows * _stickHeight + (_rows - 1) * _rowGap,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Size design = designSize;
    canvas.save();
    canvas.scale(size.width / design.width, size.height / design.height);
    for (int bundle = 0; bundle < tens; bundle++) {
      _paintBundle(
        canvas,
        Offset(
          (bundle % bundlesPerRow) * (_bundleWidth + _bundleGap),
          (bundle ~/ bundlesPerRow) * (_stickHeight + _rowGap),
        ),
      );
    }
    final double looseLeft = tens > 0 ? _bundlesWidth + _groupGap : 0;
    final double looseTop = (_rows - 1) * (_stickHeight + _rowGap);
    for (int stick = 0; stick < ones; stick++) {
      _paintStick(
        canvas,
        Offset(looseLeft + stick * (_stickWidth + _looseGap), looseTop),
      );
    }
    canvas.restore();
  }

  void _paintBundle(Canvas canvas, Offset topLeft) {
    for (int stick = 0; stick < _sticksPerBundle; stick++) {
      _paintStick(
        canvas,
        topLeft.translate(stick * (_stickWidth + _stickGap), 0),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          topLeft.dx - 2,
          topLeft.dy + (_stickHeight - _bandHeight) / 2,
          _bundleWidth + 4,
          _bandHeight,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = _band,
    );
  }

  void _paintStick(Canvas canvas, Offset topLeft) {
    final RRect stick = RRect.fromRectAndRadius(
      Rect.fromLTWH(topLeft.dx, topLeft.dy, _stickWidth, _stickHeight),
      const Radius.circular(2),
    );
    canvas.drawRRect(stick, Paint()..color = _wood);
    canvas.drawRRect(
      stick,
      Paint()
        ..color = _woodEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(TenBundlesPainter oldDelegate) {
    return oldDelegate.tens != tens || oldDelegate.ones != ones;
  }
}
