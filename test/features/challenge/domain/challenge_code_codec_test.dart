import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/services/seeded_random_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_error.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_reading.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_code_codec.dart';

ChallengeCode _code({
  List<int> tables = const <int>[2, 5],
  ChallengeCodeMode mode = ChallengeCodeMode.timeAttack,
  int questionCount = 80,
  int seed = 4242,
  int score = 18,
  int version = 1,
}) {
  return ChallengeCode(
    tables: tables,
    mode: mode,
    questionCount: questionCount,
    seed: seed,
    scoreToBeat: score,
    generatorVersion: version,
  );
}

/// Writes the 44-bit [value] with a valid check character, as a newer
/// app could.
String _rawCode(int value) {
  const String alphabet = ChallengeCodeCodec.alphabet;
  final List<int> digits = List<int>.filled(9, 0);
  int rest = value;
  for (int index = 8; index >= 0; index--) {
    digits[index] = rest % 31;
    rest ~/= 31;
  }
  int sum = 0;
  for (int index = 0; index < 9; index++) {
    sum += (index + 1) * digits[index];
  }
  final int check = <int>[
    for (int digit = 0; digit < 31; digit++) digit,
  ].firstWhere((int digit) => (sum + 10 * digit) % 31 == 0);
  return <int>[...digits, check].map((int digit) => alphabet[digit]).join();
}

