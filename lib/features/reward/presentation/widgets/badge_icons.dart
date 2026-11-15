import 'package:flutter/material.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_key.dart';

/// The icon of the badge [key], the same on "Mes badges" and on the
/// celebration of a quiz.
IconData badgeIconOf(String key) {
  return switch (key) {
    BadgeKey.firstStep => Icons.flag_rounded,
    BadgeKey.perfect => Icons.verified_rounded,
    BadgeKey.lightning => Icons.bolt_rounded,
    BadgeKey.sprinter => Icons.timer_rounded,
    BadgeKey.survivor => Icons.favorite_rounded,
    BadgeKey.regular => Icons.local_fire_department_rounded,
    BadgeKey.allFacts => Icons.emoji_events_rounded,
    _ => Icons.military_tech_rounded,
  };
}
