import 'package:kid_matix/features/math_word/domain/services/catalog_sentence_splitter.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_catalog.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_templates.dart';
import 'package:kid_matix/features/problem/domain/services/problem_domain.dart';

import '../../math_word/helpers/math_word_fixtures.dart';

/// The word problems domain over the real content and the real math
/// words, as the app registers it.
ProblemDomain buildProblemDomain() {
  return ProblemDomain(
    catalog: ProblemCatalog(ProblemTemplates.all),
    splitter: CatalogSentenceSplitter(catalog: loadMathWordCatalog()),
  );
}

/// The template of [problemKey].
ProblemTemplate problemTemplate(String problemKey) {
  return ProblemTemplates.all.firstWhere(
    (ProblemTemplate problem) => problem.problemKey == problemKey,
  );
}
