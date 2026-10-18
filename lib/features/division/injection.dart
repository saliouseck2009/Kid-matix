import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/features/division/domain/services/division_domain.dart';

/// Declares the division domain in the [DomainRegistry] of [sl], after the
/// domains before it: the domains are offered in their registration order.
void registerDivisionFeature(GetIt sl) {
  sl<DomainRegistry>().register(DivisionDomain());
}
