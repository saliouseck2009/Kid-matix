import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_state.dart';

/// Reads a reward value with a use case, and reads it again each time
/// [changes] emits, after a quiz is saved.
final class RewardValueCubit<T> extends Cubit<RewardValueState<T>> {
  /// Creates the Cubit reading [read], refreshed on [changes].
  RewardValueCubit({required this._read, this._changes})
    : super(RewardValueLoading<T>());

  final Future<DataState<T>> Function() _read;
  final Stream<void>? _changes;
  StreamSubscription<void>? _subscription;

  /// Reads the value and follows its changes.
  Future<void> load() async {
    _subscription ??= _changes?.listen((_) => unawaited(_reload()));
    await _reload();
  }

  Future<void> _reload() async {
    final DataState<T> read = await _read();
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<T>(:final data) => RewardValueLoaded<T>(value: data),
      DataFailed<T>(:final exception) => RewardValueFailure<T>(
        errorCode: exception.code,
      ),
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
