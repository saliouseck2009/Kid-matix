import 'package:kid_matix/features/shop/domain/repositories/shop_repository.dart';

/// Emits an event each time a theme or a purchase changes.
class WatchThemeChangesUseCase {
  /// Creates the use case.
  const WatchThemeChangesUseCase({required this._repository});

  final ShopRepository _repository;

  /// Returns the stream of changes.
  Stream<void> call() => _repository.watchChanges();
}
