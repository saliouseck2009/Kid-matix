import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:meta/meta.dart';

/// Time passing in a duel.
@immutable
final class DuelElapseParams {
  /// Creates the parameters.
  const DuelElapseParams({required this.game, required this.elapsed});

  /// The duel as it stands.
  final DuelGameEntity game;

  /// Time passed since the last call.
  final Duration elapsed;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DuelElapseParams &&
            other.game == game &&
            other.elapsed == elapsed;
  }

  @override
  int get hashCode => Object.hash(game, elapsed);
}
