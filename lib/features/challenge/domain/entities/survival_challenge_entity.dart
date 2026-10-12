import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:meta/meta.dart';

/// The survival game offered to a player.
@immutable
final class SurvivalChallengeEntity {
  /// Creates the challenge.
  const SurvivalChallengeEntity({
    required this.source,
    this.keepsTimerTurnedOff = false,
  });

  /// The game to play.
  final SurvivalSource source;

  /// Whether the player turned the timer off: survival keeps it anyway,
  /// and the challenge says so.
  final bool keepsTimerTurnedOff;

  /// Returns a copy with the given fields replaced.
  SurvivalChallengeEntity copyWith({
    SurvivalSource? source,
    bool? keepsTimerTurnedOff,
  }) {
    return SurvivalChallengeEntity(
      source: source ?? this.source,
      keepsTimerTurnedOff: keepsTimerTurnedOff ?? this.keepsTimerTurnedOff,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SurvivalChallengeEntity &&
            other.source == source &&
            other.keepsTimerTurnedOff == keepsTimerTurnedOff;
  }

  @override
  int get hashCode => Object.hash(source, keepsTimerTurnedOff);
}
