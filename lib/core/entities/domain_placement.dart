import 'package:meta/meta.dart';

/// What one placement test found in one domain, as a class assessment
/// keeps it: the skills of the domain the child had, out of those the
/// test checks there.
@immutable
final class DomainPlacement {
  /// Creates the placement in [domainId].
  const DomainPlacement({
    required this.domainId,
    required this.level,
    required this.skillCount,
  });

  /// Learning domain.
  final String domainId;

  /// Skills of the domain the child had, or `null` when the test stopped
  /// before reaching the domain (not the same as 0).
  final int? level;

  /// Skills the test checks in the domain.
  final int skillCount;

  /// Share of the skills acquired, from 0 to 1, or `null` when the
  /// domain was not reached.
  double? get share {
    final int? reached = level;
    if (reached == null) return null;
    return skillCount == 0 ? 0 : reached / skillCount;
  }

  /// Returns a copy with the given fields replaced.
  DomainPlacement copyWith({String? domainId, int? level, int? skillCount}) {
    return DomainPlacement(
      domainId: domainId ?? this.domainId,
      level: level ?? this.level,
      skillCount: skillCount ?? this.skillCount,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DomainPlacement &&
            other.domainId == domainId &&
            other.level == level &&
            other.skillCount == skillCount;
  }

  @override
  int get hashCode => Object.hash(domainId, level, skillCount);

  @override
  String toString() => 'DomainPlacement($domainId, $level/$skillCount)';
}
