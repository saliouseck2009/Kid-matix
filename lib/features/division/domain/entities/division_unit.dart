import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/division/domain/entities/division_fact.dart';
import 'package:meta/meta.dart';

/// The divisions by one number, such as "Diviser par 7": a world of the
/// learning path, the reverse of a multiplication table.
@immutable
final class DivisionUnit implements LearningUnit {
  /// Creates the unit of [number] with the divisions of `number × 1` to
  /// `number × lastQuotient`.
  DivisionUnit({required this.number, required int lastQuotient})
    : facts = List<DivisionFact>.unmodifiable(
        List<DivisionFact>.generate(
          lastQuotient,
          (int index) => DivisionFact(divisor: number, quotient: index + 1),
        ),
      );

  /// The divisor, from 1 to 12: also the number of the table it reverses.
  @override
  final int number;

  /// Divisions of the unit, quotient 1 first.
  final List<DivisionFact> facts;

  /// Short stable name of the unit inside its key, such as `7`; its texts
  /// are chosen by it.
  String get slug => '$number';

  /// Stable key, `div:7` for the divisions by 7; never changes once
  /// released.
  @override
  String get key => '${DivisionFact.keyPrefix}:$slug';

  @override
  List<LearningItem> get items => facts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DivisionUnit && other.number == number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => key;
}
