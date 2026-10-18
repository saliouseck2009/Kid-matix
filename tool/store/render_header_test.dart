// Renders the App Store product page header asset from the mascot drawing,
// into docs/store/assets/. Run it by hand when the mascot or the brand
// colors change:
//   flutter test tool/store/render_header_test.dart
//   cd docs/store/assets
//   ffmpeg -y -i app-store-header.png -pix_fmt rgb24 rgb.png
//   mv rgb.png app-store-header.png
// The second step drops the alpha channel: App Store Connect refuses a
// header asset that carries one.
//
// Size and rules come from the creative assets specifications of App Store
// Connect: a 16:9 asset of 5244 x 2950 px, PNG, no transparency, usable for
// both the product page header and the search results placement. The art
// that matters stays inside a safe area of 1402 x 962 px, centered
// horizontally and above the vertical center, because every other
// placement crops to it.

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/theme/app_text_theme.dart';
import 'package:kid_matix/core/widgets/mascot_painter.dart';

const double _width = 5244;
const double _height = 2950;

/// Center of the safe area: horizontally centered, above the vertical center.
const Offset _safeCenter = Offset(_width / 2, _height * 0.4);
const Size _safeSize = Size(1402, 962);

const MascotColors _colors = (
  body: AppColors.yellow,
  feet: AppColors.yellowDepth,
  eye: AppColors.white,
  ink: AppColors.ink,
  badge: AppColors.violet,
  cheek: AppColors.redTint,
);

/// Fully grown mascot: it has ears, arms, cheeks and a star.
const int _mascotStage = 5;

/// The fact shown in the bubble: digits and operators only, so the asset
/// needs no translation.
const String _fact = '7 × 8 = 56';

/// Shapes scattered over the background.
enum _Symbol { times, plus, equals, divide, star }

