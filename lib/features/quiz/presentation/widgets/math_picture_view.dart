import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/math_picture_labels.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/number_line_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/objects_painter.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/ten_bundles_painter.dart';

/// The drawing of a question or of a help card: objects to count, bundles
/// of ten, or a number line, with its label for screen readers.
class MathPictureView extends StatelessWidget {
  /// Creates the view of [picture].
  const MathPictureView({
    required this.picture,
    this.isSolved = false,
    this.blankText,
    this.blankColor,
    super.key,
  });

  /// Drawing to show.
  final MathPicture picture;

  /// Whether the drawing shows its answer, on a help card: its label then
  /// tells how many objects there are.
  final bool isSolved;

  /// What the player typed for the hidden number of a line, or `null`.
  final String? blankText;

  /// Color of [blankText].
  final Color? blankColor;

  @override
  Widget build(BuildContext context) {
    final String label = MathPictureLabels(context.l10n).describe(
      picture,
      isSolved: isSolved,
      blankText: blankText,
    );
    return Semantics(
      label: label,
      image: true,
      excludeSemantics: true,
      child: switch (picture) {
        ObjectsPicture(:final int count) => _ScaledDrawing.objects(
          ObjectsPainter(
            count: count,
            frameColor: context.palette.tint,
            slotColor: context.palette.softBorder,
          ),
        ),
        TenBundlesPicture(:final int tens, :final int ones) =>
          _ScaledDrawing.bundles(TenBundlesPainter(tens: tens, ones: ones)),
        final NumberLinePicture line => NumberLineView(
          line: line,
          blankText: blankText,
          blankColor: blankColor,
        ),
      },
    );
  }
}

/// A drawing scaled to the room it gets, keeping its proportions, at
/// most [_maxScale] times its design size.
class _ScaledDrawing extends StatelessWidget {
  _ScaledDrawing.objects(ObjectsPainter this.painter)
    : design = painter.designSize;

  _ScaledDrawing.bundles(TenBundlesPainter this.painter)
    : design = painter.designSize;

  static const double _maxScale = 1.6;

  final CustomPainter painter;
  final Size design;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: design.width * _maxScale,
        maxHeight: design.height * _maxScale,
      ),
      child: AspectRatio(
        aspectRatio: design.width / design.height,
        child: CustomPaint(painter: painter),
      ),
    );
  }
}
