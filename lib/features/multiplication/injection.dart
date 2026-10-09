import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

/// Declares the multiplication domain in the [DomainRegistry] of [sl].
void registerMultiplicationFeature(GetIt sl) {
  sl<DomainRegistry>().register(MultiplicationDomain());
}
