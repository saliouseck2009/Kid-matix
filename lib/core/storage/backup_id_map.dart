import 'package:kid_matix/core/services/id_generator.dart';

/// Identifiers given to the rows of a backup file as they are imported.
///
/// The player gets [profileId]; every other identifier of the file, such
/// as a quiz session's, gets a new one, the same each time it is met, so
/// rows that point to each other in the file still do once imported, and
/// importing a file twice never collides.
final class BackupIdMap {
  /// Creates the map for the player [profileId].
  BackupIdMap({required this.profileId, required this._idGenerator});

  /// Identifier of the imported player on this phone.
  final String profileId;

  final IdGenerator _idGenerator;
  final Map<String, String> _ids = <String, String>{};

  /// Returns the identifier on this phone of [fileId], an identifier of
  /// the file.
  String remap(String fileId) {
    return _ids.putIfAbsent(fileId, _idGenerator.generateId);
  }
}
