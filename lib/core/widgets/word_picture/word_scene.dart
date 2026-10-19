/// The provisional drawing of a math word is a short row of simple
/// elements, with no text in it (many children do not read well yet).
///
/// A scene is data: `WordScenes` maps each word key to its row, and
/// `WordPicturePainter` draws any row. A final illustration replaces a
/// scene, or the whole painter, without touching the screens.
sealed class SceneElement {
  const SceneElement();

  /// Share of the width of the drawing this element takes, relative to the
  /// others.
  double get weight => 1;
}

/// What an item of a pile looks like.
enum SceneItem {
  /// A mango: an orange fruit with a leaf.
  mango,

  /// A marble, whose color is chosen by the tone of the pile.
  marble,

  /// A coin.
  coin,

  /// A square biscuit.
  biscuit,

  /// A chair.
  chair,
}

/// What holds a pile.
enum SceneContainer {
  /// Nothing: the items lie there.
  none,

  /// A basket.
  basket,

  /// A flat plate.
  plate,

  /// An open box.
  box,

  /// A bag.
  bag,

  /// A money jar.
  jar,

  /// A price tag.
  tag,
}

/// How a pile is marked.
enum SceneMark {
  /// Plain.
  none,

  /// Faded and dashed: taken away.
  faded,

  /// Circled: the one the word is about.
  ring,
}

/// A pile of [count] items, possibly in a container.
final class SceneItems extends SceneElement {
  /// Creates a pile.
  const SceneItems(
    this.item,
    this.count, {
    this.container = SceneContainer.none,
    this.mark = SceneMark.none,
    this.tone = 0,
  });

  /// Kind of item.
  final SceneItem item;

  /// How many are drawn; zero draws the empty container.
  final int count;

  /// What holds them.
  final SceneContainer container;

  /// How the pile is marked.
  final SceneMark mark;

  /// Color variant of the items; `-1` alternates two.
  final int tone;
}

/// Where an arrow points.
enum SceneDirection {
  /// To the right: from one thing to the next.
  right,

  /// Upwards: it grows.
  up,

  /// Downwards: it falls in.
  down,
}

/// An arrow between two elements.
final class SceneArrow extends SceneElement {
  /// Creates an arrow.
  const SceneArrow(this.direction);

  /// Where it points.
  final SceneDirection direction;

  @override
  double get weight => 0.6;
}

/// A bar of [cells] cells, the first [filled] colored; the cells from
/// [accentFrom] are of the accent color, and a bar cut in groups of
/// [groupSize] cells shows a gap between the groups.
final class SceneBar extends SceneElement {
  /// Creates a bar.
  const SceneBar(
    this.cells, {
    int? filled,
    this.accentFrom,
    this.groupSize,
    this.mark = SceneMark.none,
  }) : filled = filled ?? cells;

  /// Cells of the bar.
  final int cells;

  /// Cells colored, from the bottom.
  final int filled;

  /// First cell drawn in the accent color, or `null`.
  final int? accentFrom;

  /// Cells in each group, or `null` for a bar in one piece.
  final int? groupSize;

  /// How the bar is marked.
  final SceneMark mark;
}

/// A round shape cut in [parts] equal parts, [shown] of them colored.
final class ScenePie extends SceneElement {
  /// Creates a cut shape.
  const ScenePie(this.parts, this.shown);

  /// Equal parts.
  final int parts;

  /// Parts colored.
  final int shown;
}

/// [count] people, drawn as heads.
final class ScenePeople extends SceneElement {
  /// Creates a row of people.
  const ScenePeople(this.count);

  /// How many.
  final int count;
}

/// A question mark in a bubble: the quantity to find.
final class SceneMystery extends SceneElement {
  /// Creates the bubble.
  const SceneMystery();
}

/// [total] steps of a story, the step [current] marked: the start is the
/// first, the end the last.
final class SceneSteps extends SceneElement {
  /// Creates the steps.
  const SceneSteps(this.total, this.current);

  /// Steps of the story.
  final int total;

  /// The marked step, from 0.
  final int current;
}
