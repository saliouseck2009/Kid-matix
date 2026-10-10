// Renders the images of the app icon and the launch screen from the
// mascot drawing, into tool/icon/out/. Run it by hand when the mascot
// changes: flutter test tool/icon/render_icon_test.dart
// then: dart run flutter_launcher_icons
// and: dart run flutter_native_splash:create

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/widgets/mascot_painter.dart';

const MascotColors _colors = (
  body: AppColors.yellow,
  feet: AppColors.yellowDepth,
  eye: AppColors.white,
  ink: AppColors.ink,
  badge: AppColors.violet,
  cheek: AppColors.redTint,
);

/// Stage of the mascot on the icon: grown enough to have ears and arms.
const int _iconStage = 3;

Future<void> _render(
  String name, {
  required double size,
  required double mascotShare,
  Color? background,
}) async {
  // The mascot sits low in its box: lift it to center it.
  const double lift = 0.07;
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  if (background != null) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size, size),
      Paint()..color = background,
    );
  }
  final double mascot = size * mascotShare;
  canvas.translate((size - mascot) / 2, (size - mascot) / 2 - mascot * lift);
  const MascotPainter(
    colors: _colors,
    stage: _iconStage,
    mood: MascotMood.happy,
  ).paint(canvas, Size(mascot, mascot));
  final ui.Image image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final ByteData? bytes = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  final File file = File('tool/icon/out/$name');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
}

void main() {
  test('renders the icon and launch images', () async {
    await _render(
      'icon.png',
      size: 1024,
      mascotShare: 0.92,
      background: AppColors.violet,
    );
    await _render('icon_foreground.png', size: 1024, mascotShare: 0.72);
    await _render('splash.png', size: 768, mascotShare: 0.9);
  });
}
