/// Amount of XP a player aims to earn each day.
enum DailyGoal {
  /// 20 XP a day: reached in one short session.
  light(xp: 20),

  /// 50 XP a day.
  regular(xp: 50),

  /// 100 XP a day.
  intense(xp: 100);

  const DailyGoal({required this.xp});

  /// XP to earn in one day to reach the goal.
  final int xp;
}
