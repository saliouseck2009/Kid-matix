import 'package:meta/meta.dart';

/// How a backup file becomes a player of the phone.
@immutable
sealed class BackupImportChoice {
  const BackupImportChoice();
}

/// A new player with the nickname of the file, free on the phone.
final class ImportAsNewPlayer extends BackupImportChoice {
  /// Creates the choice.
  const ImportAsNewPlayer();

  @override
  bool operator ==(Object other) => other is ImportAsNewPlayer;

  @override
  int get hashCode => (ImportAsNewPlayer).hashCode;
}

/// The player [profileId] of the phone, who has the same nickname, is
/// replaced by the file: their progress is erased.
final class ReplacePlayer extends BackupImportChoice {
  /// Creates the choice.
  const ReplacePlayer({required this.profileId});

  /// Player replaced.
  final String profileId;

  @override
  bool operator ==(Object other) =>
      other is ReplacePlayer && other.profileId == profileId;

  @override
  int get hashCode => profileId.hashCode;
}

/// A new player with another [nickname] than the file's.
final class RenamePlayer extends BackupImportChoice {
  /// Creates the choice.
  const RenamePlayer({required this.nickname});

  /// Nickname typed for the imported player.
  final String nickname;

  @override
  bool operator ==(Object other) =>
      other is RenamePlayer && other.nickname == nickname;

  @override
  int get hashCode => nickname.hashCode;
}
