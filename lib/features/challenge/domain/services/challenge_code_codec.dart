import 'package:kid_matix/core/quiz/frozen_question_generator.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_error.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_reading.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_rules.dart';
import 'package:kid_matix/features/challenge/domain/services/code_challenge_rules.dart';

/// Writes a [ChallengeCode] as ten characters a child can copy, and reads
/// it back.
///
/// The alphabet has 31 characters, uppercase, without the ones a child
/// mixes up: no 0 and O, no 1, I and L. A code is 9 data characters, the
/// most significant first, then one check character.
///
/// The 9 data characters hold a 44-bit number (31^9 > 2^44). Its bits,
/// from the lowest:
///
/// | Bits  | Field                                                  |
/// | ----- | ------------------------------------------------------ |
/// | 0–3   | generator version, 1 to 15 (0 is never written)        |
/// | 4–5   | mode: 0 training, 1 training with timer, 2 time attack |
/// | 6–7   | question count: 10, 20, 30 for a training; 0 otherwise |
/// | 8–19  | tables: bit n − 1 set for the table of n, 1 to 12      |
/// | 20–26 | score to beat, 0 to 127                                |
/// | 27–43 | seed of the draw, 0 to 131 071                         |
///
/// The version sits in the lowest bits so that a later version may
/// change every other field: it is read first.
///
/// Check character: with the value v(i) of the character at position i
/// (1 to 10), the sum of i × v(i) is a multiple of 31. As 31 is prime and
/// the positions are below it, any single changed character and any two
/// characters swapped are caught.
final class ChallengeCodeCodec {
  /// Creates the codec.
  const ChallengeCodeCodec();

  /// The 31 characters of a code, in the order of their values.
  static const String alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

  /// Characters of a code.
  static const int length = 10;

  /// Bits of the seed: seeds go from 0 to `1 << seedBits` excluded.
  static const int seedBits = 17;

  /// Highest score a code can carry.
  static const int maxScore = (1 << _scoreBits) - 1;

  static const int _base = 31;
  static const int _dataLength = length - 1;
  static const int _versionBits = 4;
  static const int _modeShift = _versionBits;
  static const int _modeBits = 2;
  static const int _countShift = _modeShift + _modeBits;
  static const int _countBits = 2;
  static const int _tablesShift = _countShift + _countBits;
  static const int _tableBits = 12;
  static const int _scoreShift = _tablesShift + _tableBits;
  static const int _scoreBits = 7;
  static const int _seedShift = _scoreShift + _scoreBits;
  static const int _payloadBits = _seedShift + seedBits;
  static const int _groupLength = 4;
  static const String _groupSeparator = '-';

  /// [input] without spaces and dashes, in uppercase: what the child
  /// typed, ready to read.
  static String normalize(String input) {
    return input.toUpperCase().replaceAll(RegExp(r'[\s\-_]'), '');
  }

  /// [code] cut in groups for reading, such as `K7M2-QX9T-B4`.
  static String format(String code) {
    final StringBuffer buffer = StringBuffer();
    for (int index = 0; index < code.length; index++) {
      if (index > 0 && index % _groupLength == 0) {
        buffer.write(_groupSeparator);
      }
      buffer.write(code[index]);
    }
    return buffer.toString();
  }

  /// Whether [code] fits in a code: a known version, tables from 1 to 12,
  /// a coded question count and a score the game allows.
  bool canEncode(ChallengeCode code) {
    return FrozenQuestionGenerator.supports(code.generatorVersion) &&
        code.generatorVersion < 1 << _versionBits &&
        code.tables.isNotEmpty &&
        code.tables.every((int table) => table >= 1 && table <= _tableBits) &&
        _countIndexOf(code) != null &&
        code.seed >= 0 &&
        code.seed < 1 << seedBits &&
        code.scoreToBeat >= 0 &&
        code.scoreToBeat <= _maxScoreOf(code.questionCount);
  }

