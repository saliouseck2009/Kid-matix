import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/number/domain/entities/number_item.dart';
import 'package:meta/meta.dart';

/// One unit of the numbers up to 100, such as "Compter jusqu'à 10": a
/// world of the learning path.
@immutable
final class NumbersUnit implements LearningUnit {
  /// Creates the unit [slug], the [number]th of the path, with [items].
  NumbersUnit({
    required this.slug,
    required this.number,
    required List<NumberItem> items,
  }) : numberItems = List<NumberItem>.unmodifiable(items);

  /// Short stable name of the unit inside its key, such as `count10`.
  final String slug;

  /// Position of the unit on the path, from 1; names its texts.
  @override
  final int number;

  /// Items of the unit, in their natural order.
  final List<NumberItem> numberItems;

  /// Stable key, such as `num:count10`; never changes once released.
  @override
  String get key => '${NumberItem.keyPrefix}:$slug';

  @override
  List<LearningItem> get items => numberItems;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NumbersUnit && other.slug == slug;

  @override
  int get hashCode => slug.hashCode;

  @override
  String toString() => key;
}