void main() {
  testWidgets('renders the App Store header asset', (
    WidgetTester tester,
  ) async {
    // The rendering and the font loading are real asynchronous engine work:
    // they never complete inside the fake async zone of the test.
    await tester.runAsync(() async {
      await _loadDisplayFont();
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      _paintBackground(canvas);
      _paintScatteredSymbols(canvas);
      _paintStars(canvas);
      _paintMascot(canvas);
      _paintFactBubble(canvas);
      final ui.Image image = await recorder.endRecording().toImage(
        _width.toInt(),
        _height.toInt(),
      );
      final ByteData? bytes = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final File file = File('docs/store/assets/app-store-header.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    });
  });
}

Future<void> _loadDisplayFont() async {
  final Uint8List data = await File(
    'assets/fonts/Fredoka-Variable.ttf',
  ).readAsBytes();
  final FontLoader loader = FontLoader(AppTextTheme.displayFontFamily)
    ..addFont(Future<ByteData>.value(ByteData.view(data.buffer)));
  await loader.load();
}

/// Violet ground, lit behind the mascot and darker towards the corners.
void _paintBackground(Canvas canvas) {
  const Rect full = Rect.fromLTWH(0, 0, _width, _height);
  canvas.drawRect(
    full,
    Paint()
      ..shader = ui.Gradient.radial(
        _safeCenter,
        _width * 0.62,
        <Color>[
          const Color(0xFF7A5CFF),
          AppColors.violet,
          AppColors.violetDepth,
        ],
        <double>[0, 0.42, 1],
      ),
  );
}

/// Math symbols spread over the whole canvas, so that any crop keeps some.
/// None of them lands near the safe area: the center stays clean.
void _paintScatteredSymbols(Canvas canvas) {
  final math.Random random = math.Random(42);
  final Rect keepClear = Rect.fromCenter(
    center: _safeCenter,
    width: _safeSize.width + 760,
    height: _safeSize.height + 560,
  );
  for (int i = 0; i < 110; i++) {
    final Offset center = Offset(
      random.nextDouble() * _width,
      random.nextDouble() * _height,
    );
    if (keepClear.contains(center)) {
      continue;
    }
    final _Symbol symbol =
        _Symbol.values[random.nextInt(_Symbol.values.length)];
    final double size = 100 + random.nextDouble() * 130;
    final double opacity = 0.05 + random.nextDouble() * 0.045;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((random.nextDouble() - 0.5) * 0.7);
    _paintSymbol(
      canvas,
      symbol,
      size,
      AppColors.white.withValues(alpha: opacity),
    );
    canvas.restore();
  }
}

/// Draws [symbol] centered on the origin, inside a box of [size].
void _paintSymbol(Canvas canvas, _Symbol symbol, double size, Color color) {
  final double half = size / 2;
  final Paint paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.17
    ..strokeCap = StrokeCap.round;
  switch (symbol) {
    case _Symbol.times:
      canvas
        ..drawLine(Offset(-half, -half), Offset(half, half), paint)
        ..drawLine(Offset(-half, half), Offset(half, -half), paint);
    case _Symbol.plus:
      canvas
        ..drawLine(Offset(-half, 0), Offset(half, 0), paint)
        ..drawLine(Offset(0, -half), Offset(0, half), paint);
    case _Symbol.equals:
      canvas
        ..drawLine(
          Offset(-half, -half * 0.42),
          Offset(half, -half * 0.42),
          paint,
        )
        ..drawLine(
          Offset(-half, half * 0.42),
          Offset(half, half * 0.42),
          paint,
        );
    case _Symbol.divide:
      final Paint dot = Paint()..color = color;
      canvas
        ..drawLine(Offset(-half, 0), Offset(half, 0), paint)
        ..drawCircle(Offset(0, -half * 0.62), size * 0.1, dot)
        ..drawCircle(Offset(0, half * 0.62), size * 0.1, dot);
    case _Symbol.star:
      canvas.drawPath(_starPath(half), Paint()..color = color);
  }
}

/// Five-pointed star of radius [radius], centered on the origin.
Path _starPath(double radius) {
  final Path path = Path();
  const int points = 5;
  final double innerRadius = radius * 0.46;
  for (int i = 0; i < points * 2; i++) {
    final double angle = -math.pi / 2 + i * math.pi / points;
    final double r = i.isEven ? radius : innerRadius;
    final Offset point = Offset(math.cos(angle) * r, math.sin(angle) * r);
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path..close();
}

/// Center of the mascot inside the safe area: it stands on the left half,
/// the bubble it speaks sits on the right half.
const double _mascotSize = 840;
const double _mascotCenterX = _width / 2 - 478;
const double _mascotBottom = 1660;

/// The mascot, standing on its shadow, on the left of the safe area.
void _paintMascot(Canvas canvas) {
  canvas.drawOval(
    Rect.fromCenter(
      center: const Offset(_mascotCenterX, _mascotBottom - _mascotSize * 0.05),
      width: _mascotSize * 0.78,
      height: _mascotSize * 0.13,
    ),
    Paint()
      ..color = AppColors.violetDepth.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
  );
  canvas.save();
  canvas.translate(
    _mascotCenterX - _mascotSize / 2,
    _mascotBottom - _mascotSize,
  );
  const MascotPainter(
    colors: _colors,
    stage: _mascotStage,
    mood: MascotMood.happy,
  ).paint(canvas, const Size(_mascotSize, _mascotSize));
  canvas.restore();
}

/// Three reward stars arching over the mascot.
void _paintStars(Canvas canvas) {
  const List<Offset> centers = <Offset>[
    Offset(_mascotCenterX - 314, _mascotBottom - _mascotSize - 48),
    Offset(_mascotCenterX - 160, _mascotBottom - _mascotSize - 165),
    Offset(_mascotCenterX + 14, _mascotBottom - _mascotSize - 203),
  ];
  const List<double> radii = <double>[46, 62, 38];
  for (int i = 0; i < centers.length; i++) {
    canvas.save();
    canvas.translate(centers[i].dx, centers[i].dy);
    canvas.rotate(-0.18 + i * 0.16);
    canvas.drawPath(_starPath(radii[i]), Paint()..color = AppColors.yellow);
    canvas.restore();
  }
}

/// White bubble on the right of the mascot, holding the multiplication fact.
void _paintFactBubble(Canvas canvas) {
  final TextPainter painter = TextPainter(
    text: const TextSpan(
      text: _fact,
      style: TextStyle(
        fontFamily: AppTextTheme.displayFontFamily,
        fontSize: 168,
        height: 1.15,
        fontWeight: FontWeight.w600,
        fontVariations: <ui.FontVariation>[ui.FontVariation('wght', 600)],
        color: AppColors.ink,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  const double paddingX = 96;
  const double paddingY = 60;
  const double centerY = _mascotBottom - _mascotSize * 0.62;
  final Rect bubble = Rect.fromLTWH(
    _mascotCenterX + _mascotSize * 0.47,
    centerY - (painter.height + paddingY * 2) / 2,
    painter.width + paddingX * 2,
    painter.height + paddingY * 2,
  );
  final Path tail = Path()
    ..moveTo(bubble.left + 10, centerY - 76)
    ..lineTo(bubble.left + 10, centerY + 76)
    ..lineTo(bubble.left - 118, centerY + 18)
    ..close();
  final Path shape = Path.combine(
    PathOperation.union,
    Path()
      ..addRRect(RRect.fromRectAndRadius(bubble, const Radius.circular(84))),
    tail,
  );
  canvas
    ..drawPath(
      shape.shift(const Offset(0, 20)),
      Paint()
        ..color = AppColors.violetDepth.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    )
    ..drawPath(shape, Paint()..color = AppColors.white);
  painter.paint(
    canvas,
    Offset(
      bubble.center.dx - painter.width / 2,
      bubble.center.dy - painter.height / 2,
    ),
  );
}
