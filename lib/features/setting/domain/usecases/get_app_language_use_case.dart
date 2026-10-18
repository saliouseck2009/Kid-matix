import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';
import 'package:kid_matix/features/setting/domain/repositories/language_repository.dart';

/// Reads the language of the interface chosen for the phone.
class GetAppLanguageUseCase implements NoParamUseCase<DataState<AppLanguage>> {
  /// Creates the use case.
  const GetAppLanguageUseCase({required this._repository});

  final LanguageRepository _repository;

  @override
  Future<DataState<AppLanguage>> call() => _repository.getLanguage();
}
