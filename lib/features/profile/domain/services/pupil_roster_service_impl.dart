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
    required this._clock,
  });

  final ProfileRepository _repository;
  final SelectProfileUseCase _selectProfile;
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
    final AppException? conflict = await _findConflict(classroomId, pupils);
    if (conflict != null) return DataFailed<int>(conflict);
    final int firstIndex =
        (existing as DataSuccess<List<ProfileEntity>>).data.length;
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
  Stream<void> watchChanges() => _repository.watchProfileChanges();

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
