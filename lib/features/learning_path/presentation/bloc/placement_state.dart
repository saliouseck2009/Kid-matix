import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_test_entity.dart';
import 'package:meta/meta.dart';

/// State of the placement test screen.
@immutable
sealed class PlacementState {
  const PlacementState();
}

/// The test is offered, with « Passer ».
final class PlacementOffered extends PlacementState {
  /// Creates the state.
  const PlacementOffered();
}

/// The test is being built.
final class PlacementLoading extends PlacementState {
  /// Creates the state.
  const PlacementLoading();
}

/// A question is asked.
final class PlacementAsking extends PlacementState {
  /// Creates the state of question [index] of [test].
  const PlacementAsking({
    required this.test,
    required this.index,
    required this.askedAt,
    this.knownUnitKeys = const <String>{},
    this.typedDigits = '',
    this.isSubmitting = false,
  });

  /// Most digits the keypad accepts; every answer of the test fits.
  static const int maxTypedDigits = 3;

  /// The test.
  final PlacementTestEntity test;

  /// Rank of the question asked, from 0.
  final int index;

  /// When the question was shown.
  final DateTime askedAt;

  /// Units found so far.
  final Set<String> knownUnitKeys;

  /// Digits typed so far.
  final String typedDigits;

  /// Whether the answer is being recorded; the keys wait meanwhile.
  final bool isSubmitting;

  /// Question asked.
  PlacementQuestionEntity get question => test.questions[index];

  /// Whether this is the last question.
  bool get isLast => index == test.questions.length - 1;

  /// Returns the state with [digit] typed after the others; a leading 0
  /// is replaced, and digits past [maxTypedDigits] are ignored.
  PlacementAsking withDigit(int digit) {
    if (typedDigits.length >= maxTypedDigits) return this;
    final String kept = typedDigits == '0' ? '' : typedDigits;
    return copyWith(typedDigits: '$kept$digit');
  }

  /// Returns the state with the last typed digit erased.
  PlacementAsking withoutLastDigit() {
    if (typedDigits.isEmpty) return this;
    return copyWith(
      typedDigits: typedDigits.substring(0, typedDigits.length - 1),
    );
  }

  /// Returns a copy with the given fields replaced.
  PlacementAsking copyWith({
    int? index,
    DateTime? askedAt,
    Set<String>? knownUnitKeys,
    String? typedDigits,
    bool? isSubmitting,
  }) {
    return PlacementAsking(
      test: test,
      index: index ?? this.index,
      askedAt: askedAt ?? this.askedAt,
      knownUnitKeys: knownUnitKeys ?? this.knownUnitKeys,
      typedDigits: typedDigits ?? this.typedDigits,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Every question was answered: the tables found are open.
final class PlacementFinished extends PlacementState {
  /// Creates the state of [test], where the units of [knownUnitKeys] were
  /// found.
  const PlacementFinished({required this.test, required this.knownUnitKeys});

  /// The test.
  final PlacementTestEntity test;

  /// Units found, now open on the path.
  final Set<String> knownUnitKeys;

  /// Numbers and keys of the units of the test, each with whether it
  /// was found.
  List<({int number, String unitKey, bool isKnown})> get units {
    return <({int number, String unitKey, bool isKnown})>[
      for (final PlacementQuestionEntity question in test.questions)
        (
          number: question.unitNumber,
          unitKey: question.unitKey,
          isKnown: knownUnitKeys.contains(question.unitKey),
        ),
    ];
  }
}

/// The test could not be built or an answer not recorded.
final class PlacementFailure extends PlacementState {
  /// Creates the state for [errorCode].
  const PlacementFailure({required this.errorCode});

  /// Reason of the failure.
  final AppErrorCode errorCode;
}
