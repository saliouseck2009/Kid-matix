import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/entities/pupil_draft.dart';
import 'package:kid_matix/core/error/data_state.dart';

/// The pupils of the classes, as the class mode sees them: ordinary
/// players of the device, attached to a class.
///
/// Implemented by the profile feature, which owns the players. The limit
/// of free players does not apply to pupils, and a pupil's nickname is
/// unique inside their class only.
abstract interface class PupilRosterService {
  /// Most pupils one class holds (owner, 2026-10-20).
  static const int maxPupilsPerClass = 60;

  /// Returns the pupils of [classroomId], oldest first.
  Future<DataState<List<PlayerIdentity>>> readPupils({
    required String classroomId,
  });

  /// Returns the class of the player [profileId], or `null` for a free
  /// player.
  Future<DataState<String?>> readClassroomOf({required String profileId});

  /// Returns the nicknames of [nicknames] that cannot be used: those that
  /// break the nickname rules and those that repeat an earlier one of the
  /// list (ignoring case and accents), in their order.
  List<String> findUnusableNicknames(List<String> nicknames);

  /// Adds [pupils] to [classroomId] in one go, all or nothing; a pupil
  /// whose identifier is already on the device is left as it is, so a
  /// class received twice adds nobody twice. Resolves to how many pupils
  /// were added.
  ///
  /// Fails with a `ValidationException` when a nickname cannot be used
  /// (see [findUnusableNicknames]), with a `ConflictException` when a
  /// nickname is taken in the class, and with a `LimitReachedException`
  /// when the class would hold more than [maxPupilsPerClass] pupils.
  Future<DataState<int>> addPupils({
    required String classroomId,
    required List<PupilDraft> pupils,
  });

  /// Erases the progress of the pupil [profileId] (stars, crowns, XP,
  /// mastery...), as « Réinitialiser » does; the class results stay.
  Future<DataState<void>> resetPupil({required String profileId});

  /// Deletes the pupil [profileId] and everything they own, their class
  /// results included.
  Future<DataState<void>> removePupil({required String profileId});

  /// Makes the pupil [profileId] the active player.
  Future<DataState<void>> selectPupil({required String profileId});

  /// Emits an event each time a player, pupils included, may have
  /// changed.
  Stream<void> watchChanges();
}
