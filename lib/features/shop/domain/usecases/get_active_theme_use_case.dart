import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/shop/domain/repositories/shop_repository.dart';

/// Returns the color theme a player applied; takes the profile id.
class GetActiveThemeUseCase
    implements UseCase<DataState<AppColorTheme>, String> {
  /// Creates the use case.
  const GetActiveThemeUseCase({required this._repository});

  final ShopRepository _repository;

  @override
  Future<DataState<AppColorTheme>> call({required String params}) {
    return _repository.getActiveTheme(profileId: params);
  }
}
