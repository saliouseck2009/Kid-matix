import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/sentence_part.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_family.dart';
import 'package:kid_matix/features/math_word/domain/entities/operation_statement.dart';

/// Everything the math words domain teaches: the words, grouped in
/// families, and the statements of « Quelle opération ? ».
///
/// Read from `assets/math_words/math_words.json`, which
/// `tool/build_math_words.py` derives from `docs/product/math-words.md`.
final class MathWordCatalog {
  /// Creates the catalog of [words] (in the order of the content table,
  /// grouped by family) and [statements]; throws a [FormatException] when
  /// a key is duplicated or a statement uses a word that does not exist.
  factory MathWordCatalog({
    required List<MathWord> words,
    required List<OperationStatement> statements,
    Map<String, Map<String, String>> helpExplanations =
        const <String, Map<String, String>>{},
  }) {
    final Set<String> keys = words.map((MathWord word) => word.wordKey).toSet();
    if (keys.length != words.length) {
      throw const FormatException('Two math words share a key');
    }
    for (final OperationStatement statement in statements) {
      for (final String key in statement.wordKeys) {
        if (!keys.contains(key)) {
          throw FormatException('${statement.id} uses the unknown word $key');
        }
      }
    }
    return MathWordCatalog._(words, statements, helpExplanations);
  }

  /// Reads the decoded data asset.
  factory MathWordCatalog.fromJson(Map<String, Object?> json) {
    final Object? words = json['words'];
    final Object? statements = json['statements'];
    if (words is! List || statements is! List) {
      throw const FormatException('Not a math words catalog');
    }
    return MathWordCatalog(
      helpExplanations: <String, Map<String, String>>{
        for (final Object? entry in words)
          _stringOf(_objectOf(entry), 'key'): _helpOf(_objectOf(entry)),
      },
      words: <MathWord>[
        for (final Object? entry in words) _wordOf(_objectOf(entry)),
      ],
      statements: <OperationStatement>[
        for (final Object? entry in statements) _statementOf(_objectOf(entry)),
      ],
    );
  }

  MathWordCatalog._(
    List<MathWord> words,
    List<OperationStatement> statements,
    Map<String, Map<String, String>> helpExplanations,
  ) : _helpExplanations = helpExplanations,
      words = List<MathWord>.unmodifiable(words),
      statements = List<OperationStatement>.unmodifiable(statements),
      families = List<MathWordFamily>.unmodifiable(_familiesOf(words));

  /// Every word, in the order of the content table.
  final List<MathWord> words;

  /// Every statement.
  final List<OperationStatement> statements;

  /// The families, in the order of the path.
  final List<MathWordFamily> families;

  final Map<String, Map<String, String>> _helpExplanations;

  /// The explanation of [wordKey] written in each help language, by
  /// language code (`"help": {"wo": {"explanation": …}}` in the asset);
  /// empty until the owner writes them.
  Map<String, String> helpExplanationsOf(String wordKey) {
    return _helpExplanations[wordKey] ?? const <String, String>{};
  }

  late final Map<String, MathWord> _wordsByKey = <String, MathWord>{
    for (final MathWord word in words) word.wordKey: word,
  };

  /// The word of [wordKey], or `null`.
  MathWord? wordOf(String wordKey) => _wordsByKey[wordKey];

  /// The statements that train the word [wordKey].
  List<OperationStatement> statementsOf(String wordKey) {
    return <OperationStatement>[
      for (final OperationStatement statement in statements)
        if (statement.wordKeys.contains(wordKey)) statement,
    ];
  }

  /// The example of [word] cut into pieces: the word itself and the other
  /// math words it contains can be touched.
  List<SentencePart> sentenceOf(MathWord word) {
    final String example = word.example;
    final String lower = example.toLowerCase();
    final int start = lower.indexOf(word.surface.toLowerCase());
    final List<({int start, int end, String key})> spans =
        <({int start, int end, String key})>[
          if (start >= 0)
            (start: start, end: start + word.surface.length, key: word.wordKey),
        ];
    for (final MathWord other in words) {
      if (other == word) continue;
      final int at = _findWhole(lower, other.surface.toLowerCase());
      final int end = at + other.surface.length;
      final bool overlaps = spans.any(
        (({int start, int end, String key}) span) =>
            at < span.end && end > span.start,
      );
      if (at >= 0 && !overlaps) {
        spans.add((start: at, end: end, key: other.wordKey));
      }
    }
    spans.sort(
      (
        ({int start, int end, String key}) a,
        ({int start, int end, String key}) b,
      ) => a.start.compareTo(b.start),
    );
    final List<SentencePart> parts = <SentencePart>[];
    int cursor = 0;
    for (final ({int start, int end, String key}) span in spans) {
      if (span.start > cursor) {
        parts.add(SentencePart(example.substring(cursor, span.start)));
      }
      parts.add(
        SentencePart(
          example.substring(span.start, span.end),
          wordKey: span.key,
        ),
      );
      cursor = span.end;
    }
    if (cursor < example.length) {
      parts.add(SentencePart(example.substring(cursor)));
    }
    return parts;
  }

