import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_catalog.dart';

/// Reads the content of the math words from the data asset
/// `assets/math_words/math_words.json`, derived from the content table by
/// `tool/build_math_words.py`.
final class MathWordAssetSource {
  /// Creates the source over [bundle].
  const MathWordAssetSource({required this._bundle});

  /// Path of the data asset.
  static const String asset = 'assets/math_words/math_words.json';

  final AssetBundle _bundle;

  /// Returns the catalog; throws a [FormatException] when the asset is
  /// malformed, which a test of the bundled file prevents.
  Future<MathWordCatalog> load() async {
    final Object? json = jsonDecode(await _bundle.loadString(asset));
    if (json is! Map<String, Object?>) {
      throw const FormatException('Not a math words catalog');
    }
    return MathWordCatalog.fromJson(json);
  }
}
