import 'dart:convert';
import 'dart:io';

import 'package:kid_matix/features/math_word/domain/entities/math_word_catalog.dart';
import 'package:kid_matix/features/math_word/domain/services/math_word_domain.dart';

/// The catalog of the bundled data asset, read from the project folder
/// (tests run from the root of the project).
MathWordCatalog loadMathWordCatalog() {
  final Object? json = jsonDecode(
    File('assets/math_words/math_words.json').readAsStringSync(),
  );
  return MathWordCatalog.fromJson(json! as Map<String, Object?>);
}

/// The math words domain over the bundled content.
MathWordDomain buildMathWordDomain() {
  return MathWordDomain(catalog: loadMathWordCatalog());
}
