import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/arrow_painter.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/bar_painter.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/items_painter.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/mystery_painter.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/people_painter.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/pie_painter.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/steps_painter.dart';
import 'package:kid_matix/core/widgets/word_picture/word_scene.dart';

/// Draws a scene of simple shapes: the provisional drawing of a math
/// word. It keeps the proportions of its design size, and gives each
/// element of the row to the helper of its kind (`painters/`).
class WordPicturePainter extends CustomPainter {
  /// Creates the painter of [scene].
  WordPicturePainter({required this.scene});

  /// Width of the drawing in design units.
  static const double designWidth = 240;

  /// Height of the drawing in design units.
  static const double designHeight = 140;

  /// Ratio of the drawing, width over height.
  static const double aspectRatio = designWidth / designHeight;

  static const double _padding = 6;

  /// The row of elements drawn.
  final List<SceneElement> scene;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / designWidth, size.height / designHeight);
    final double totalWeight = scene.fold(
      0,
      (double sum, SceneElement element) => sum + element.weight,
    );
    double left = 0;
    for (final SceneElement element in scene) {
      final double width = designWidth * element.weight / totalWeight;
      final Rect cell = Rect.fromLTWH(
        left,
        0,
        width,
        designHeight,
      ).deflate(_padding);
      _paintElement(canvas, cell, element);
      left += width;
    }
    canvas.restore();
  }

  void _paintElement(Canvas canvas, Rect cell, SceneElement element) {
    switch (element) {
      case SceneItems():
        ItemsPainter.paint(canvas, cell, element);
      case SceneArrow():
        ArrowPainter.paint(canvas, cell, element.direction);
      case SceneBar():
        BarPainter.paint(canvas, cell, element);
      case ScenePie():
        PiePainter.paint(canvas, cell, element);
      case ScenePeople():
        PeoplePainter.paint(canvas, cell, element.count);
      case SceneMystery():
        MysteryPainter.paint(canvas, cell);
      case SceneSteps():
        StepsPainter.paint(canvas, cell, element);
    }
  }

  @override
  bool shouldRepaint(WordPicturePainter oldDelegate) {
    return !identical(oldDelegate.scene, scene);
  }
}