void main() {
  const ChallengeCodeCodec codec = ChallengeCodeCodec();

  ChallengeCodeError? errorOf(String input) {
    return switch (codec.decode(input)) {
      ChallengeCodeRejected(:final ChallengeCodeError error) => error,
      ChallengeCodeAccepted() => null,
    };
  }

  group('ChallengeCodeCodec', () {
    test('writes ten characters of the alphabet, the layout pinned', () {
      // Act
      final String actualCode = codec.encode(_code());
      // Assert
      expect(actualCode, hasLength(10));
      expect(
        actualCode.split('').every(ChallengeCodeCodec.alphabet.contains),
        isTrue,
      );
      expect(actualCode, '2PQJTF5MPR');
    });
    test('the alphabet has no 0, O, 1, I or L', () {
      // Assert
      expect(ChallengeCodeCodec.alphabet, hasLength(31));
      for (final String character in <String>['0', 'O', '1', 'I', 'L']) {
        expect(ChallengeCodeCodec.alphabet.contains(character), isFalse);
      }
      expect(ChallengeCodeCodec.alphabet.split('').toSet(), hasLength(31));
    });
    test('reads back what it wrote, for every mode and many seeds', () {
      // Arrange
      final SeededRandomSource inputRandom = SeededRandomSource(seed: 1);
      final List<ChallengeCode> inputCodes = <ChallengeCode>[
        for (int index = 0; index < 300; index++) _randomCode(inputRandom),
        _code(tables: <int>[for (int table = 1; table <= 12; table++) table]),
        _code(seed: (1 << ChallengeCodeCodec.seedBits) - 1, score: 80),
        _code(seed: 0, score: 0, tables: <int>[12]),
      ];
      for (final ChallengeCode inputCode in inputCodes) {
        // Act
        final ChallengeCodeReading actualReading = codec.decode(
          codec.encode(inputCode),
        );
        // Assert
        expect(
          actualReading,
          isA<ChallengeCodeAccepted>().having(
            (ChallengeCodeAccepted reading) => reading.code,
            'code',
            inputCode,
          ),
        );
      }
    });
    test('accepts lowercase, spaces and dashes', () {
      // Arrange
      final String inputCode = codec.encode(_code());
      final String inputTyped =
          ' ${ChallengeCodeCodec.format(inputCode).toLowerCase()} ';
      // Act
      final ChallengeCodeReading actualReading = codec.decode(inputTyped);
      // Assert
      expect(actualReading, isA<ChallengeCodeAccepted>());
      expect(ChallengeCodeCodec.format('K7M2QX9TB4'), 'K7M2-QX9T-B4');
    });
    test('refuses every code with one character changed', () {
      // Arrange
      final String inputCode = codec.encode(_code());
      for (int position = 0; position < inputCode.length; position++) {
        for (final String character in ChallengeCodeCodec.alphabet.split('')) {
          if (character == inputCode[position]) continue;
          final String inputAltered = inputCode.replaceRange(
            position,
            position + 1,
            character,
          );
          // Act & Assert
          expect(errorOf(inputAltered), ChallengeCodeError.altered);
        }
      }
    });
    test('refuses every code with two characters swapped', () {
      // Arrange
      final String inputCode = codec.encode(_code());
      for (int first = 0; first < inputCode.length; first++) {
        for (int second = first + 1; second < inputCode.length; second++) {
          if (inputCode[first] == inputCode[second]) continue;
          final List<String> characters = inputCode.split('');
          characters[first] = inputCode[second];
          characters[second] = inputCode[first];
          // Act & Assert
          expect(errorOf(characters.join()), ChallengeCodeError.altered);
        }
      }
    });
    test('refuses a code of an unknown generator version', () {
      // Arrange: version 2, a time attack on the table of 2.
      final String inputCode = _rawCode(2 | 2 << 4 | 1 << 8);
      // Act & Assert
      expect(errorOf(inputCode), ChallengeCodeError.unknownVersion);
    });
    test('refuses what is no code', () {
      // Assert
      expect(errorOf(''), ChallengeCodeError.malformed);
      expect(errorOf('K7M2QX9TB'), ChallengeCodeError.malformed);
      expect(errorOf('K7M2QX9TB44'), ChallengeCodeError.malformed);
      expect(errorOf('K7M2QX9TB0'), ChallengeCodeError.malformed);
      expect(errorOf('K7M2QX9TBO'), ChallengeCodeError.malformed);
      // Version 0, mode 3, no table, a count or score out of range, more
      // than 44 bits: each with a valid check character.
      expect(errorOf(_rawCode(2 << 4 | 1 << 8)), ChallengeCodeError.malformed);
      expect(
        errorOf(_rawCode(1 | 3 << 4 | 1 << 8)),
        ChallengeCodeError.malformed,
      );
      expect(errorOf(_rawCode(1 | 2 << 4)), ChallengeCodeError.malformed);
      expect(
        errorOf(_rawCode(1 | 2 << 4 | 1 << 6 | 1 << 8)),
        ChallengeCodeError.malformed,
      );
      expect(
        errorOf(_rawCode(1 | 3 << 6 | 1 << 8)),
        ChallengeCodeError.malformed,
      );
      expect(
        errorOf(_rawCode(1 | 1 << 8 | 11 << 20)),
        ChallengeCodeError.malformed,
      );
      expect(
        errorOf(_rawCode(1 | 2 << 4 | 1 << 8 | 1 << 44)),
        ChallengeCodeError.malformed,
      );
    });
    test('cannot write a code out of its fields', () {
      // Assert
      expect(codec.canEncode(_code()), isTrue);
      expect(codec.canEncode(_code(version: 2)), isFalse);
      expect(codec.canEncode(_code(tables: <int>[])), isFalse);
      expect(codec.canEncode(_code(tables: <int>[13])), isFalse);
      expect(codec.canEncode(_code(questionCount: 10)), isFalse);
      expect(
        codec.canEncode(
          _code(mode: ChallengeCodeMode.training, questionCount: 15),
        ),
        isFalse,
      );
      expect(codec.canEncode(_code(seed: 1 << 17)), isFalse);
      expect(codec.canEncode(_code(seed: -1)), isFalse);
      expect(codec.canEncode(_code(score: 81)), isFalse);
      expect(codec.canEncode(_code(score: -1)), isFalse);
      expect(() => codec.encode(_code(version: 2)), throwsArgumentError);
    });
  });

  group('ChallengeCode', () {
    test('sorts its tables, keeps each once and compares by value', () {
      // Act
      final ChallengeCode actualCode = _code(tables: <int>[5, 2, 5]);
      // Assert
      expect(actualCode.tables, <int>[2, 5]);
      expect(actualCode, _code());
      expect(actualCode.hashCode, _code().hashCode);
      expect(actualCode.copyWith(scoreToBeat: 3), _code(score: 3));
      expect(actualCode.copyWith(), actualCode);
      expect(actualCode, isNot(_code(seed: 1)));
      expect(actualCode.toString(), contains('timeAttack'));
    });
  });
}

ChallengeCode _randomCode(SeededRandomSource random) {
  final ChallengeCodeMode mode =
      ChallengeCodeMode.values[random.nextInt(ChallengeCodeMode.values.length)];
  final int questionCount = mode.isTraining
      ? <int>[10, 20, 30][random.nextInt(3)]
      : 80;
  return _code(
    tables: <int>[
      for (int table = 1; table <= 12; table++)
        if (random.nextInt(2) == 0) table,
      1 + random.nextInt(12),
    ],
    mode: mode,
    questionCount: questionCount,
    seed: random.nextInt(1 << ChallengeCodeCodec.seedBits),
    score: random.nextInt(questionCount + 1),
  );
}
