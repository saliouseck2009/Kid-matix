import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:sqflite/sqflite.dart';

/// What a feature keeps of one player, written to a backup file and read
/// back from it (lot F20).
///
/// Implemented in the data layer of each feature that stores data per
/// player, the way `ProgressResetHook` is: no class reads the tables of
/// every feature. Each part owns one section of the file.
abstract interface class ProfileBackupPart {
  /// Name of the section of the file holding this part. It never changes
  /// once released: older files must still be read.
  String get section;

  /// Reads everything [profileId] keeps in this part, as JSON values.
  Future<Map<String, Object?>> exportSection(
    DatabaseExecutor executor, {
    required String profileId,
  });

  /// Writes [content], read from a file, for the player of [ids] in
  /// [transaction], and returns the tables written, to notify once the
  /// transaction is committed.
  ///
  /// Unknown keys are ignored and missing ones count as empty, so a file
  /// of another version of the format can be read. Every identifier of
  /// the file goes through [ids]: nothing collides with the rows already
  /// on the phone. Throws a [FormatException] when [content] is malformed.
  Future<List<String>> importSection(
    Transaction transaction, {
    required Map<String, Object?> content,
    required BackupIdMap ids,
  });
}

/// The [ProfileBackupPart]s of the app, added by each feature at startup.
final class ProfileBackupParts {
  final List<ProfileBackupPart> _parts = <ProfileBackupPart>[];

  /// Every part, in the order they were added.
  List<ProfileBackupPart> get parts =>
      List<ProfileBackupPart>.unmodifiable(_parts);

  /// Adds [part].
  void add(ProfileBackupPart part) => _parts.add(part);
}
