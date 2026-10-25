import 'package:kid_matix/core/entities/pupil_draft.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';

/// Adds the pupils of a class file one by one: a pupil already on the
/// tablet (same id) is skipped; a new pupil whose nickname another pupil
/// of the class already has becomes « Moussa 2 », « Moussa 3 »...
final class PupilMerge {
  PupilMerge._(this.addedCount, this.renamedNicknames);

  /// Numbers tried after a taken nickname: « Moussa 2 » to « Moussa 9 ».
  static const int _lastSuffix = 9;

  /// How many pupils were new on the tablet.
  final int addedCount;

  /// The new nicknames of the renamed pupils.
  final List<String> renamedNicknames;

  /// Adds [pupils] to [classroomId] through [roster].
  static Future<DataState<PupilMerge>> run({
    required PupilRosterService roster,
    required String classroomId,
    required List<PupilEntity> pupils,
  }) async {
    int addedCount = 0;
    final List<String> renamed = <String>[];
    for (final PupilEntity pupil in pupils) {
      final DataState<String?> added = await _addOne(
        roster,
        classroomId,
        pupil,
      );
      switch (added) {
        case DataFailed<String?>(:final exception):
          return DataFailed<PupilMerge>(exception);
        case DataSuccess<String?>(data: null):
          break;
        case DataSuccess<String?>(:final String data):
          addedCount++;
          if (data != pupil.nickname) renamed.add(data);
      }
    }
    return DataSuccess<PupilMerge>(PupilMerge._(addedCount, renamed));
  }

  /// Resolves to the nickname [pupil] was added under, or `null` when the
  /// pupil was already on the tablet.
  static Future<DataState<String?>> _addOne(
    PupilRosterService roster,
    String classroomId,
    PupilEntity pupil,
  ) async {
    for (final String nickname in _candidatesOf(roster, pupil.nickname)) {
      final DataState<int> added = await roster.addPupils(
        classroomId: classroomId,
        pupils: <PupilDraft>[_draftOf(pupil, nickname)],
      );
      switch (added) {
        case DataSuccess<int>(:final data):
          return DataSuccess<String?>(data == 0 ? null : nickname);
        case DataFailed<int>(:final exception)
            when exception.code == AppErrorCode.conflict:
          continue;
        case DataFailed<int>(:final exception):
          return DataFailed<String?>(exception);
      }
    }
    return const DataFailed<String?>(
      ConflictException(message: 'Every nickname taken in the class.'),
    );
  }

  /// The nickname, then « nickname 2 » to « nickname 9 » when they are
  /// valid nicknames (a long one is cut to make room for the number).
  static Iterable<String> _candidatesOf(
    PupilRosterService roster,
    String nickname,
  ) sync* {
    yield nickname;
    for (int suffix = 2; suffix <= _lastSuffix; suffix++) {
      final String candidate = '${_cut(nickname)} $suffix';
      if (roster.findUnusableNicknames(<String>[candidate]).isEmpty) {
        yield candidate;
      }
    }
  }

  // Leaves room for « 2 » within the 12 characters of a nickname.
  static String _cut(String nickname) {
    const int room = 10;
    final List<int> runes = nickname.runes.toList();
    return runes.length <= room
        ? nickname
        : String.fromCharCodes(runes.take(room)).trimRight();
  }

  static PupilDraft _draftOf(PupilEntity pupil, String nickname) {
    return PupilDraft(
      id: pupil.id,
      nickname: nickname,
      avatarKey: pupil.player.avatarKey,
      colorKey: pupil.player.colorKey,
    );
  }
}
