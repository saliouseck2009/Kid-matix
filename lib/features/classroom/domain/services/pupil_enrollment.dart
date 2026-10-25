import 'package:kid_matix/core/entities/pupil_draft.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';

/// Adds a list of nicknames to a class as new pupils, shared by the
/// creation of a class and the « Ajouter des élèves » of its page.
class PupilEnrollment {
  /// Creates the helper.
  const PupilEnrollment({required this._roster, required this._ids});

  final PupilRosterService _roster;
  final IdGenerator _ids;

  /// The nicknames of [nicknames] that cannot be used: they break the
  /// nickname rules or repeat an earlier one.
  List<String> findUnusableNicknames(List<String> nicknames) {
    return _roster.findUnusableNicknames(nicknames);
  }

  /// Why [nicknames] cannot join a class of [existingCount] pupils, or
  /// `null` when they can.
  ///
  /// A `ValidationException` when there is none or one cannot be used, a
  /// `LimitReachedException` beyond [ClassroomRules.maxPupils].
  AppException? findProblem({
    required List<String> nicknames,
    int existingCount = 0,
  }) {
    if (nicknames.isEmpty) {
      return const ValidationException(message: 'No pupil.');
    }
    if (existingCount + nicknames.length > ClassroomRules.maxPupils) {
      return const LimitReachedException(message: 'Too many pupils.');
    }
    if (findUnusableNicknames(nicknames).isNotEmpty) {
      return const ValidationException(message: 'Unusable nickname.');
    }
    return null;
  }

  /// Adds [nicknames] to [classroomId], each with a new identifier;
  /// resolves to how many pupils were added.
  Future<DataState<int>> enroll({
    required String classroomId,
    required List<String> nicknames,
  }) {
    return _roster.addPupils(
      classroomId: classroomId,
      pupils: <PupilDraft>[
        for (final String nickname in nicknames)
          PupilDraft(id: _ids.generateId(), nickname: nickname),
      ],
    );
  }
}
