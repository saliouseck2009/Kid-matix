import 'package:flutter/rendering.dart';
import 'package:kid_matix/core/entities/accessory_slot.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';

/// Draws the accessories of the mascot in its 120 x 120 box: the back
/// ones behind the body, the others in front.
///
/// Provisional drawings, like the mascot itself.
final class MascotAccessoryPainter {
  /// Creates the painter of [accessories].
  const MascotAccessoryPainter({required this.accessories});

  static const Color _red = Color(0xFFE8604C);
  static const Color _blue = Color(0xFF1F6FD6);
  static const Color _green = Color(0xFF137A4B);
  static const Color _gold = Color(0xFFFFC531);
  static const Color _goldDark = Color(0xFFE0A100);
  static const Color _violet = Color(0xFF5B3DF5);
  static const Color _pink = Color(0xFFF27BC0);
  static const Color _brown = Color(0xFF8A5A3B);
  static const Color _ink = Color(0xFF221A4D);
  static const Color _white = Color(0xFFFFFFFF);

  /// Accessories worn.
  final Set<MascotAccessory> accessories;

  /// Paints what the mascot wears on its back, behind its body.
  void paintBehind(Canvas canvas) {
    for (final MascotAccessory accessory in accessories) {
      if (accessory.slot == AccessorySlot.back) _paint(canvas, accessory);
    }
  }

  /// Paints what the mascot wears on its head, eyes and neck.
  void paintInFront(Canvas canvas) {
    for (final AccessorySlot slot in <AccessorySlot>[
      AccessorySlot.neck,
      AccessorySlot.eyes,
      AccessorySlot.head,
    ]) {
      for (final MascotAccessory accessory in accessories) {
        if (accessory.slot == slot) _paint(canvas, accessory);
      }
    }
  }

