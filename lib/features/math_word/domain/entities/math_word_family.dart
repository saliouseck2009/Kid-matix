import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word.dart';
import 'package:meta/meta.dart';

/// One family of words, such as the words that take away: a world of the
/// learning path.
@immutable
final class MathWordFamily implements LearningUnit {
  /// Creates the family [slug], the [number]th of the path, with [words].
  MathWordFamily({
    required this.slug,
    required this.number,
    required List<MathWord> words,
  }) : words = List<MathWord>.unmodifiable(words);

  /// Short stable name of the family inside its key, such as `remove`.
  final String slug;

  /// Position of the family on the path, from 1; its texts are chosen by
  /// [slug], never by this position.
  @override
  final int number;

  /// Words of the family, in their natural order.
  final List<MathWord> words;

  /// Stable key, such as `word:remove`; never changes once released.
  @override
  String get key => '${MathWord.keyPrefix}:$slug';

  @override
  List<LearningItem> get items => words;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MathWordFamily && other.slug == slug;

  @override
  int get hashCode => slug.hashCode;

  @override
  String toString() => key;
}
