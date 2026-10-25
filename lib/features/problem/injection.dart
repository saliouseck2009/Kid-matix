import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/entities/currency.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/services/sentence_splitter.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_catalog.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_templates.dart';
import 'package:kid_matix/features/problem/domain/services/problem_domain.dart';

/// Declares the word problems domain in the [DomainRegistry] of [sl], after
/// the math words: the domains are offered in their registration order.
///
/// The words that can be touched come from the [SentenceSplitter] of the
/// math words when it is registered (it is left out with them when their
/// content is unreadable); the money is [Currency.defaultCurrency], the one
/// place to change it.
void registerProblemFeature(GetIt sl) {
  sl<DomainRegistry>().register(
    ProblemDomain(
      catalog: ProblemCatalog(ProblemTemplates.all),
      splitter: sl.isRegistered<SentenceSplitter>()
          ? sl<SentenceSplitter>()
          : null,
      currency: Currency.defaultCurrency,
    ),
  );
}
