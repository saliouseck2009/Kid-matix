import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_journey.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_outcome.dart';
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

/// A question is being built.
final class PlacementLoading extends PlacementState {
  /// Creates the state.
  const PlacementLoading();
}

/// A question is asked.
final class PlacementAsking extends PlacementState {
  /// Creates the state of [question], the next one of [journey].
  const PlacementAsking({
    required this.journey,
    required this.question,
    required this.askedAt,
    this.typedDigits = '',
    this.isSubmitting = false,
  });

  /// Most digits the keypad accepts; every answer of the test fits.
  static const int maxTypedDigits = 3;

  /// Where the test stands: the skill and the typical question asked.
  final PlacementJourney journey;

  /// Question asked.
  final Question question;

  /// When the question was shown.
  final DateTime askedAt;

  /// Digits typed so far.
  final String typedDigits;

  /// Whether the answer is being recorded; the keys wait meanwhile.
  final bool isSubmitting;

  /// Learning domain of the question.
  String get domainId => journey.skill!.domainId;

  /// Fraction of the skills climbed, for the progress bar: the skill being
  /// asked, and how far in it.
  double get progress {
    final int skillCount = journey.skills.length;
    final int probeCount = journey.skill!.probeUnitKeys.length;
    return (journey.skillIndex + journey.probeIndex / probeCount) / skillCount;
  }

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
  PlacementAsking copyWith({String? typedDigits, bool? isSubmitting}) {
    return PlacementAsking(
      journey: journey,
      question: question,
      askedAt: askedAt,
      typedDigits: typedDigits ?? this.typedDigits,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// The test is over: its result is kept and the units found are open.
final class PlacementFinished extends PlacementState {
  /// Creates the state of the [outcome].
  const PlacementFinished({required this.outcome});

  /// What the test found.
  final PlacementOutcome outcome;
}

/// The test could not be built or an answer not recorded.
final class PlacementFailure extends PlacementState {
  /// Creates the state for [errorCode].
  const PlacementFailure({required this.errorCode});

  /// Reason of the failure.
  final AppErrorCode errorCode;
}
