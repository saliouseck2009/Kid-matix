import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_file_codec.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_word.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/data_state_test_extension.dart';
import 'helpers/classroom_device.dart';

/// F31-03: the class files (version 2) carry the assessments and their
/// results, merged once, and version 1 files are still read.
void main() {
  late ClassroomDevice teacher;
  late ClassroomDevice tablet;
  late ClassroomEntity classroom;
  late ClassroomRoster roster;

  setUpAll(sqfliteFfiInit);

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
  });

  tearDown(() async {
    await teacher.close();
    await tablet.close();
  });

  Future<void> carry(ClassroomDevice from, ClassroomDevice to) async {
    await from.exportClassroom(
      params: (classroomId: classroom.id, isFull: true),
    );
    to.files.fileToPick = from.files.sharedContent;
    (await to.importClassroom()).requireData;
  }

  test('carry an assessment to the tablets and its results back', () async {
    // Arrange: the teacher opens the assessment and gives the class.
    final ClassAssessment inputAssessment = ClassAssessment(
      id: 'a1',
      classroomId: classroom.id,
      periodLabel: 'Début',
      openedAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
    );
    await teacher.assessments.saveAssessment(assessment: inputAssessment);
    await carry(teacher, tablet);
    final AssessmentResult inputResult = AssessmentResult(
      assessmentId: 'a1',
      pupilId: roster.pupils.first.id,
      takenAt: DateTime(2026, 10, 2),
      levels: const <DomainPlacement>[
        DomainPlacement(domainId: 'numbers', level: 1, skillCount: 1),
        DomainPlacement(domainId: 'division', level: null, skillCount: 1),
      ],
      words: const <AssessmentWord>[
        AssessmentWord(itemKey: 'word:ajouter', isUnderstood: true),
        AssessmentWord(itemKey: 'word:en_plus', isUnderstood: false),
      ],
    );
    await tablet.assessments.addResults(
      results: <AssessmentResult>[inputResult],
    );
    // Act: the tablet sends its results back, twice.
    await carry(tablet, teacher);
    await carry(tablet, teacher);
    // Assert
    expect(
      (await tablet.assessments.getAssessments(
        classroomId: classroom.id,
      )).requireData,
      <ClassAssessment>[inputAssessment],
    );
    expect(
      (await teacher.assessments.getResults(
        classroomId: classroom.id,
      )).requireData,
      <AssessmentResult>[inputResult],
    );
    final Map<String, Object?> actualFile =
        jsonDecode(teacher.files.sharedContent!) as Map<String, Object?>;
    expect(actualFile['version'], 2);
  });

  test('a closed assessment is closed on the other tablet too', () async {
    // Arrange
    final ClassAssessment inputAssessment = ClassAssessment(
      id: 'a1',
      classroomId: classroom.id,
      periodLabel: 'Début',
      openedAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
    );
    await teacher.assessments.saveAssessment(assessment: inputAssessment);
    await carry(teacher, tablet);
    // Act
    await teacher.assessments.saveAssessment(
      assessment: inputAssessment.copyWith(
        closedAt: DateTime(2026, 10, 5),
        updatedAt: DateTime(2026, 10, 5),
      ),
    );
    await carry(teacher, tablet);
    // Assert
    final ClassAssessment actual = (await tablet.assessments.getAssessments(
      classroomId: classroom.id,
    )).requireData.single;
    expect(actual.isOpen, isFalse);
  });

  test('a version 1 file reads as a file without assessments', () async {
    // Arrange
    await teacher.exportClassroom(
      params: (classroomId: classroom.id, isFull: true),
    );
    final Map<String, Object?> inputFile =
        jsonDecode(teacher.files.sharedContent!) as Map<String, Object?>
          ..['version'] = 1
          ..remove('assessments')
          ..remove('assessmentResults');
    // Act
    final ClassroomTransfer actual = const ClassroomFileCodec().decode(
      jsonEncode(inputFile),
    );
    // Assert
    expect(actual.pupils, hasLength(2));
    expect(actual.assessments, isEmpty);
    expect(actual.assessmentResults, isEmpty);
  });

  test('refuses a result of a pupil the file does not carry', () async {
    // Arrange
    final ClassroomTransfer inputTransfer = ClassroomTransfer(
      classroom: classroom,
      pupils: const [],
      assignments: const [],
      sessions: const [],
      assessments: <ClassAssessment>[
        ClassAssessment(
          id: 'a1',
          classroomId: classroom.id,
          periodLabel: 'Début',
          openedAt: DateTime(2026, 10, 1),
          updatedAt: DateTime(2026, 10, 1),
        ),
      ],
      assessmentResults: <AssessmentResult>[
        AssessmentResult(
          assessmentId: 'a1',
          pupilId: 'stranger',
          takenAt: DateTime(2026, 10, 2),
          levels: const [],
          words: const [],
        ),
      ],
    );
    tablet.files.fileToPick = const ClassroomFileCodec().encode(
      inputTransfer,
      exportedAt: DateTime(2026, 10, 2),
      appVersion: '2.0.0',
    );
    // Act
    final AppException? actual =
        (await tablet.importClassroom()).exceptionOrNull;
    // Assert
    expect(actual?.code, AppErrorCode.invalidFile);
  });
}