  /// [text] cut into pieces for the word problems (lot F30): each math
  /// word it contains, in the form the word has in its example, is a piece
  /// that can be touched (its first whole-word match). Longer forms win
  /// over the shorter ones they contain.
  List<SentencePart> splitText(String text) {
    final String lower = text.toLowerCase();
    final List<({int start, int end, String key})> spans =
        <({int start, int end, String key})>[];
    // Each word is found by its form in the example or by its own text:
    // « partager » is touchable in « les partager » as « partage » is in
    // « Il partage ».
    final List<(MathWord, String)> expressions = <(MathWord, String)>[
      for (final MathWord word in words) ...<(MathWord, String)>[
        (word, word.surface),
        if (word.text.toLowerCase() != word.surface.toLowerCase())
          (word, word.text),
      ],
    ]..sort((a, b) => b.$2.length.compareTo(a.$2.length));
    for (final (MathWord word, String expression) in expressions) {
      final int at = _findWhole(lower, expression.toLowerCase());
      if (at < 0) continue;
      final int end = at + expression.length;
      final bool overlaps = spans.any(
        (({int start, int end, String key}) span) =>
            at < span.end && end > span.start,
      );
      final bool isTaken = spans.any(
        (({int start, int end, String key}) span) => span.key == word.wordKey,
      );
      if (!overlaps && !isTaken) {
        spans.add((start: at, end: end, key: word.wordKey));
      }
    }
    spans.sort(
      (
        ({int start, int end, String key}) a,
        ({int start, int end, String key}) b,
      ) => a.start.compareTo(b.start),
    );
    final List<SentencePart> parts = <SentencePart>[];
    int cursor = 0;
    for (final ({int start, int end, String key}) span in spans) {
      if (span.start > cursor) {
        parts.add(SentencePart(text.substring(cursor, span.start)));
      }
      parts.add(
        SentencePart(text.substring(span.start, span.end), wordKey: span.key),
      );
      cursor = span.end;
    }
    if (cursor < text.length) parts.add(SentencePart(text.substring(cursor)));
    return parts;
  }

  static final RegExp _letter = RegExp(r'\p{L}', unicode: true);

  /// Position of the first occurrence of [needle] in [text] that is not
  /// inside a longer word, or -1.
  static int _findWhole(String text, String needle) {
    int from = 0;
    while (true) {
      final int at = text.indexOf(needle, from);
      if (at < 0) return -1;
      final int end = at + needle.length;
      final bool startsWord = at == 0 || !_letter.hasMatch(text[at - 1]);
      final bool endsWord = end == text.length || !_letter.hasMatch(text[end]);
      if (startsWord && endsWord) return at;
      from = at + 1;
    }
  }

  static List<MathWordFamily> _familiesOf(List<MathWord> words) {
    final Map<String, List<MathWord>> bySlug = <String, List<MathWord>>{};
    for (final MathWord word in words) {
      bySlug.putIfAbsent(word.familySlug, () => <MathWord>[]).add(word);
    }
    int number = 0;
    return <MathWordFamily>[
      for (final MapEntry<String, List<MathWord>> entry in bySlug.entries)
        MathWordFamily(slug: entry.key, number: ++number, words: entry.value),
    ];
  }

  static Map<String, Object?> _objectOf(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw const FormatException('Not an object');
  }

  static String _stringOf(Map<String, Object?> json, String name) {
    final Object? value = json[name];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Missing text: $name');
  }

  static MathWord _wordOf(Map<String, Object?> json) {
    return MathWord(
      wordKey: _stringOf(json, 'key'),
      familySlug: _stringOf(json, 'family'),
      notion: _stringOf(json, 'notion'),
      text: _stringOf(json, 'text'),
      meaning: _stringOf(json, 'meaning'),
      example: _stringOf(json, 'example'),
      surface: _stringOf(json, 'surface'),
    );
  }

  /// The explanations of a word entry by help language.
  static Map<String, String> _helpOf(Map<String, Object?> json) {
    final Object? help = json['help'];
    if (help is! Map) return const <String, String>{};
    return <String, String>{
      for (final MapEntry<Object?, Object?> language in help.entries)
        if (language.key case final String code)
          if (language.value case {'explanation': final String text})
            code: text,
    };
  }

  static OperationStatement _statementOf(Map<String, Object?> json) {
    final Object? keys = json['keys'];
    if (keys is! List) throw const FormatException('Missing keys');
    final String operation = _stringOf(json, 'operation');
    return OperationStatement(
      id: _stringOf(json, 'id'),
      text: _stringOf(json, 'text'),
      operation: MathOperator.values.firstWhere(
        (MathOperator value) =>
            value.name == operation &&
            OperationStatement.arithmetic.contains(value),
        orElse: () => throw FormatException('Unknown operation $operation'),
      ),
      wordKeys: keys.whereType<String>().toList(),
    );
  }
}