  void _paint(Canvas canvas, MascotAccessory accessory) {
    switch (accessory) {
      case MascotAccessory.cap:
        _fill(
          canvas,
          Path()..addArc(const Rect.fromLTWH(30, 4, 60, 40), 3.14, 3.14),
          _blue,
        );
        _fill(
          canvas,
          Path()..addRRect(
            RRect.fromLTRBR(56, 20, 104, 28, const Radius.circular(4)),
          ),
          _blue,
        );
      case MascotAccessory.wizardHat:
        _fill(
          canvas,
          _triangle(
            const Offset(36, 28),
            const Offset(84, 28),
            const Offset(60, -24),
          ),
          _violet,
        );
        _fill(
          canvas,
          Path()..addOval(
            Rect.fromCenter(center: const Offset(60, 6), width: 8, height: 8),
          ),
          _gold,
        );
      case MascotAccessory.headphones:
        _stroke(
          canvas,
          Path()..addArc(const Rect.fromLTWH(18, 6, 84, 70), 3.3, 2.8),
          _ink,
          6,
        );
        _fill(
          canvas,
          Path()..addRRect(
            RRect.fromLTRBR(12, 44, 24, 64, const Radius.circular(5)),
          ),
          _red,
        );
        _fill(
          canvas,
          Path()..addRRect(
            RRect.fromLTRBR(96, 44, 108, 64, const Radius.circular(5)),
          ),
          _red,
        );
      case MascotAccessory.kingCrown:
        _fill(canvas, _zigzagCrown(), _gold);
      case MascotAccessory.partyHat:
        _fill(
          canvas,
          _triangle(
            const Offset(46, 24),
            const Offset(74, 24),
            const Offset(60, -12),
          ),
          _pink,
        );
        _fill(
          canvas,
          Path()..addOval(
            Rect.fromCenter(center: const Offset(60, -12), width: 9, height: 9),
          ),
          _gold,
        );
      case MascotAccessory.roundGlasses:
        _stroke(
          canvas,
          Path()..addOval(
            Rect.fromCenter(
              center: const Offset(45, 56),
              width: 28,
              height: 28,
            ),
          ),
          _ink,
          3,
        );
        _stroke(
          canvas,
          Path()..addOval(
            Rect.fromCenter(
              center: const Offset(75, 56),
              width: 28,
              height: 28,
            ),
          ),
          _ink,
          3,
        );
        _stroke(
          canvas,
          Path()
            ..moveTo(59, 56)
            ..lineTo(61, 56),
          _ink,
          3,
        );
      case MascotAccessory.sunglasses:
        _fill(
          canvas,
          Path()..addRRect(
            RRect.fromLTRBR(30, 46, 58, 64, const Radius.circular(6)),
          ),
          _ink,
        );
        _fill(
          canvas,
          Path()..addRRect(
            RRect.fromLTRBR(62, 46, 90, 64, const Radius.circular(6)),
          ),
          _ink,
        );
        _stroke(
          canvas,
          Path()
            ..moveTo(58, 52)
            ..lineTo(62, 52),
          _ink,
          3,
        );
      case MascotAccessory.lightningGoggles:
        _fill(
          canvas,
          Path()..addRRect(
            RRect.fromLTRBR(16, 50, 104, 58, const Radius.circular(4)),
          ),
          _gold,
        );
        _stroke(
          canvas,
          Path()..addOval(
            Rect.fromCenter(
              center: const Offset(45, 56),
              width: 26,
              height: 22,
            ),
          ),
          _goldDark,
          4,
        );
        _stroke(
          canvas,
          Path()..addOval(
            Rect.fromCenter(
              center: const Offset(75, 56),
              width: 26,
              height: 22,
            ),
          ),
          _goldDark,
          4,
        );
      case MascotAccessory.bowTie:
        _fill(
          canvas,
          _triangle(
            const Offset(60, 88),
            const Offset(44, 80),
            const Offset(44, 96),
          ),
          _red,
        );
        _fill(
          canvas,
          _triangle(
            const Offset(60, 88),
            const Offset(76, 80),
            const Offset(76, 96),
          ),
          _red,
        );
      case MascotAccessory.scarf:
        _fill(
          canvas,
          Path()..addRRect(
            RRect.fromLTRBR(26, 82, 94, 92, const Radius.circular(5)),
          ),
          _green,
        );
        _fill(
          canvas,
          Path()..addRRect(
            RRect.fromLTRBR(72, 86, 82, 108, const Radius.circular(4)),
          ),
          _green,
        );
      case MascotAccessory.medal:
        _stroke(
          canvas,
          Path()
            ..moveTo(48, 80)
            ..lineTo(60, 96)
            ..lineTo(72, 80),
          _blue,
          4,
        );
        _fill(
          canvas,
          Path()..addOval(
            Rect.fromCenter(
              center: const Offset(60, 100),
              width: 14,
              height: 14,
            ),
          ),
          _gold,
        );
      case MascotAccessory.cape:
        _fill(canvas, _capeShape(), _red);
      case MascotAccessory.goldenCape:
        _fill(canvas, _capeShape(), _gold);
      case MascotAccessory.backpack:
        _fill(
          canvas,
          Path()..addRRect(
            RRect.fromLTRBR(88, 46, 114, 96, const Radius.circular(8)),
          ),
          _brown,
        );
      case MascotAccessory.wings:
        _fill(
          canvas,
          Path()..addOval(
            Rect.fromCenter(center: const Offset(8, 54), width: 30, height: 44),
          ),
          _white,
        );
        _fill(
          canvas,
          Path()..addOval(
            Rect.fromCenter(
              center: const Offset(112, 54),
              width: 30,
              height: 44,
            ),
          ),
          _white,
        );
    }
  }

  static Path _capeShape() {
    return Path()
      ..moveTo(26, 40)
      ..lineTo(94, 40)
      ..lineTo(112, 112)
      ..lineTo(8, 112)
      ..close();
  }

  static Path _zigzagCrown() {
    return Path()
      ..moveTo(34, 26)
      ..lineTo(34, 2)
      ..lineTo(47, 14)
      ..lineTo(60, -2)
      ..lineTo(73, 14)
      ..lineTo(86, 2)
      ..lineTo(86, 26)
      ..close();
  }

  static Path _triangle(Offset a, Offset b, Offset c) {
    return Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
  }

  static void _fill(Canvas canvas, Path path, Color color) {
    canvas.drawPath(path, Paint()..color = color);
  }

  static void _stroke(Canvas canvas, Path path, Color color, double width) {
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }
}
