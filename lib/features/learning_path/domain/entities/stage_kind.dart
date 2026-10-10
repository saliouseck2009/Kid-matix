/// The stages of the learning path.
///
/// Each table has the five first ones, in this order; a review stage
/// follows every group of 3 tables.
enum StageKind {
  /// 1. The whole table and its tip, then its 10 facts in order.
  discovery,

  /// 2. The 10 facts shuffled, answers to pick.
  training,

  /// 3. The 10 facts shuffled, answers to write.
  writing,

  /// 4. The 10 facts shuffled, every format, 10 seconds each.
  speed,

  /// 5. The boss fight of the table, delivered with lot F6.
  boss,

  /// 15 questions mixing the tables seen so far.
  review,
}
