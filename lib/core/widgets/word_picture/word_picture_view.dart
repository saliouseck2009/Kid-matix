import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/word_picture/word_picture_painter.dart';
import 'package:kid_matix/core/widgets/word_picture/word_scenes.dart';

/// The drawing of a math word, found by its key. A screen reader says
/// [label], the word, in place of the shapes.
class WordPictureView extends StatelessWidget {
  /// Creates the view of the word [wordKey].
  const WordPictureView({required this.wordKey, this.label, super.key});

  /// Key of the math word, such as `il_reste`.
  final String wordKey;

  /// What a screen reader says; the drawing is skipped when `null`.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final Widget drawing = AspectRatio(
      aspectRatio: WordPicturePainter.aspectRatio,
      child: CustomPaint(
        painter: WordPicturePainter(scene: WordScenes.of(wordKey)),
      ),
    );
    return Semantics(
      label: label,
      image: true,
      excludeSemantics: true,
      child: drawing,
    );
  }
}
