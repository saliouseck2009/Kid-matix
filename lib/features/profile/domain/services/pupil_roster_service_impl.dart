import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/entities/pupil_draft.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';
import 'package:kid_matix/features/profile/domain/usecases/delete_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/reset_progress_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';

/// [PupilRosterService] over the stored profiles.
///
/// New pupils get the free avatars in turn, with a color that changes
/// every 12 pupils, so the 60 pupils of a full class all look different;
/// each pupil can change them afterwards like any player.
final class PupilRosterServiceImpl implements PupilRosterService {
  /// Creates the service.
  const PupilRosterServiceImpl({
    required this._repository,
    required this._selectProfile,
    required this._resetProgress,
    required this._deleteProfile,
    required this._clock,
  });

  final ProfileRepository _repository;
  final SelectProfileUseCase _selectProfile;
  final ResetProgressUseCase _resetProgress;
  final DeleteProfileUseCase _deleteProfile;
  final Clock _clock;

  @override
  Future<DataState<List<PlayerIdentity>>> readPupils({
    required String classroomId,
  }) async {
    return switch (await _repository.getPupils(classroomId: classroomId)) {
      DataSuccess<List<ProfileEntity>>(:final data) =>
        DataSuccess<List<PlayerIdentity>>(data.map(_identityOf).toList()),
      DataFailed<List<ProfileEntity>>(:final exception) =>
        DataFailed<List<PlayerIdentity>>(exception),
    };
  }

  @override
  Future<DataState<String?>> readClassroomOf({
    required String profileId,
  }) async {
    return switch (await _repository.getProfile(profileId: profileId)) {
      DataSuccess<ProfileEntity>(:final data) => DataSuccess<String?>(
        data.classroomId,
      ),
      DataFailed<ProfileEntity>(:final exception) => DataFailed<String?>(
        exception,
      ),
    };
  }

  @override
  List<String> findUnusableNicknames(List<String> nicknames) {
    final Set<String> seen = <String>{};
    return <String>[
      for (final String nickname in nicknames)
        if (NicknameRules.validate(nickname) != null ||
            !seen.add(NicknameRules.normalize(nickname)))
          nickname,
    ];
  }

  @override
  Future<DataState<int>> addPupils({
    required String classroomId,
    required List<PupilDraft> pupils,
  }) async {
    final List<String> nicknames = pupils
        .map((PupilDraft pupil) => pupil.nickname)
        .toList();
    if (findUnusableNicknames(nicknames).isNotEmpty) {
      return const DataFailed<int>(
        ValidationException(message: 'Unusable pupil nickname.'),
      );
    }
    final DataState<List<ProfileEntity>> existing = await _repository.getPupils(
      classroomId: classroomId,
    );
    if (existing case DataFailed<List<ProfileEntity>>(:final exception)) {
      return DataFailed<int>(exception);
    }
    final List<ProfileEntity> current =
        (existing as DataSuccess<List<ProfileEntity>>).data;
    final AppException? problem =
        _findCapacityProblem(current, pupils) ??
        await _findConflict(classroomId, pupils);
    if (problem != null) return DataFailed<int>(problem);
    final int firstIndex = current.length;
    return _repository.createPupils(
      pupils: <ProfileEntity>[
        for (int index = 0; index < pupils.length; index++)
          _profileOf(pupils[index], classroomId, firstIndex + index),
      ],
    );
  }

  @override
  Future<DataState<void>> selectPupil({required String profileId}) async {
    return switch (await _selectProfile(params: profileId)) {
      DataSuccess<ProfileEntity>() => const DataSuccess<void>(null),
      DataFailed<ProfileEntity>(:final exception) => DataFailed<void>(
        exception,
      ),
    };
  }

  @override
  Future<DataState<void>> resetPupil({required String profileId}) {
    return _resetProgress(params: profileId);
  }

  @override
  Future<DataState<void>> removePupil({required String profileId}) {
    return _deleteProfile(params: profileId);
  }

  @override
  Stream<void> watchChanges() => _repository.watchProfileChanges();

  /// A `LimitReachedException` when the new ones of [pupils] would take
  /// the class beyond its maximum; pupils already there do not count.
  static AppException? _findCapacityProblem(
    List<ProfileEntity> current,
    List<PupilDraft> pupils,
  ) {
    final Set<String> currentIds = <String>{
      for (final ProfileEntity profile in current) profile.id,
    };
    final int newCount = pupils
        .where((PupilDraft pupil) => !currentIds.contains(pupil.id))
        .length;
    if (current.length + newCount <= PupilRosterService.maxPupilsPerClass) {
      return null;
    }
    return const LimitReachedException(message: 'Too many pupils.');
  }

  Future<AppException?> _findConflict(
    String classroomId,
    List<PupilDraft> pupils,
  ) async {
    for (final PupilDraft pupil in pupils) {
      final DataState<bool> taken = await _repository.isNicknameTaken(
        nickname: pupil.nickname,
        excludedProfileId: pupil.id,
        classroomId: classroomId,
      );
      switch (taken) {
        case DataFailed<bool>(:final exception):
          return exception;
        case DataSuccess<bool>(data: true):
          return const ConflictException(message: 'Nickname taken in class.');
        case DataSuccess<bool>(data: false):
          continue;
      }
    }
    return null;
  }

  ProfileEntity _profileOf(PupilDraft pupil, String classroomId, int index) {
    final List<ProfileAvatar> avatars = ProfileAvatar.free;
    const List<ProfileColor> colors = ProfileColor.values;
    return ProfileEntity.newPlayer(
      id: pupil.id,
      nickname: NicknameRules.clean(pupil.nickname),
      avatar:
          ProfileAvatar.values.asNameMap()[pupil.avatarKey] ??
          avatars[index % avatars.length],
      color:
          ProfileColor.values.asNameMap()[pupil.colorKey] ??
          colors[(index + index ~/ avatars.length) % colors.length],
      // One millisecond apart, so the class keeps the order of its list.
      createdAt: _clock.now().add(Duration(milliseconds: index)),
      classroomId: classroomId,
    );
  }

  static PlayerIdentity _identityOf(ProfileEntity profile) {
    return PlayerIdentity(
      id: profile.id,
      nickname: profile.nickname,
      avatarKey: profile.avatar.name,
      colorKey: profile.color.name,
    );
  }
}
