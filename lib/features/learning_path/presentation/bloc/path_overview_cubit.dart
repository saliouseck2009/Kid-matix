import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_path_overview_use_case.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/path_overview_state.dart';

/// The progress of a player in every domain, read each time « Mes
/// parcours » opens.
final class PathOverviewCubit extends Cubit<PathOverviewState> {
  /// Creates the Cubit of the player [profileId].
  PathOverviewCubit({required this._profileId, required this._getOverview})
    : super(const PathOverviewLoading());

  final String _profileId;
  final GetPathOverviewUseCase _getOverview;

  /// Reads the progress again; the previous one stays shown meanwhile.
  Future<void> load() async {
    final DataState<PathOverviewEntity> read = await _getOverview(
      params: _profileId,
    );
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<PathOverviewEntity>(:final data) => PathOverviewLoaded(
        overview: data,
      ),
      DataFailed<PathOverviewEntity>(:final exception) => PathOverviewFailure(
        errorCode: exception.code,
      ),
    });
  }
}
