import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/features/division/domain/services/division_domain.dart';
import 'package:kid_matix/features/division/injection.dart';
import 'package:kid_matix/features/multiplication/injection.dart';
import 'package:kid_matix/features/number/injection.dart';

void main() {
  test('declares the division domain after the domains before it', () {
    // Arrange
    final GetIt inputLocator = GetIt.asNewInstance()
      ..registerLazySingleton<DomainRegistry>(DomainRegistry.new);
    registerMultiplicationFeature(inputLocator);
    registerNumbersFeature(inputLocator);
    // Act
    registerDivisionFeature(inputLocator);
    // Assert
    final DomainRegistry actualRegistry = inputLocator<DomainRegistry>();
    expect(actualRegistry.find(DivisionDomain.domainId), isA<DivisionDomain>());
    expect(
      actualRegistry.domains.map((LearningDomain domain) => domain.id),
      <String>['multiplication', 'numbers', 'division'],
    );
  });
}
