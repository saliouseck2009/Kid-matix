import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:meta/meta.dart';

/// The two players of a duel, one per half of the screen.
///
/// Two profiles, or a profile and a guest; the same profile never holds
/// both halves.
@immutable
final class DuelLineup {
  /// Creates the lineup; throws an [ArgumentError] when [isValid] is
  /// false.
  DuelLineup({required this.top, required this.bottom}) {
    if (!isValid(top: top, bottom: bottom)) {
      throw ArgumentError('Two profiles, or a profile and a guest, needed');
    }
  }

  /// Player of the upside-down half.
  final DuelPlayer top;

  /// Player of the half read the right way up.
  final DuelPlayer bottom;

  /// Whether [top] and [bottom] can play together: at least one profile,
  /// and never the same one twice.
  static bool isValid({required DuelPlayer top, required DuelPlayer bottom}) {
    if (top is GuestDuelPlayer && bottom is GuestDuelPlayer) return false;
    return top.profileId == null || top.profileId != bottom.profileId;
  }

  /// The player of [side].
  DuelPlayer playerOf(DuelSide side) => side == DuelSide.top ? top : bottom;

  /// Returns a copy with the given players replaced.
  DuelLineup copyWith({DuelPlayer? top, DuelPlayer? bottom}) {
    return DuelLineup(top: top ?? this.top, bottom: bottom ?? this.bottom);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DuelLineup && other.top == top && other.bottom == bottom;
  }

  @override
  int get hashCode => Object.hash(top, bottom);
}
