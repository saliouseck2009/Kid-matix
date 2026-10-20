import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/data_state.dart';

/// The players of the shared phone, as the duel lists them.
///
/// Implemented by the profile feature, which owns the players.
abstract interface class PlayerDirectoryService {
  /// Returns every free player of the device, oldest first: the pupils of
  /// the classes are left out of the duel and the leaderboard.
  Future<DataState<List<PlayerIdentity>>> readPlayers();
}
