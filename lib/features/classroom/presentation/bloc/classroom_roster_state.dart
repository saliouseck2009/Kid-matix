import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:meta/meta.dart';

/// What a list of the pupils of a class shows.
@immutable
sealed class ClassroomRosterState {
  const ClassroomRosterState();
}

/// The class is being read, or a pupil is being opened.
final class ClassroomRosterLoading extends ClassroomRosterState {
  /// Creates the state.
  const ClassroomRosterLoading();
}

/// The class and its pupils, filtered by [query].
final class ClassroomRosterLoaded extends ClassroomRosterState {
  /// Creates the state.
  ClassroomRosterLoaded({required this.roster, this.query = ''})
    : visiblePupils = _filter(roster.pupils, query);

  /// The class and all its pupils.
  final ClassroomRoster roster;

  /// What the pupil typed in the search field.
  final String query;

  /// The pupils whose nickname contains [query], ignoring case.
  final List<PupilEntity> visiblePupils;

  static List<PupilEntity> _filter(List<PupilEntity> pupils, String query) {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) return pupils;
    return pupils
        .where(
          (PupilEntity pupil) => pupil.nickname.toLowerCase().contains(needle),
        )
        .toList();
  }
}

/// The class could not be read or the pupil could not be opened.
final class ClassroomRosterFailure extends ClassroomRosterState {
  /// Creates the state.
  const ClassroomRosterFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
