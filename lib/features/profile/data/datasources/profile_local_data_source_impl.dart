import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/common_columns.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_settings_table.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_table.dart';
import 'package:kid_matix/features/profile/data/models/profile_local_model.dart';
import 'package:kid_matix/features/profile/data/models/profile_settings_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [ProfileLocalDataSource] over the app database.
final class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  /// Creates the data source over [database].
  const ProfileLocalDataSourceImpl({required this._database});

  static const String _isLive = '${CommonColumns.deletedAt} IS NULL';
  static const String _isLiveWithId = '${ProfileTable.id} = ? AND $_isLive';
  static const String _countAlias = 'profile_count';

  final AppDatabase _database;

  @override
  Future<List<ProfileLocalModel>> getProfiles() async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ProfileTable.name,
      where: _isLive,
      orderBy: ProfileTable.createdAt,
    );
    return rows.map(ProfileLocalModel.fromJson).toList();
  }

  @override
  Future<ProfileLocalModel?> getProfile({required String profileId}) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ProfileTable.name,
      where: _isLiveWithId,
      whereArgs: <Object>[profileId],
    );
    return rows.isEmpty ? null : ProfileLocalModel.fromJson(rows.single);
  }

  @override
  Future<int> countProfiles() async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.rawQuery(
      'SELECT COUNT(*) AS $_countAlias FROM ${ProfileTable.name} '
      'WHERE $_isLive',
    );
    return rows.single[_countAlias]! as int;
  }

  @override
  Future<bool> hasNormalizedNickname({
    required String normalizedNickname,
    String? excludedProfileId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ProfileTable.name,
      columns: <String>[ProfileTable.id],
      where:
          '${ProfileTable.normalizedNickname} = ? AND $_isLive '
          'AND ${ProfileTable.id} != ?',
      whereArgs: <Object>[normalizedNickname, excludedProfileId ?? ''],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<void> insertProfile({
    required ProfileLocalModel profile,
    required ProfileSettingsLocalModel settings,
  }) async {
    final Database database = await _database.database;
    await database.transaction((Transaction transaction) async {
      await transaction.insert(ProfileTable.name, profile.toJson());
      await transaction.insert(ProfileSettingsTable.name, settings.toJson());
    });
  }

  @override
  Future<int> updateProfile({required ProfileLocalModel profile}) async {
    final Database database = await _database.database;
    return database.update(
      ProfileTable.name,
      profile.toJson(),
      where: _isLiveWithId,
      whereArgs: <Object>[profile.id],
    );
  }

  @override
  Future<int> deleteProfile({required String profileId}) async {
    final Database database = await _database.database;
    return database.delete(
      ProfileTable.name,
      where: '${ProfileTable.id} = ?',
      whereArgs: <Object>[profileId],
    );
  }
}
