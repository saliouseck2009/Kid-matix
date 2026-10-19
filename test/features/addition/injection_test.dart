import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/features/addition/domain/services/addition_domain.dart';
import 'package:kid_matix/features/addition/injection.dart';
import 'package:kid_matix/features/multiplication/injection.dart';
import 'package:kid_matix/features/number/injection.dart';

void main() {
  test('declares the addition domain after the numbers', () {
    // Arrange
    final GetIt inputLocator = GetIt.asNewInstance()
      ..registerLazySingleton<DomainRegistry>(DomainRegistry.new);
    registerMultiplicationFeature(inputLocator);
    registerNumbersFeature(inputLocator);
    // Act
    registerAdditionFeature(inputLocator);
    // Assert
    final DomainRegistry actualRegistry = inputLocator<DomainRegistry>();
    expect(actualRegistry.find(AdditionDomain.domainId), isA<AdditionDomain>());
    expect(
      actualRegistry.domains.map((LearningDomain domain) => domain.id),
      <String>['multiplication', 'numbers', 'addition'],
    );
  });
}
