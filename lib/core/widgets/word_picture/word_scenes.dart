import 'package:kid_matix/core/widgets/word_picture/word_scene.dart';

/// The provisional scene of each math word, by key (the ideas of the
/// "Idée d'image" column of `docs/product/math-words.md`).
abstract final class WordScenes {
  /// The scene of the word [wordKey]; a question mark for a word that
  /// has none yet, so a new word never draws nothing.
  static List<SceneElement> of(String wordKey) {
    return _scenes[wordKey] ?? fallback;
  }

  /// Whether the word has its own scene.
  static bool has(String wordKey) => _scenes.containsKey(wordKey);

  /// Keys of the words that have a scene.
  static Iterable<String> get wordKeys => _scenes.keys;

  /// Scene of a word without one.
  static const List<SceneElement> fallback = <SceneElement>[SceneMystery()];

  static const SceneArrow _right = SceneArrow(SceneDirection.right);
  static const SceneArrow _up = SceneArrow(SceneDirection.up);
  static const SceneArrow _down = SceneArrow(SceneDirection.down);

  static const Map<String, List<SceneElement>> _scenes =
      <String, List<SceneElement>>{
        // Add.
        'ajouter': <SceneElement>[
          SceneItems(SceneItem.mango, 3),
          _right,
          SceneItems(SceneItem.mango, 7, container: SceneContainer.basket),
        ],
        'en_plus': <SceneElement>[
          SceneItems(SceneItem.mango, 6, container: SceneContainer.basket),
          SceneItems(SceneItem.mango, 4, mark: SceneMark.ring),
        ],
        'en_tout': <SceneElement>[
          SceneItems(SceneItem.mango, 3),
          SceneItems(SceneItem.mango, 4),
          _right,
          SceneItems(
            SceneItem.mango,
            7,
            container: SceneContainer.basket,
            mark: SceneMark.ring,
          ),
        ],
        'ensemble': <SceneElement>[
          SceneItems(SceneItem.marble, 4),
          SceneItems(SceneItem.marble, 3, tone: 1),
          _right,
          SceneItems(
            SceneItem.marble,
            7,
            container: SceneContainer.box,
            tone: -1,
          ),
        ],
        'gagner': <SceneElement>[
          SceneItems(SceneItem.coin, 1),
          _down,
          SceneItems(SceneItem.coin, 6, container: SceneContainer.jar),
        ],
        'recevoir': <SceneElement>[
          SceneItems(SceneItem.mango, 3),
          _right,
          SceneItems(SceneItem.mango, 5, container: SceneContainer.basket),
        ],
        'augmenter': <SceneElement>[
          SceneItems(SceneItem.coin, 3, container: SceneContainer.tag),
          _up,
        ],
        // Remove.
        'enlever': <SceneElement>[
          SceneItems(SceneItem.marble, 4),
          SceneItems(SceneItem.marble, 3, mark: SceneMark.faded),
        ],
        'il_reste': <SceneElement>[
          SceneItems(
            SceneItem.mango,
            6,
            container: SceneContainer.basket,
            mark: SceneMark.ring,
          ),
          SceneItems(SceneItem.mango, 4, mark: SceneMark.faded),
        ],
        'retirer': <SceneElement>[
          SceneItems(SceneItem.marble, 5, container: SceneContainer.box),
          _right,
          SceneItems(SceneItem.marble, 2),
        ],
        'vendre': <SceneElement>[
          SceneItems(SceneItem.mango, 4),
          _right,
          SceneItems(SceneItem.coin, 2),
        ],
        'donner': <SceneElement>[
          SceneItems(SceneItem.mango, 2, container: SceneContainer.basket),
          _right,
          SceneItems(SceneItem.mango, 2, container: SceneContainer.basket),
        ],
        'perdre': <SceneElement>[
          SceneItems(SceneItem.marble, 5, container: SceneContainer.bag),
          _down,
          SceneItems(SceneItem.marble, 1, mark: SceneMark.faded),
        ],
        'acheter': <SceneElement>[
          SceneItems(SceneItem.coin, 3),
          _right,
          SceneItems(SceneItem.mango, 3, container: SceneContainer.basket),
        ],
        // Compare.
        'de_plus_que': <SceneElement>[SceneBar(8, accentFrom: 5), SceneBar(5)],
        'de_moins_que': <SceneElement>[
          SceneBar(9),
          SceneBar(5, mark: SceneMark.ring),
        ],
        'autant_que': <SceneElement>[SceneBar(6), SceneBar(6)],
        'le_plus_grand': <SceneElement>[
          SceneBar(3),
          SceneBar(6, mark: SceneMark.ring),
          SceneBar(4),
        ],
        'le_plus_petit': <SceneElement>[
          SceneBar(5),
          SceneBar(2, mark: SceneMark.ring),
          SceneBar(7),
        ],
        'difference': <SceneElement>[SceneBar(9, accentFrom: 4), SceneBar(4)],
        'egal': <SceneElement>[
          SceneBar(5, mark: SceneMark.ring),
          SceneBar(5, mark: SceneMark.ring),
        ],
        // Group.
        'par_paquets_de': <SceneElement>[
          SceneItems(SceneItem.biscuit, 4, container: SceneContainer.box),
          SceneItems(SceneItem.biscuit, 4, container: SceneContainer.box),
          SceneItems(SceneItem.biscuit, 4, container: SceneContainer.box),
        ],
        'chacun': <SceneElement>[
          SceneItems(SceneItem.marble, 3, container: SceneContainer.plate),
          SceneItems(SceneItem.marble, 3, container: SceneContainer.plate),
          SceneItems(SceneItem.marble, 3, container: SceneContainer.plate),
          SceneItems(SceneItem.marble, 3, container: SceneContainer.plate),
        ],
        'fois': <SceneElement>[
          SceneItems(SceneItem.marble, 3),
          SceneItems(SceneItem.marble, 3),
          SceneItems(SceneItem.marble, 3),
          SceneItems(SceneItem.marble, 3),
        ],
        'dans_chaque': <SceneElement>[
          SceneItems(SceneItem.mango, 4, container: SceneContainer.basket),
          SceneItems(SceneItem.mango, 4, container: SceneContainer.basket),
          SceneItems(SceneItem.mango, 4, container: SceneContainer.basket),
        ],
        'rangee': <SceneElement>[
          SceneItems(SceneItem.chair, 4),
          SceneItems(SceneItem.chair, 4),
          SceneItems(SceneItem.chair, 4),
        ],
        'double': <SceneElement>[
          SceneItems(SceneItem.marble, 5),
          SceneItems(SceneItem.marble, 5),
        ],
        // Share.
        'partager': <SceneElement>[
          SceneItems(SceneItem.mango, 6, container: SceneContainer.basket),
          _right,
          SceneItems(SceneItem.mango, 0, container: SceneContainer.plate),
          SceneItems(SceneItem.mango, 0, container: SceneContainer.plate),
          SceneItems(SceneItem.mango, 0, container: SceneContainer.plate),
        ],
        'partager_egalement': <SceneElement>[
          SceneItems(SceneItem.mango, 2, container: SceneContainer.plate),
          SceneItems(SceneItem.mango, 2, container: SceneContainer.plate),
          SceneItems(SceneItem.mango, 2, container: SceneContainer.plate),
        ],
        'repartir': <SceneElement>[
          SceneItems(SceneItem.marble, 3, container: SceneContainer.bag),
          SceneItems(SceneItem.marble, 3, container: SceneContainer.bag),
          SceneItems(SceneItem.marble, 3, container: SceneContainer.bag),
          SceneItems(SceneItem.marble, 3, container: SceneContainer.bag),
        ],
        'par_personne': <SceneElement>[
          SceneItems(SceneItem.mango, 12, container: SceneContainer.basket),
          _right,
          ScenePeople(4),
        ],
        'diviser': <SceneElement>[ScenePie(3, 3)],
        'moitie': <SceneElement>[ScenePie(2, 1)],
        'quart': <SceneElement>[ScenePie(4, 1)],
        // Questions.
        'combien': <SceneElement>[
          SceneItems(SceneItem.mango, 5, container: SceneContainer.basket),
          SceneMystery(),
        ],
        'combien_de_fois': <SceneElement>[SceneBar(12, groupSize: 3)],
        'total': <SceneElement>[
          SceneItems(SceneItem.mango, 3),
          SceneItems(SceneItem.mango, 4),
          _down,
          SceneItems(SceneItem.mango, 7, mark: SceneMark.ring),
        ],
        'au_depart': <SceneElement>[SceneSteps(3, 0)],
        'a_la_fin': <SceneElement>[SceneSteps(3, 2)],
        'apres': <SceneElement>[SceneSteps(3, 1)],
      };
}
