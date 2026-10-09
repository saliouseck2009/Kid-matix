import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_tip.dart';
import 'package:meta/meta.dart';

/// One multiplication table: a world of the learning path.
@immutable
final class MultiplicationTable implements LearningUnit {
  /// Creates the table of [number], with the facts [number] x 1 to
  /// [number] x [lastMultiplier].
  MultiplicationTable({required this.number, required int lastMultiplier})
    : facts = List<MultiplicationFact>.unmodifiable(
        List<MultiplicationFact>.generate(
          lastMultiplier,
          (int index) =>
              MultiplicationFact(table: number, multiplier: index + 1),
        ),
      );

  /// Number of the table, from 1 to 12.
  @override
  final int number;

  /// Facts of the table, multiplier 1 first.
  final List<MultiplicationFact> facts;

  /// Stable key, `mul:7` for the table of 7.
  @override
  String get key => '${MultiplicationFact.keyPrefix}:$number';

  @override
  List<LearningItem> get items => facts;

  /// Tip shown at the discovery stage of the table.
  MultiplicationTip get tip => MultiplicationTip.values[number - 1];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiplicationTable &&
          other.number == number &&
          other.facts.length == facts.length;

  @override
  int get hashCode => Object.hash(number, facts.length);

  @override
  String toString() => key;
}
