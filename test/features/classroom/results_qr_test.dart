import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/classroom/data/datasources/qr_results_codec_impl.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_word.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/qr_results.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/make_results_qr_use_case.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/data_state_test_extension.dart';
import 'helpers/classroom_device.dart';

SavedQuizSession _session(String id, String profileId, int answers) {
  return SavedQuizSession(
    id: id,
    profileId: profileId,
    domainId: 'multiplication',
    mode: QuizMode.path,
    isCompleted: true,
    questionCount: answers,
    correctCount: answers,
    endedAt: DateTime(2026, 10, 21, 10),
    duration: const Duration(minutes: 3),
    answers: <SavedAnswer>[
      for (int index = 1; index <= answers; index++)
        SavedAnswer(position: index, itemKey: 'mul:7x$index', isCorrect: true),
    ],
  );
}

void main() {
  setUpAll(sqfliteFfiInit);

  group('QrResultsCodec', () {
    test('reads back what it wrote, results and sessions', () {
      // Arrange
      final QrResults inputResults = QrResults(
        classroomId: 'c1',
        sessions: <PracticeSession>[
          PracticeSession(
            id: 's1',
            pupilId: 'p1',
            classroomId: 'c1',
            domainId: 'addition',
            startedAt: DateTime(2026, 10, 21, 9),
            duration: const Duration(seconds: 95),
            questionCount: 2,
            correctCount: 1,
            answers: const <PracticeAnswer>[
              PracticeAnswer(position: 1, itemKey: 'add:7+8', isCorrect: true),
              PracticeAnswer(
                position: 2,
                itemKey: 'add:7+8',
                isCorrect: false,
                isRetry: true,
              ),
            ],
          ),
        ],
        results: <AssessmentResult>[
          AssessmentResult(
            assessmentId: 'a1',
            pupilId: 'p1',
            takenAt: DateTime(2026, 10, 21, 10),
            levels: const <DomainPlacement>[
              DomainPlacement(domainId: 'division', level: null, skillCount: 1),
            ],
            words: const <AssessmentWord>[
              AssessmentWord(itemKey: 'word:il_reste', isUnderstood: true),
            ],
          ),
        ],
      );
      // Act
      final String actualText = const QrResultsCodecImpl().encode(
        inputResults,
      );
      // Assert
      expect(actualText, startsWith('KMXQ1.'));
      expect(const QrResultsCodecImpl().decode(actualText), inputResults);
    });

    test('refuses other codes and newer versions', () {
      // Arrange
      const QrResultsCodecImpl inputCodec = QrResultsCodecImpl();
      // Act and assert
      expect(
        () => inputCodec.decode('https://example.org'),
        throwsA(
          isA<Object>().having(
            (Object e) => e.toString(),
            'error',
            contains('InvalidFile'),
          ),
        ),
      );
      expect(
        () => inputCodec.decode('KMXQ1.AAAA'),
        throwsA(
          isA<Object>().having(
            (Object e) => e.toString(),
            'error',
            contains('InvalidFile'),
          ),
        ),
      );
      expect(
        () => inputCodec.decode('KMXQ2.AAAA'),
        throwsA(
          isA<Object>().having(
            (Object e) => e.toString(),
            'error',
            contains('UnsupportedVersion'),
          ),
        ),
      );
    });
  });

  group('Results by QR code', () {
    late ClassroomDevice teacher;
    late ClassroomDevice tablet;
    late ClassroomEntity classroom;
    late ClassroomRoster roster;

    setUp(() async {
      teacher = await ClassroomDevice.open('teacher');
      tablet = await ClassroomDevice.open('tablet');
      classroom = (await teacher.createClassroom(
        params: const CreateClassroomParams(
          name: 'CE1',
          nicknames: <String>['Awa', 'Moussa'],
        ),
      )).requireData;
      roster = (await teacher.getRoster(params: classroom.id)).requireData;
      await teacher.assessments.saveAssessment(
        assessment: ClassAssessment(
          id: 'a1',
          classroomId: classroom.id,
          periodLabel: 'Début',
          openedAt: DateTime(2026, 10, 20),
          updatedAt: DateTime(2026, 10, 20),
        ),
      );
      await teacher.exportClassroom(
        params: (classroomId: classroom.id, isFull: true),
      );
      tablet.files.fileToPick = teacher.files.sharedContent;
      (await tablet.importClassroom()).requireData;
    });

    tearDown(() async {
      await teacher.close();
      await tablet.close();
    });

    test('carries new sessions to the teacher once, then nothing', () async {
      // Arrange
      await tablet.play(_session('s1', roster.pupils.first.id, 10));
      await tablet.play(_session('s2', roster.pupils.last.id, 10));
      // Act
      final ResultsQr actualQr = (await tablet.makeQr(
        params: classroom.id,
      )).requireData;
      final ClassroomMergeReport actualMerge = (await teacher.receiveQr(
        params: actualQr.text,
      )).requireData;
      final ClassroomMergeReport actualAgain = (await teacher.receiveQr(
        params: actualQr.text,
      )).requireData;
      await tablet.confirmQr(
        params: (classroomId: classroom.id, sequence: actualQr.sequence),
      );
      // Assert
      expect(actualQr.sessionCount, 2);
      expect(actualQr.text.length, lessThan(QrResults.maxTextLength));
      expect(actualMerge.addedSessionCount, 2);
      expect(actualAgain.addedSessionCount, 0);
      expect(
        (await tablet.makeQr(params: classroom.id)).exceptionOrNull?.code,
        AppErrorCode.validation,
      );
    });

    test('falls back to the file when the results are too many', () async {
      // Arrange: 200 sessions with identifiers that do not compress.
      for (int index = 0; index < 200; index++) {
        await tablet.play(
          _session(
            '${index * 7919 % 104729}-$index',
            roster.pupils.first.id,
            10,
          ),
        );
      }
      // Act
      final AppErrorCode? actual = (await tablet.makeQr(
        params: classroom.id,
      )).exceptionOrNull?.code;
      // Assert
      expect(actual, AppErrorCode.limitReached);
    });

    test('asks for the class file when the class is unknown', () async {
      // Arrange
      final ClassroomDevice stranger = await ClassroomDevice.open('other');
      addTearDown(stranger.close);
      await tablet.play(_session('s1', roster.pupils.first.id, 3));
      final ResultsQr inputQr = (await tablet.makeQr(
        params: classroom.id,
      )).requireData;
      // Act
      final AppErrorCode? actual = (await stranger.receiveQr(
        params: inputQr.text,
      )).exceptionOrNull?.code;
      // Assert
      expect(actual, AppErrorCode.notFound);
    });
  });
}
