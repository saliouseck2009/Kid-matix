import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/features/addition/domain/services/addition_domain.dart';

/// Declares the addition domain in the [DomainRegistry] of [sl], after the
/// numbers: the domains are offered in their registration order.
void registerAdditionFeature(GetIt sl) {
  sl<DomainRegistry>().register(AdditionDomain());
}
