import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_word.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/domain_progress.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';
import 'package:kid_matix/features/classroom/domain/services/class_progress_calculator.dart';

final DateTime _start = DateTime(2026, 10, 1);
final DateTime _end = DateTime(2026, 11, 1);

final ClassroomEntity _classroom = ClassroomEntity(
  id: 'c1',
  name: 'CE1',
  weeklyGoal: 1000,
  createdAt: _start,
  updatedAt: _start,
);

PupilEntity _pupil(String id) {
  return PupilEntity(
    classroomId: 'c1',
    player: PlayerIdentity(
      id: id,
      nickname: 'Awa $id',
      avatarKey: 'avatar1',
      colorKey: 'violet',
    ),
  );
}

AssessmentResult _result(
  String assessmentId,
  String pupilId, {
  required int numbers,
  required int words,
}) {
  return AssessmentResult(
    assessmentId: assessmentId,
    pupilId: pupilId,
    takenAt: assessmentId == 'a1' ? _start : _end,
    levels: <DomainPlacement>[
      DomainPlacement(domainId: 'numbers', level: numbers, skillCount: 1),
      const DomainPlacement(domainId: 'division', level: null, skillCount: 1),
    ],
    words: <AssessmentWord>[
      for (int index = 0; index < 4; index++)
        AssessmentWord(itemKey: 'word:$index', isUnderstood: index < words),
    ],
  );
}

/// A session of [pupilId] on [day] answering `add:1+1` right [right] times.
PracticeSession _session(String id, String pupilId, DateTime day, int right) {
  return PracticeSession(
    id: id,
    pupilId: pupilId,
    classroomId: 'c1',
    domainId: 'addition',
    startedAt: day,
    duration: const Duration(minutes: 5),
    questionCount: right,
    correctCount: right,
    answers: <PracticeAnswer>[
      for (int index = 1; index <= right; index++)
        PracticeAnswer(position: index, itemKey: 'add:1+1', isCorrect: true),
    ],
  );
}

void main() {
  test('compares two periods per pupil and for the class', () {
    // Arrange
    final AssessmentPeriod inputFrom = AssessmentPeriod(
      key: 'debut',
      label: 'Début',
      startedAt: _start,
      assessmentIds: const <String>['a1'],
    );
    final AssessmentPeriod inputTo = AssessmentPeriod(
      key: 'fin',
      label: 'Fin',
      startedAt: _end,
      assessmentIds: const <String>['a2'],
    );
    // Act
    final ClassProgressReport actual = ClassProgressCalculator.compute((
      classroom: _classroom,
      pupils: <PupilEntity>[_pupil('p1'), _pupil('p2'), _pupil('p3')],
      from: inputFrom,
      to: inputTo,
      results: <AssessmentResult>[
        _result('a1', 'p1', numbers: 0, words: 1),
        _result('a1', 'p2', numbers: 1, words: 2),
        _result('a2', 'p1', numbers: 1, words: 3),
        _result('a2', 'p2', numbers: 1, words: 2),
      ],
      sessions: <PracticeSession>[
        _session('before', 'p1', DateTime(2026, 9, 20), 1),
        _session('during', 'p1', DateTime(2026, 10, 10), 3),
        _session('after', 'p2', DateTime(2026, 11, 2), 3),
      ],
      generatedAt: _end,
    ));
    // Assert: the class.
    final DomainProgress actualNumbers = actual.domains.single;
    expect(actualNumbers.domainId, 'numbers');
    expect(actualNumbers.averageFrom, 0.5);
    expect(actualNumbers.averageTo, 1);
    expect(actualNumbers.progressedCount, 1);
    expect(actualNumbers.assessedToCount, 2);
    expect(actual.wordsFrom, closeTo(0.375, 1e-9));
    expect(actual.wordsTo, closeTo(0.625, 1e-9));
    expect(actual.practiceTime, const Duration(minutes: 5));
    expect(actual.sessionCount, 1);
    expect(actual.acquiredItemCount, 1);
    // Assert: each pupil, in the class list order.
    final List<PupilReportRow> actualRows = actual.pupils;
    expect(actualRows.map((PupilReportRow r) => r.number), <int>[1, 2, 3]);
    expect(actualRows.first.nickname, 'Awa p1');
    expect(actualRows.first.levelsFrom['numbers']?.level, 0);
    expect(actualRows.first.levelsTo['numbers']?.level, 1);
    expect(actualRows.first.wordsTo, (understood: 3, asked: 4));
    expect(actualRows.first.acquiredItemCount, 1);
    expect(actualRows[2].levelsTo, isEmpty);
    expect(actualRows[2].wordsTo, isNull);
  });

  test('reports one period alone with the practice before it', () {
    // Act
    final ClassProgressReport actual = ClassProgressCalculator.compute((
      classroom: _classroom,
      pupils: <PupilEntity>[_pupil('p1')],
      from: null,
      to: AssessmentPeriod(
        key: 'debut',
        label: 'Début',
        startedAt: _start,
        assessmentIds: const <String>['a1'],
      ),
      results: <AssessmentResult>[_result('a1', 'p1', numbers: 1, words: 4)],
      sessions: <PracticeSession>[
        _session('before', 'p1', DateTime(2026, 9, 20), 3),
      ],
      generatedAt: _start,
    ));
    // Assert
    expect(actual.domains.single.averageFrom, isNull);
    expect(actual.domains.single.averageTo, 1);
    expect(actual.wordsTo, 1);
    expect(actual.sessionCount, 1);
    expect(actual.acquiredItemCount, 1);
  });
}
