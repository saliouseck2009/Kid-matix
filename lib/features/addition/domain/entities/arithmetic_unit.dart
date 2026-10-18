import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/addition/domain/entities/arithmetic_fact.dart';
import 'package:meta/meta.dart';

/// The visual aid of a unit, drawn on the help card of a fact missed
/// twice.
enum ArithmeticAid {
  /// A number line: the path from one number to the other, through the
  /// ten when the operation crosses it.
  numberLine,

  /// A number line from the number to 10: what is missing to make ten.
  completeToTen,

  /// Bundles of ten and loose sticks showing the result.
  tenBundles,
}

/// One unit of the additions and subtractions, such as "Additions jusqu'à
/// 20": a world of the learning path.
@immutable
final class ArithmeticUnit implements LearningUnit {
  /// Creates the unit [slug], the [number]th of the path, with [facts].
  ArithmeticUnit({
    required this.slug,
    required this.number,
    required this.aid,
    required List<ArithmeticFact> facts,
  }) : facts = List<ArithmeticFact>.unmodifiable(facts);

  /// Prefix of every unit key; the facts have their own, `add` and `sub`.
  static const String keyPrefix = 'addsub';

  /// Short stable name of the unit inside its key, such as `add20`.
  final String slug;

  /// Position of the unit on the path, from 1; its texts are chosen by
  /// [slug], never by this position.
  @override
  final int number;

  /// Visual aid of the unit's help cards.
  final ArithmeticAid aid;

  /// Facts of the unit, in their natural order.
  final List<ArithmeticFact> facts;

  /// Stable key, such as `addsub:add20`; never changes once released.
  @override
  String get key => '$keyPrefix:$slug';

  @override
  List<LearningItem> get items => facts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ArithmeticUnit && other.slug == slug;

  @override
  int get hashCode => slug.hashCode;

  @override
  String toString() => key;
}
