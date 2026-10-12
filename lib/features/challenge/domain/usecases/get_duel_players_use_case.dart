import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_directory_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';

/// Lists the players of the phone who can play a duel, oldest first.
class GetDuelPlayersUseCase
    implements NoParamUseCase<DataState<List<PlayerIdentity>>> {
  /// Creates the use case.
  const GetDuelPlayersUseCase({required this._players});

  final PlayerDirectoryService _players;

  @override
  Future<DataState<List<PlayerIdentity>>> call() => _players.readPlayers();
}
