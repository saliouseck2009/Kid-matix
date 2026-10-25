/// The three drawings of the bar model of a word problem (lot F30).
enum BarModelShape {
  /// A whole bar over two parts: putting together, taking away.
  partWhole(<BarRole>[BarRole.whole, BarRole.partA, BarRole.partB]),

  /// Two bars side by side and the gap between them.
  compare(<BarRole>[BarRole.big, BarRole.small, BarRole.gap]),

  /// Equal bars: how many, how big each, and the total.
  groups(<BarRole>[BarRole.total, BarRole.groups, BarRole.each]),

  /// Two bars, the longer being a number of times the shorter: « 2 fois
  /// plus ».
  ratio(<BarRole>[BarRole.big, BarRole.small, BarRole.times]);

  const BarModelShape(this.roles);

  /// The places of the drawing, in the order they are shown.
  final List<BarRole> roles;
}

/// A place of the bar model that holds a number.
enum BarRole {
  /// The whole bar.
  whole,

  /// A part of the whole.
  partA,

  /// The other part of the whole.
  partB,

  /// The longer bar.
  big,

  /// The shorter bar.
  small,

  /// What the longer bar has more than the shorter one.
  gap,

  /// All the groups together.
  total,

  /// How many equal groups.
  groups,

  /// How much in each group.
  each,

  /// How many times the longer bar holds the shorter one.
  times,
}
