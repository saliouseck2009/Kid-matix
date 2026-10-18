import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/features/multiplication/injection.dart';
import 'package:kid_matix/features/numbers/domain/services/numbers_domain.dart';
import 'package:kid_matix/features/numbers/injection.dart';

void main() {
  test('declares the numbers domain after the multiplication', () {
    // Arrange
    final GetIt inputLocator = GetIt.asNewInstance()
      ..registerLazySingleton<DomainRegistry>(DomainRegistry.new);
    registerMultiplicationFeature(inputLocator);
    // Act
    registerNumbersFeature(inputLocator);
    // Assert
    final DomainRegistry actualRegistry = inputLocator<DomainRegistry>();
    expect(actualRegistry.find(NumbersDomain.domainId), isA<NumbersDomain>());
    expect(
      actualRegistry.domains.map((LearningDomain domain) => domain.id),
      <String>['multiplication', 'numbers'],
    );
  });
}
