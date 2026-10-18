import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_choice_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/path_domain_repository.dart';

/// Returns the domains of the app and the one a player sees: the domain
/// they chose last, or the first one registered (the multiplication) when
/// they never chose, when it cannot be read or is no longer in the app.
///
/// Fails with a `ValidationException` when the app has no domain.
class GetDomainChoiceUseCase
    implements UseCase<DataState<DomainChoiceEntity>, String> {
  /// Creates the use case.
  const GetDomainChoiceUseCase({
    required this._repository,
    required this._domains,
  });

  final PathDomainRepository _repository;
  final DomainRegistry _domains;

  /// Returns the choice of the player [params].
  @override
  Future<DataState<DomainChoiceEntity>> call({required String params}) async {
    final List<String> domainIds = _domains.domains
        .map((LearningDomain domain) => domain.id)
        .toList();
    if (domainIds.isEmpty) {
      return const DataFailed<DomainChoiceEntity>(
        ValidationException(message: 'No learning domain.'),
      );
    }
    final DataState<String?> stored = await _repository.getDomain(
      profileId: params,
    );
    final String? chosen = switch (stored) {
      DataSuccess<String?>(:final String? data) => data,
      DataFailed<String?>() => null,
    };
    return DataSuccess<DomainChoiceEntity>(
      DomainChoiceEntity(
        domainIds: domainIds,
        selectedId: domainIds.contains(chosen) ? chosen! : domainIds.first,
      ),
    );
  }
}
