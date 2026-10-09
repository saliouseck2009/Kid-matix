import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/profile/data/datasources/active_profile_local_data_source.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_table.dart';
import 'package:kid_matix/features/profile/data/models/profile_local_model.dart';
import 'package:kid_matix/features/profile/data/models/profile_settings_local_model.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [ProfileRepository] over the local database and the device preferences.
///
/// After each write, the choice of the active player included, it tells the
/// [TableChangeBus] that the `profile` table changed, so the screens and the
/// session watching it reload.
final class ProfileRepositoryImpl implements ProfileRepository {
  /// Creates the repository.
  const ProfileRepositoryImpl({
    required this._profiles,
    required this._activeProfile,
    required this._clock,
    required this._changeBus,
  });

  static const String _logName = 'profile';

  final ProfileLocalDataSource _profiles;
  final ActiveProfileLocalDataSource _activeProfile;
  final Clock _clock;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<List<ProfileEntity>>> getProfiles() {
    return _guard(() async {
      final List<ProfileLocalModel> models = await _profiles.getProfiles();
      return models.map((ProfileLocalModel model) => model.toEntity()).toList();
    });
  }

  @override
  Future<DataState<ProfileEntity>> getProfile({required String profileId}) {
    return _guard(() async => (await _readProfile(profileId)).toEntity());
  }

  @override
  Future<DataState<int>> countProfiles() => _guard(_profiles.countProfiles);

  @override
  Future<DataState<bool>> isNicknameTaken({
    required String nickname,
    String? excludedProfileId,
  }) {
    return _guard(
      () => _profiles.hasNormalizedNickname(
        normalizedNickname: NicknameRules.normalize(nickname),
        excludedProfileId: excludedProfileId,
      ),
    );
  }

  @override
  Future<DataState<ProfileEntity>> createProfile({
    required ProfileEntity profile,
  }) {
    return _guard(() async {
      final DateTime now = _clock.now();
      await _profiles.insertProfile(
        profile: ProfileLocalModel.fromEntity(profile: profile, updatedAt: now),
        settings: ProfileSettingsLocalModel.fromEntity(
          settings: ProfileSettingsEntity.defaults(profileId: profile.id),
          updatedAt: now,
        ),
      );
      _notifyProfilesChanged();
      return profile;
    });
  }

  @override
  Future<DataState<ProfileEntity>> updateProfile({
    required ProfileEntity profile,
  }) {
    return _guard(() async {
      final int changedRows = await _profiles.updateProfile(
        profile: ProfileLocalModel.fromEntity(
          profile: profile,
          updatedAt: _clock.now(),
        ),
      );
      if (changedRows == 0) throw _notFound(profile.id);
      _notifyProfilesChanged();
      return profile;
    });
  }

  @override
  Future<DataState<void>> deleteProfile({required String profileId}) {
    return _guard(() async {
      final int deletedRows = await _profiles.deleteProfile(
        profileId: profileId,
      );
      if (deletedRows == 0) throw _notFound(profileId);
      if (await _activeProfile.readActiveProfileId() == profileId) {
        await _activeProfile.clearActiveProfileId();
      }
      _notifyProfilesChanged();
    });
  }

  @override
  Future<DataState<String?>> getActiveProfileId() {
    return _guard(() async {
      final String? profileId = await _activeProfile.readActiveProfileId();
      if (profileId == null) return null;
      if (await _profiles.getProfile(profileId: profileId) != null) {
        return profileId;
      }
      await _activeProfile.clearActiveProfileId();
      return null;
    });
  }

  @override
  Future<DataState<void>> setActiveProfileId({required String profileId}) {
    return _guard(() async {
      await _activeProfile.writeActiveProfileId(profileId: profileId);
      _notifyProfilesChanged();
    });
  }

  @override
  Future<DataState<void>> clearActiveProfileId() {
    return _guard(() async {
      await _activeProfile.clearActiveProfileId();
      _notifyProfilesChanged();
    });
  }

  @override
  Stream<void> watchProfileChanges() {
    return _changeBus.watchTable(table: ProfileTable.name);
  }

  Future<ProfileLocalModel> _readProfile(String profileId) async {
    final ProfileLocalModel? model = await _profiles.getProfile(
      profileId: profileId,
    );
    if (model == null) throw _notFound(profileId);
    return model;
  }

  NotFoundException _notFound(String profileId) {
    return NotFoundException(message: 'No profile $profileId.');
  }

  void _notifyProfilesChanged() {
    _changeBus.notifyChanged(table: ProfileTable.name);
  }

  /// Runs [action] and turns its outcome or its failure into a [DataState].
  Future<DataState<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return DataSuccess<T>(await action());
    } on AppException catch (exception) {
      return DataFailed<T>(exception);
    } on DatabaseException catch (error, stackTrace) {
      log(
        'Database failure',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<T>(
        error.isUniqueConstraintError()
            ? const ConflictException(message: 'Nickname already taken.')
            : CacheException(message: error.toString()),
      );
    } on Object catch (error, stackTrace) {
      log(
        'Unexpected failure',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<T>(UnknownException(message: error.toString()));
    }
  }
}