  /// The ten characters of [code].
  ///
  /// Throws an [ArgumentError] when [canEncode] is false.
  String encode(ChallengeCode code) {
    if (!canEncode(code)) throw ArgumentError.value(code, 'code');
    final int tables = code.tables.fold(
      0,
      (int bits, int table) => bits | 1 << (table - 1),
    );
    int value =
        code.generatorVersion |
        code.mode.index << _modeShift |
        _countIndexOf(code)! << _countShift |
        tables << _tablesShift |
        code.scoreToBeat << _scoreShift |
        code.seed << _seedShift;
    final List<int> digits = List<int>.filled(_dataLength, 0);
    for (int index = _dataLength - 1; index >= 0; index--) {
      digits[index] = value % _base;
      value ~/= _base;
    }
    return <int>[
      ...digits,
      _checkDigitOf(digits),
    ].map((int digit) => alphabet[digit]).join();
  }

  /// Reads [input], as typed by the child.
  ChallengeCodeReading decode(String input) {
    final String text = normalize(input);
    final List<int> digits = <int>[
      for (final String character in text.split(''))
        alphabet.indexOf(character),
    ];
    if (digits.length != length || digits.contains(-1)) {
      return const ChallengeCodeRejected(ChallengeCodeError.malformed);
    }
    if (_weightedSum(digits) % _base != 0) {
      return const ChallengeCodeRejected(ChallengeCodeError.altered);
    }
    final int value = digits
        .take(_dataLength)
        .fold(0, (int sum, int digit) => sum * _base + digit);
    final int version = value & _maskOf(_versionBits);
    if (value >> _payloadBits != 0 || version == 0) {
      return const ChallengeCodeRejected(ChallengeCodeError.malformed);
    }
    if (!FrozenQuestionGenerator.supports(version)) {
      return const ChallengeCodeRejected(ChallengeCodeError.unknownVersion);
    }
    final ChallengeCode? code = _readFields(value, version);
    return code == null
        ? const ChallengeCodeRejected(ChallengeCodeError.malformed)
        : ChallengeCodeAccepted(code);
  }

  ChallengeCode? _readFields(int value, int version) {
    final int modeIndex = value >> _modeShift & _maskOf(_modeBits);
    final int countIndex = value >> _countShift & _maskOf(_countBits);
    final int tableBits = value >> _tablesShift & _maskOf(_tableBits);
    final int score = value >> _scoreShift & _maskOf(_scoreBits);
    if (modeIndex >= ChallengeCodeMode.values.length || tableBits == 0) {
      return null;
    }
    final ChallengeCodeMode mode = ChallengeCodeMode.values[modeIndex];
    final int? questionCount = _questionCountOf(mode, countIndex);
    if (questionCount == null || score > _maxScoreOf(questionCount)) {
      return null;
    }
    return ChallengeCode(
      tables: <int>[
        for (int table = 1; table <= _tableBits; table++)
          if (tableBits & 1 << (table - 1) != 0) table,
      ],
      mode: mode,
      questionCount: questionCount,
      seed: value >> _seedShift,
      scoreToBeat: score,
      generatorVersion: version,
    );
  }

  /// Index of the question count of [code] in its field, or `null` when
  /// it cannot be coded.
  static int? _countIndexOf(ChallengeCode code) {
    if (!code.mode.isTraining) {
      return code.questionCount == ChallengeRules.timeAttackQuestionCount
          ? 0
          : null;
    }
    final int index = CodeChallengeRules.trainingQuestionCounts.indexOf(
      code.questionCount,
    );
    return index < 0 ? null : index;
  }

  static int? _questionCountOf(ChallengeCodeMode mode, int index) {
    if (!mode.isTraining) {
      return index == 0 ? ChallengeRules.timeAttackQuestionCount : null;
    }
    const List<int> counts = CodeChallengeRules.trainingQuestionCounts;
    return index < counts.length ? counts[index] : null;
  }

  /// Most right answers a game of [questionCount] questions allows.
  static int _maxScoreOf(int questionCount) {
    return questionCount < maxScore ? questionCount : maxScore;
  }

  /// The check character that makes the weighted sum a multiple of 31.
  static int _checkDigitOf(List<int> digits) {
    // 28 is the inverse of 10 modulo 31: 10 × 28 = 280 = 9 × 31 + 1.
    const int inverseOfLastWeight = 28;
    final int sum = _weightedSum(digits) % _base;
    return (_base - sum) * inverseOfLastWeight % _base;
  }

  static int _weightedSum(List<int> digits) {
    int sum = 0;
    for (int index = 0; index < digits.length; index++) {
      sum += (index + 1) * digits[index];
    }
    return sum;
  }

  static int _maskOf(int bits) => (1 << bits) - 1;
}
