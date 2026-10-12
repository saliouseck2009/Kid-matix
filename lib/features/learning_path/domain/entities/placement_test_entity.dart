import 'package:kid_matix/core/quiz/question.dart';
import 'package:meta/meta.dart';

/// The placement test offered to a new player: one question per unit of
/// the domain, in the natural order of the units.
///
/// A right answer opens its unit on the learning path at once.
@immutable
final class PlacementTestEntity {
  /// Creates the test of [domainId] made of [questions].
  PlacementTestEntity({
    required this.domainId,
    required List<PlacementQuestionEntity> questions,
  }) : questions = List<PlacementQuestionEntity>.unmodifiable(questions);

  /// Learning domain, such as `multiplication`.
  final String domainId;

  /// Questions, one per unit.
  final List<PlacementQuestionEntity> questions;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PlacementTestEntity || other.domainId != domainId) {
      return false;
    }
    if (other.questions.length != questions.length) return false;
    for (int index = 0; index < questions.length; index++) {
      if (other.questions[index] != questions[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(domainId, Object.hashAll(questions));
}

/// One question of the placement test, about one fact of its unit.
@immutable
final class PlacementQuestionEntity {
  /// Creates the question [question] of the unit numbered [unitNumber].
  const PlacementQuestionEntity({
    required this.unitNumber,
    required this.question,
  });

  /// Number of the unit, such as 7 for the table of 7.
  final int unitNumber;

  /// Question asked, answered on the keypad.
  final Question question;

  /// Key of the unit the question opens, such as `mul:7`.
  String get unitKey => question.unitKey;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlacementQuestionEntity &&
            other.unitNumber == unitNumber &&
            other.question == question;
  }

  @override
  int get hashCode => Object.hash(unitNumber, question);
}
