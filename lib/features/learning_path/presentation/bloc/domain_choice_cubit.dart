import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_choice_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_use_cases.dart';

/// The domain a player sees on the map or in the Profile; it follows a
/// choice made on the other screen.
final class DomainChoiceCubit extends Cubit<DomainChoiceState> {
  /// Creates the Cubit of the player [profileId].
  DomainChoiceCubit({required this._profileId, required this._useCases})
    : super(const DomainChoiceLoading());

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

  /// Shows [domainId] at once and keeps it as the player's choice; a
  /// choice that cannot be kept is reported, the domain stays shown.
  Future<void> select(String domainId) async {
    final DomainChoiceState current = state;
    if (current is! DomainChoiceLoaded) return;
    final DomainChoiceEntity choice = current.choice;
    if (choice.selectedId == domainId) return;
    if (!choice.domainIds.contains(domainId)) return;
    emit(DomainChoiceLoaded(choice: choice.copyWith(selectedId: domainId)));
    final DataState<void> saved = await _useCases.selectDomain(
      params: LearningPathParams(profileId: _profileId, domainId: domainId),
    );
    if (saved case DataFailed<void>(:final exception)) {
      addError(exception, StackTrace.current);
    }
  }

  Future<void> _read() async {
    final DataState<DomainChoiceEntity> read = await _useCases.getChoice(
      params: _profileId,
    );
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<DomainChoiceEntity>(:final data) => DomainChoiceLoaded(
        choice: data,
      ),
      DataFailed<DomainChoiceEntity>(:final exception) => DomainChoiceFailure(
        errorCode: exception.code,
      ),
    });
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
