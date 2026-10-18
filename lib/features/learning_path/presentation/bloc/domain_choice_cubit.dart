import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_choice_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_use_cases.dart';

/// The domain a player sees on the map or in the Profile, `null` while it
/// is read; it follows a choice made on the other screen.
final class DomainChoiceCubit extends Cubit<DomainChoiceEntity?> {
  /// Creates the Cubit of the player [profileId].
  DomainChoiceCubit({required this._profileId, required this._useCases})
    : super(null);

  final String _profileId;
  final DomainChoiceUseCases _useCases;
  StreamSubscription<void>? _changes;

  /// Reads the choice and follows its changes.
  Future<void> load() async {
    _changes ??= _useCases
        .watchChoice(profileId: _profileId)
        .listen((_) => unawaited(_read()));
    await _read();
  }

  /// Shows [domainId] at once and keeps it as the player's choice.
  Future<void> select(String domainId) async {
    final DomainChoiceEntity? current = state;
    if (current == null || current.selectedId == domainId) return;
    if (!current.domainIds.contains(domainId)) return;
    emit(current.copyWith(selectedId: domainId));
    await _useCases.selectDomain(
      params: LearningPathParams(profileId: _profileId, domainId: domainId),
    );
  }

  Future<void> _read() async {
    final DataState<DomainChoiceEntity> read = await _useCases.getChoice(
      params: _profileId,
    );
    if (isClosed) return;
    if (read case DataSuccess<DomainChoiceEntity>(:final data)) emit(data);
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
