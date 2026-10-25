import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/placement_result_service.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/classroom/data/datasources/assessment_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_tables.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_result_rows.dart';
import 'package:kid_matix/features/classroom/data/models/class_assessment_local_model.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_rules.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_word.dart';
import 'package:sqflite/sqflite.dart';

/// Keeps the result of a pupil in an assessment when they finish its
/// word check, in the transaction that saves the quiz session: the words
/// understood, and the levels of the placement test they took since the
/// assessment was opened (none when they skipped it).
///
/// A word check left midway keeps nothing: the pupil takes the
/// assessment again.
final class AssessmentSessionHook implements SessionSavedHook {
  /// Creates the hook; the services are read at the first session, so
  /// that registering the hook resolves nothing.
  const AssessmentSessionHook({
    required PupilRosterService Function() roster,
    required PlacementResultService Function() placements,
    required this._assessments,
  }) : _readRoster = roster,
       _readPlacements = placements;

  final PupilRosterService Function() _readRoster;
  final PlacementResultService Function() _readPlacements;
  final AssessmentLocalDataSource _assessments;

  @override
  Future<SessionWrite> prepare({required SavedQuizSession session}) async {
    final String? assessmentId = AssessmentRules.assessmentIdOf(
      session.sourceKey,
    );
    if (assessmentId == null || !session.isCompleted) return _nothing;
    final ClassAssessmentLocalModel? assessment = await _assessments
        .getAssessment(assessmentId: assessmentId);
    if (assessment == null ||
        !await _isPupilOf(session.profileId, assessment.classroomId)) {
      return _nothing;
    }
    final DataState<List<DomainPlacement>?> placement = await _readPlacements()
        .readTestTakenSince(
          profileId: session.profileId,
          since: DateTime.fromMillisecondsSinceEpoch(assessment.openedAt),
        );
    if (placement case DataFailed<List<DomainPlacement>?>(:final exception)) {
      throw exception;
    }
    final AssessmentResultRows rows = AssessmentResultMapper.rowsOf(
      resultOf(
        session,
        assessmentId,
        (placement as DataSuccess<List<DomainPlacement>?>).data ??
            const <DomainPlacement>[],
      ),
      updatedAt: session.endedAt,
    );
    return (Transaction transaction) async {
      final bool isNew = await _assessments.insertResultWith(transaction, rows);
      return isNew
          ? const <String>[ClassroomTables.assessmentResult]
          : const <String>[];
    };
  }

  /// The result of the word check [session] of [assessmentId], with the
  /// [levels] of the placement test: the first answer about each word
  /// decides whether it is understood, second chances left out.
  static AssessmentResult resultOf(
    SavedQuizSession session,
    String assessmentId,
    List<DomainPlacement> levels,
  ) {
    final Map<String, bool> firstAnswers = <String, bool>{};
    for (final SavedAnswer answer in session.answers) {
      if (answer.isRetry) continue;
      firstAnswers.putIfAbsent(answer.itemKey, () => answer.isCorrect);
    }
    return AssessmentResult(
      assessmentId: assessmentId,
      pupilId: session.profileId,
      takenAt: session.endedAt,
      levels: levels,
      words: <AssessmentWord>[
        for (final MapEntry<String, bool> entry in firstAnswers.entries)
          AssessmentWord(itemKey: entry.key, isUnderstood: entry.value),
      ],
    );
  }

  Future<bool> _isPupilOf(String profileId, String classroomId) async {
    final DataState<String?> classroom = await _readRoster().readClassroomOf(
      profileId: profileId,
    );
    if (classroom case DataFailed<String?>(:final exception)) throw exception;
    return (classroom as DataSuccess<String?>).data == classroomId;
  }

  static Future<List<String>> _nothing(Transaction transaction) async {
    return const <String>[];
  }
}
