import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Languages translated from the French template.
const List<String> _translations = <String>['en', 'es'];

const String _noBreakSpace = ' ';

Map<String, Object?> _readArb(String locale) {
  return jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
      as Map<String, Object?>;
}

/// Texts of an ARB file by key, without its metadata.
Map<String, String> _textsOf(Map<String, Object?> arb) {
  return <String, String>{
    for (final MapEntry<String, Object?> entry in arb.entries)
      if (!entry.key.startsWith('@')) entry.key: entry.value! as String,
  };
}

/// Names of the placeholders [text] uses, with the ICU `plural` and
/// `select` messages read case by case.
Set<String> _placeholdersOf(String text) {
  final _IcuReader reader = _IcuReader(text);
  reader.readMessage();
  return reader.names;
}

/// Reads an ICU message: `{name}` is a placeholder, `{name, plural, ...}`
/// and `{name, select, ...}` hold one message per case.
final class _IcuReader {
  _IcuReader(this._text);

  final String _text;
  int _index = 0;
  final Set<String> names = <String>{};

  /// Reads up to the `}` closing the current message, or the end.
  void readMessage() {
    while (_index < _text.length && _text[_index] != '}') {
      if (_text[_index] == '{') {
        _index++;
        _readArgument();
      } else {
        _index++;
      }
    }
  }

  void _readArgument() {
    final String name = _readUntil(',}').trim();
    names.add(name);
    if (_text[_index++] == '}') return;
    _readUntil(',');
    _index++;
    while (true) {
      final String selector = _readUntil('{}').trim();
      if (_text[_index] == '}' || selector.isEmpty) break;
      _index++;
      readMessage();
      _index++;
    }
    _index++;
  }

  String _readUntil(String stops) {
    final int start = _index;
    while (!stops.contains(_text[_index])) {
      _index++;
    }
    return _text.substring(start, _index);
  }
}

void main() {
  final Map<String, Object?> template = _readArb('fr');
  final Map<String, String> frenchTexts = _textsOf(template);

  group('Translation files', () {
    test('placeholders are read inside plural and select cases', () {
      // Act
      final Set<String> actualNames = _placeholdersOf(
        'Hi {name}: {count, plural, =1{one star} other{{count} of {total}}} '
        '{kind, select, golden{gold {name}} other{plain}}',
      );
      // Assert
      expect(actualNames, <String>{'name', 'count', 'total', 'kind'});
    });

    for (final String locale in _translations) {
      final Map<String, Object?> arb = _readArb(locale);
      final Map<String, String> texts = _textsOf(arb);

      test('app_$locale.arb declares its locale', () {
        // Assert
        expect(arb['@@locale'], locale);
      });

      test('app_$locale.arb has every key of app_fr.arb and no other', () {
        // Assert
        expect(texts.keys.toSet(), frenchTexts.keys.toSet());
      });

      test('app_$locale.arb keeps the placeholders of each text', () {
        // Act
        final List<String> actualMismatches = <String>[
          for (final String key in frenchTexts.keys)
            if (texts[key] case final String text)
              if (!_samePlaceholders(text, frenchTexts[key]!)) key,
        ];
        // Assert
        expect(actualMismatches, isEmpty);
      });

      test('app_$locale.arb has no French no-break space', () {
        // Act
        final List<String> actualKeys = <String>[
          for (final MapEntry<String, String> entry in texts.entries)
            if (entry.value.contains(_noBreakSpace)) entry.key,
        ];
        // Assert
        expect(actualKeys, isEmpty);
      });
    }

    test('app_es.arb closes every ¿ and ¡ it opens', () {
      // Arrange
      final Map<String, String> spanishTexts = _textsOf(_readArb('es'));
      // Act
      final List<String> actualKeys = <String>[
        for (final MapEntry<String, String> entry in spanishTexts.entries)
          if ('¿'.allMatches(entry.value).length >
                  '?'.allMatches(entry.value).length ||
              '¡'.allMatches(entry.value).length >
                  '!'.allMatches(entry.value).length)
            entry.key,
      ];
      // Assert
      expect(actualKeys, isEmpty);
    });

    test('every placeholder of app_fr.arb is declared', () {
      // Act
      final List<String> actualUndeclared = <String>[
        for (final MapEntry<String, String> entry in frenchTexts.entries)
          if (!_samePlaceholders(
            _declaredPlaceholders(template, entry.key).map((String name) {
              return '{$name}';
            }).join(),
            entry.value,
          ))
            entry.key,
      ];
      // Assert
      expect(actualUndeclared, isEmpty);
    });
  });
}

bool _samePlaceholders(String first, String second) {
  final Set<String> firstNames = _placeholdersOf(first);
  final Set<String> secondNames = _placeholdersOf(second);
  return firstNames.length == secondNames.length &&
      firstNames.containsAll(secondNames);
}

Iterable<String> _declaredPlaceholders(
  Map<String, Object?> template,
  String key,
) {
  final Object? metadata = template['@$key'];
  if (metadata is! Map<String, Object?>) return const <String>[];
  final Object? placeholders = metadata['placeholders'];
  if (placeholders is! Map<String, Object?>) return const <String>[];
  return placeholders.keys;
}
