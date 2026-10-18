import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 13: the "Aide audio" setting of each player (lot F28).
///
/// `help_audio_language` is the code of the language of the recorded
/// explanations of the math words, or `none`. It is NULL for a player who
/// never chose, existing players included: the help is then in the first
/// pack of `packs.json`, so no language is written in the code. A word
/// without recording shows no button. The SQL is written out in full: a
/// released migration never changes.
final class Migration013AddHelpAudioSetting implements DatabaseMigration {
  /// Creates the migration.
  const Migration013AddHelpAudioSetting();

  @override
  int get version => 13;

  @override
  Future<void> migrate(Database database) async {
    await database.execute('''
      ALTER TABLE profile_settings
      ADD COLUMN help_audio_language TEXT
    ''');
  }
}
