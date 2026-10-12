import 'package:meta/meta.dart';

/// XP to give to a player outside a quiz.
@immutable
final class AwardXpParams {
  /// Creates the parameters.
  const AwardXpParams({
    required this.profileId,
    required this.xp,
    required this.sourceKey,
  });

  /// Player who earned the XP.
  final String profileId;

  /// XP earned.
  final int xp;

  /// Game that earned them, such as `duel`.
  final String sourceKey;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AwardXpParams &&
            other.profileId == profileId &&
            other.xp == xp &&
            other.sourceKey == sourceKey;
  }

  @override
  int get hashCode => Object.hash(profileId, xp, sourceKey);
}
