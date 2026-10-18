import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/seeded_draw.dart';
import 'package:kid_matix/core/services/seeded_random_source.dart';

/// Turns a [SeededDraw] into questions, the same on every phone.
///
/// Each version is frozen: once released, the questions of a seed never
/// change, since codes shared between phones depend on them. A change of
/// the draw, of [SeededRandomSource] or of the way a domain builds its
/// questions that alters the golden list of a version needs a new
/// version, and the old one kept. The player's mastery plays no part.
///
/// Version 1, from the items and question types given, in their order:
/// 1. a [SeededRandomSource] starts from the seed;
/// 2. the items are dealt in decks: each deck is the items shuffled, and
///    when a deck would start with the item that ended the previous one,
///    its first two items swap; the decks follow each other until the
///    question count is reached;
/// 3. then, item after item, a question type is drawn among the types the
///    domain supports, and the domain builds the question with the same
///    source.
final class FrozenQuestionGenerator {
  /// Creates the generator.
  const FrozenQuestionGenerator();

  /// Version used for the new draws.
  static const int currentVersion = 1;

  /// Versions this generator can play.
  static const List<int> versions = <int>[1];

  /// Whether this generator can play the draws of [version].
  static bool supports(int version) => versions.contains(version);

  /// The [questionCount] questions of [draw] among [itemKeys] of
  /// [domain], with types among [questionTypeIds].
  ///
  /// Throws an [ArgumentError] for an unknown version or item, when no
  /// item is given or when the domain supports none of the types.
  List<Question> generate({
    required LearningDomain domain,
    required List<String> itemKeys,
    required List<String> questionTypeIds,
    required int questionCount,
    required SeededDraw draw,
  }) {
    if (!supports(draw.version)) {
      throw ArgumentError.value(draw.version, 'draw', 'Unknown version');
    }
    final List<LearningItem> items = _findItems(domain, itemKeys);
    final List<String> typeIds = questionTypeIds
        .where(domain.questionTypeIds.contains)
        .toList();
    if (items.isEmpty || typeIds.isEmpty) {
      throw ArgumentError('No item or no supported question type');
    }
    final SeededRandomSource random = SeededRandomSource(seed: draw.seed);
    return _deal(items, questionCount, random)
        .map(
          (LearningItem item) => domain.buildQuestion(
            item: item,
            questionTypeId: typeIds[random.nextInt(typeIds.length)],
            random: random,
          ),
        )
        .toList();
  }

  List<LearningItem> _findItems(LearningDomain domain, List<String> keys) {
    return <LearningItem>[
      for (final String key in keys)
        domain.findItem(key) ??
            (throw ArgumentError.value(key, 'itemKeys', 'Unknown item')),
    ];
  }

  /// [count] items dealt deck after deck, never twice in a row at the
  /// joint of two decks.
  List<LearningItem> _deal(
    List<LearningItem> items,
    int count,
    SeededRandomSource random,
  ) {
    final List<LearningItem> dealt = <LearningItem>[];
    while (dealt.length < count) {
      final List<LearningItem> deck = random.shuffled(items);
      if (dealt.isNotEmpty && deck.length > 1 && deck.first == dealt.last) {
        deck
          ..[0] = deck[1]
          ..[1] = dealt.last;
      }
      dealt.addAll(deck);
    }
    return dealt.take(count).toList();
  }
}
