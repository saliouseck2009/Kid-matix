import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_backup_local_data_source.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_backup_section.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_settings_table.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_table.dart';
import 'package:kid_matix/features/profile/data/models/profile_settings_local_model.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_target.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:sqflite/sqflite.dart';

/// [ProfileBackupLocalDataSource] over the local database: the profile
/// feature writes the player and their settings, and every
/// [ProfileBackupPart] of the other features writes its own section.
final class ProfileBackupLocalDataSourceImpl
    implements ProfileBackupLocalDataSource {
  /// Creates the data source.
  const ProfileBackupLocalDataSourceImpl({
    required this._database,
    required this._parts,
    required this._idGenerator,
  });

  // Rows of several features point to each other (the XP of a quiz to
  // its session): checked once every part wrote, whatever their order.
  static const String _deferForeignKeys = 'PRAGMA defer_foreign_keys = ON';

  final AppDatabase _database;
  final ProfileBackupParts _parts;
  final IdGenerator _idGenerator;

  @override
  Future<Map<String, Object?>> readSections({required String profileId}) async {
    final Database database = await _database.database;
    return database.transaction((Transaction transaction) async {
      final Map<String, Object?> sections = <String, Object?>{
        ProfileBackupSection.name: await _readPlayer(transaction, profileId),
      };
      for (final ProfileBackupPart part in _parts.parts) {
        sections[part.section] = await part.exportSection(
          transaction,
          profileId: profileId,
        );
      }
      return sections;
    });
  }

  @override
  Future<Set<String>> writeSections({
    required Map<String, Object?> sections,
    required BackupImportTarget target,
  }) async {
    final Database database = await _database.database;
    final BackupIdMap ids = BackupIdMap(
      profileId: target.profileId,
      idGenerator: _idGenerator,
    );
    return database.transaction((Transaction transaction) async {
      await transaction.execute(_deferForeignKeys);
      if (target.replacesProfile) {
        await transaction.delete(
          ProfileTable.name,
          where: '${ProfileTable.id} = ?',
          whereArgs: <Object>[target.profileId],
        );
      }
      await _writePlayer(transaction, sections, target);
      final Set<String> tables = <String>{
        ProfileTable.name,
        ProfileSettingsTable.name,
      };
      for (final ProfileBackupPart part in _parts.parts) {
        tables.addAll(await _writePart(transaction, part, sections, ids));
      }
      await _checkForeignKeys(transaction, tables);
      return tables;
    });
  }

  Future<Map<String, Object?>> _readPlayer(
    DatabaseExecutor executor,
    String profileId,
  ) async {
    final List<Map<String, Object?>> profiles = await executor.query(
      ProfileTable.name,
      where: '${ProfileTable.id} = ?',
      whereArgs: <Object>[profileId],
    );
    if (profiles.isEmpty) {
      throw NotFoundException(message: 'No profile $profileId.');
    }
    final List<Map<String, Object?>> settings = await executor.query(
      ProfileSettingsTable.name,
      where: '${ProfileSettingsTable.profileId} = ?',
      whereArgs: <Object>[profileId],
    );
    return <String, Object?>{
      ProfileBackupSection.profileKey: profiles.first,
      ProfileBackupSection.settingsKey: settings.firstOrNull,
    };
  }

  Future<void> _writePlayer(
    Transaction transaction,
    Map<String, Object?> sections,
    BackupImportTarget target,
  ) async {
    final Map<String, Object?> profile = ProfileBackupSection.readProfile(
      sections,
    ).toJson();
    await transaction.insert(ProfileTable.name, <String, Object?>{
      ...profile,
      ProfileTable.id: target.profileId,
      'nickname': target.nickname,
      ProfileTable.normalizedNickname: NicknameRules.normalize(
        target.nickname,
      ),
      'remote_account_id': null,
      'deleted_at': null,
      // A backup always comes back as a free player: the class of a pupil
      // is not on every phone.
      ProfileTable.classroomId: null,
    });
    final ProfileSettingsLocalModel settings =
        ProfileBackupSection.readSettings(sections) ??
        ProfileSettingsLocalModel.fromEntity(
          settings: ProfileSettingsEntity.defaults(profileId: target.profileId),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(
            profile['updated_at']! as int,
          ),
        );
    await transaction.insert(ProfileSettingsTable.name, <String, Object?>{
      ...settings.toJson(),
      ProfileSettingsTable.profileId: target.profileId,
    });
  }

  /// Throws a [FormatException] when a row written points to nothing,
  /// so the transaction is rolled back: a deferred check failing only at
  /// commit would leave it open.
  Future<void> _checkForeignKeys(
    Transaction transaction,
    Set<String> tables,
  ) async {
    for (final String table in tables) {
      final List<Map<String, Object?>> broken = await transaction.rawQuery(
        'PRAGMA foreign_key_check($table)',
      );
      if (broken.isNotEmpty) {
        throw FormatException('Rows of $table point to nothing.');
      }
    }
  }

  Future<List<String>> _writePart(
    Transaction transaction,
    ProfileBackupPart part,
    Map<String, Object?> sections,
    BackupIdMap ids,
  ) async {
    final Object? content = sections[part.section];
    if (content == null) return const <String>[];
    if (content is! Map<String, Object?>) {
      throw FormatException('Section ${part.section} is not an object.');
    }
    return part.importSection(transaction, content: content, ids: ids);
  }
}
