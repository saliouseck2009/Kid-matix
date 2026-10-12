import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/mastery/domain/entities/monster_collection_entity.dart';
import 'package:meta/meta.dart';

/// What the « Mes monstres » screen shows.
@immutable
sealed class MonstersState {
  const MonstersState();
}

/// The monsters are being read.
final class MonstersLoading extends MonstersState {
  /// Creates the state.
  const MonstersLoading();
}

/// The monsters of the player.
final class MonstersLoaded extends MonstersState {
  /// Creates the state.
  const MonstersLoaded({required this.monsters});

  /// Monsters still to tame and tamed.
  final MonsterCollectionEntity monsters;
}

/// The monsters could not be read.
final class MonstersFailure extends MonstersState {
  /// Creates the state.
  const MonstersFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
