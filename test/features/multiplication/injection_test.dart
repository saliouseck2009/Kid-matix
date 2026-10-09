import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/multiplication/injection.dart';

void main() {
  test('declares the multiplication domain at startup', () {
    // Arrange
    final GetIt inputLocator = GetIt.asNewInstance()
      ..registerLazySingleton<DomainRegistry>(DomainRegistry.new);
    // Act
    registerMultiplicationFeature(inputLocator);
    // Assert
    expect(
      inputLocator<DomainRegistry>().find(MultiplicationDomain.domainId),
      isA<MultiplicationDomain>(),
    );
  });
}
