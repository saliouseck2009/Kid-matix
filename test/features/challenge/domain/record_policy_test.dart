import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/domain/services/record_policy.dart';

void main() {
  const RecordPolicy policy = RecordPolicy();
  final DateTime endedAt = DateTime(2026, 10, 10, 18);
  final RecordEntity current = RecordEntity(
    mode: QuizMode.timeAttack,
    bestScore: 18,
    sessionId: 'old',
    achievedAt: DateTime(2026, 10, 9),
  );

  RecordEntity? newRecordOf(int score, {RecordEntity? current}) {
    return policy.newRecordOf(
      mode: QuizMode.timeAttack,
      score: score,
      sessionId: 'new',
      endedAt: endedAt,
      current: current,
    );
  }

  group('RecordPolicy', () {
    test('makes a first time attack with right answers a record', () {
      // Act
      final RecordEntity? actualRecord = newRecordOf(7);
      // Assert
      expect(
        actualRecord,
        RecordEntity(
          mode: QuizMode.timeAttack,
          bestScore: 7,
          sessionId: 'new',
          achievedAt: endedAt,
        ),
      );
    });
    test('beats the record with a higher score and keeps the old one', () {
      // Act
      final RecordEntity? actualRecord = newRecordOf(19, current: current);
      // Assert
      expect(actualRecord?.bestScore, 19);
      expect(actualRecord?.previousBest, 18);
    });
    test('keeps the record when the score only equals it', () {
      // Act & Assert
      expect(newRecordOf(18, current: current), isNull);
      expect(newRecordOf(12, current: current), isNull);
    });
    test('sets no record without a right answer', () {
      // Act & Assert
      expect(newRecordOf(0), isNull);
    });
    test('keeps no record for the other modes', () {
      // Act
      final RecordEntity? actualRecord = policy.newRecordOf(
        mode: QuizMode.freeTraining,
        score: 30,
        sessionId: 'new',
        endedAt: endedAt,
      );
      // Assert
      expect(actualRecord, isNull);
    });
  });
}
