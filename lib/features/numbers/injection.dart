import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/features/numbers/domain/services/numbers_domain.dart';

/// Declares the numbers domain in the [DomainRegistry] of [sl], after the
/// multiplication: the domains are offered in their registration order.
void registerNumbersFeature(GetIt sl) {
  sl<DomainRegistry>().register(NumbersDomain());
}
