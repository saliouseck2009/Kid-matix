import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_draw.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_ref.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';

/// The word problems of `docs/product/problems.md`, in the order of the
/// table. `test/features/problem/` checks this list against the table:
/// keys, levels, operations, shapes, roles, fixed numbers, statements.
///
/// Keys never change once released. A trap is a problem whose keyword
/// suggests another operation than the real one; `trapOf` names its twin.
/// The shape helpers below carry the roles of each form of the table.
abstract final class ProblemTemplates {
  static const ProblemRef _a = ProblemRef.variable('a');
  static const ProblemRef _b = ProblemRef.variable('b');
  static const ProblemRef _r = ProblemRef.variable('r');

  /// Every problem, level 1 first.
  static final List<ProblemTemplate> all = List<ProblemTemplate>.unmodifiable(
    <ProblemTemplate>[
      // Level 1: with images.
      _takeAway(
        key: 'mangues_donnees',
        level: 1,
        statement:
            'Awa a {a} mangues. Elle en donne {b} à sa petite sœur. Combien '
            'de mangues lui reste-t-il\u00a0?',
        check:
            "Vérifie\u00a0: {b} + {r} = {a}, c'est bien le nombre de mangues "
            "d'Awa.",
        fixed: <String, int>{'a': 12, 'b': 5, 'r': 7},
        draws: <ProblemDraw>[
          _range('a', 6, 20),
          _rangeTo('b', 2, (ProblemValues v) => v['a']! - 2),
          _difference(),
        ],
      ),
      _takeAwayWhole(
        key: 'mangues_donnees_piege',
        level: 1,
        statement:
            'Awa donne {b} mangues à sa petite sœur. Il lui en reste {a}. '
            'Combien de mangues avait-elle au départ\u00a0?',
        check:
            "Vérifie\u00a0: {a} + {b} = {r}, c'est bien le nombre de mangues "
            "d'Awa au départ.",
        fixed: <String, int>{'a': 7, 'b': 5, 'r': 12},
        draws: <ProblemDraw>[
          _range('a', 2, 18),
          _rangeTo('b', 2, (ProblemValues v) => 20 - v['a']!),
          _sum(),
        ],
        trapOf: 'mangues_donnees',
      ),
      _together(
        key: 'billes_recues',
        level: 1,
        statement:
            'Mamadou a {a} billes. Il reçoit {b} billes de son ami. Combien '
            'de billes a-t-il maintenant\u00a0?',
        check:
            'Vérifie\u00a0: {a} + {b} = {r}, Mamadou a plus de billes '
            "qu'avant.",
        fixed: <String, int>{'a': 6, 'b': 4, 'r': 10},
        draws: <ProblemDraw>[
          _range('a', 2, 10),
          _range('b', 2, 10),
          _sum(),
        ],
      ),
      _groups(
        key: 'mangues_caisses',
        level: 1,
        statement:
            'Au marché, Fatou a {a} caisses. Dans chaque caisse, il y a {b} '
            'mangues. Combien de mangues a-t-elle\u00a0?',
        check:
            "Vérifie\u00a0: {a} × {b} = {r}, c'est bien le nombre de mangues "
            'de Fatou.',
        fixed: <String, int>{'a': 3, 'b': 5, 'r': 15},
        draws: <ProblemDraw>[
          _range('a', 2, 5),
          _range('b', 2, 5),
          _product(),
        ],
      ),
      _share(
        key: 'mangues_partagees',
        level: 1,
        statement:
            'Fatou a {a} mangues. Elle les partage également entre {b} amis. '
            'Combien de mangues reçoit chacun\u00a0?',
        check: 'Vérifie\u00a0: {b} × {r} = {a}, chaque ami a bien {r} mangues.',
        fixed: <String, int>{'a': 12, 'b': 3, 'r': 4},
        draws: <ProblemDraw>[
          _range('b', 2, 5),
          _range('r', 2, 5),
          _dividend(),
        ],
      ),
      _share(
        key: 'chaises_tabaski',
        level: 1,
        statement:
            'Pour la Tabaski, Awa a {a} chaises. Elle les range en {b} '
            'rangées égales. Combien de chaises y a-t-il dans chaque '
            'rangée\u00a0?',
        check: 'Vérifie\u00a0: {b} × {r} = {a}, il y a bien {a} chaises.',
        fixed: <String, int>{'a': 10, 'b': 2, 'r': 5},
        draws: <ProblemDraw>[
          _range('b', 2, 4),
          _range('r', 2, 5),
          _dividend(),
        ],
      ),
      _takeAway(
        key: 'car_personnes',
        level: 1,
        statement:
            'Dans le car rapide, il y a {a} personnes. {b} personnes '
            'descendent. Il reste combien de personnes\u00a0?',
        check: 'Vérifie\u00a0: {b} + {r} = {a} personnes.',
        fixed: <String, int>{'a': 9, 'b': 4, 'r': 5},
        draws: <ProblemDraw>[
          _range('a', 5, 20),
          _rangeTo('b', 1, (ProblemValues v) => v['a']! - 1),
          _difference(),
        ],
      ),
      _share(
        key: 'sucre_theieres',
        level: 1,
        statement:
            'Mamadou a {a} morceaux de sucre. Il les répartit dans {b} '
            'théières, le même nombre dans chaque. Combien de morceaux y '
            'a-t-il dans chaque théière\u00a0?',
        check: 'Vérifie\u00a0: {b} × {r} = {a} morceaux.',
        fixed: <String, int>{'a': 8, 'b': 2, 'r': 4},
        draws: <ProblemDraw>[
          _range('b', 2, 4),
          _range('r', 2, 5),
          _dividend(),
        ],
      ),
      _groups(
        key: 'biscuits_en_tout_piege',
        level: 1,
        statement:
            'Aminata achète {a} paquets de {b} biscuits. Combien de biscuits '
            'a-t-elle en tout\u00a0?',
        check: 'Vérifie\u00a0: {a} × {b} = {r} biscuits.',
        fixed: <String, int>{'a': 5, 'b': 3, 'r': 15},
        draws: <ProblemDraw>[
          _range('a', 2, 5),
          _range('b', 2, 5),
          _product(),
        ],
        trapOf: 'mangues_caisses',
      ),
      _takeAway(
        key: 'pains_vendus',
        level: 1,
        statement:
            'Aminata a {a} pains. Elle en vend {b} au marché. Combien de '
            'pains lui reste-t-il\u00a0?',
        check: 'Vérifie\u00a0: {b} + {r} = {a} pains.',
        fixed: <String, int>{'a': 10, 'b': 4, 'r': 6},
        draws: <ProblemDraw>[
          _range('a', 5, 20),
          _rangeTo('b', 1, (ProblemValues v) => v['a']! - 1),
          _difference(),
        ],
      ),
      // Level 2: short sentence.
      _groups(
        key: 'billes_chacun_piege',
        level: 2,
        statement:
            'Chacun des {a} enfants reçoit {b} billes. Combien de billes '
            'faut-il\u00a0?',
        check: 'Vérifie\u00a0: {a} × {b} = {r} billes.',
        fixed: <String, int>{'a': 4, 'b': 6, 'r': 24},
        draws: <ProblemDraw>[
          _range('a', 2, 9),
          _range('b', 2, 9),
          _product(),
        ],
        trapOf: 'billes_sacs',
      ),
      _groups(
        key: 'billes_sacs',
        level: 2,
        statement:
            'Il y a {a} sacs. Dans chaque sac, il y a {b} billes. Combien de '
            'billes y a-t-il\u00a0?',
        check: 'Vérifie\u00a0: {a} × {b} = {r} billes.',
        fixed: <String, int>{'a': 4, 'b': 6, 'r': 24},
        draws: <ProblemDraw>[
          _range('a', 2, 9),
          _range('b', 2, 9),
          _product(),
        ],
      ),
      _count(
        key: 'tas_fois_piege',
        level: 2,
        statement:
            'Awa a {a} billes. Combien de fois peut-elle faire un tas de {b} '
            'billes\u00a0?',
        check: 'Vérifie\u00a0: {b} × {r} = {a} billes.',
        fixed: <String, int>{'a': 24, 'b': 3, 'r': 8},
        draws: <ProblemDraw>[
          _range('b', 2, 5),
          _range('r', 2, 9),
          _dividend(),
        ],
        trapOf: 'billes_tas',
      ),
      _count(
        key: 'billes_tas',
        level: 2,
        statement:
            'Awa a {a} billes. Elle fait des tas de {b} billes. Combien de '
            'tas peut-elle faire\u00a0?',
        check: 'Vérifie\u00a0: {b} × {r} = {a} billes.',
        fixed: <String, int>{'a': 24, 'b': 3, 'r': 8},
        draws: <ProblemDraw>[
          _range('b', 2, 5),
          _range('r', 2, 9),
          _dividend(),
        ],
      ),
      _together(
        key: 'moussa_paniers',
        level: 2,
        statement:
            'Moussa met ensemble ses {a} et ses {b} mangues dans un grand '
            'panier. Combien de mangues y a-t-il dans le grand panier\u00a0?',
        check: 'Vérifie\u00a0: {a} + {b} = {r} mangues.',
        fixed: <String, int>{'a': 18, 'b': 15, 'r': 33},
        draws: <ProblemDraw>[
          _range('a', 5, 30),
          _range('b', 5, 30),
          _sum(),
        ],
      ),
      _takeAway(
        key: 'fatou_sachets',
        level: 2,
        statement:
            "Fatou a {a} sachets d'eau. Elle en vend {b} au marché. Combien "
            'lui en reste-t-il\u00a0?',
        check: 'Vérifie\u00a0: {b} + {r} = {a} sachets.',
        fixed: <String, int>{'a': 36, 'b': 14, 'r': 22},
        draws: <ProblemDraw>[
          _range('a', 10, 50),
          _rangeTo('b', 1, (ProblemValues v) => v['a']! - 2),
          _difference(),
        ],
      ),
      _compareGap(
        key: 'billes_difference',
        level: 2,
        statement:
            'Mamadou a {b} billes. Ibrahima en a {a}. Quelle est la '
            'différence entre leurs billes\u00a0?',
        check: 'Vérifie\u00a0: {b} + {r} = {a} billes.',
        fixed: <String, int>{'a': 8, 'b': 5, 'r': 3},
        draws: <ProblemDraw>[
          _range('a', 5, 30),
          _rangeTo('b', 1, (ProblemValues v) => v['a']! - 1),
          _difference(),
        ],
      ),
      _share(
        key: 'biscuits_range',
        level: 2,
        statement:
            'Aminata a {a} biscuits. Elle les range en {b} paquets égaux. '
            'Combien de biscuits y a-t-il dans chaque paquet\u00a0?',
        check: 'Vérifie\u00a0: {b} × {r} = {a} biscuits.',
        fixed: <String, int>{'a': 48, 'b': 6, 'r': 8},
        draws: <ProblemDraw>[
          _range('b', 2, 6),
          _range('r', 2, 9),
          _dividend(),
        ],
      ),
      _together(
        key: 'mamadou_gagne',
        level: 2,
        statement:
            'Au départ, Mamadou a {a} billes. Il joue et gagne {b} billes. '
            'Après le jeu, combien en a-t-il\u00a0?',
        check: 'Vérifie\u00a0: {a} + {b} = {r} billes.',
        fixed: <String, int>{'a': 30, 'b': 12, 'r': 42},
        draws: <ProblemDraw>[
          _range('a', 5, 30),
          _range('b', 2, 20),
          _sum(),
        ],
      ),
      _compareBig(
        key: 'billes_mamadou_moins_piege',
        level: 2,
        statement:
            'Mamadou a {a} billes. Il en a {b} de moins que son ami Ibrahima. '
            'Combien de billes a Ibrahima\u00a0?',
        check: 'Vérifie\u00a0: {a} + {b} = {r}, Ibrahima a bien {r} billes.',
        fixed: <String, int>{'a': 5, 'b': 3, 'r': 8},
        draws: <ProblemDraw>[
          _range('a', 2, 40),
          _range('b', 1, 10),
          _sum(),
        ],
        trapOf: 'billes_difference',
      ),
      // Level 3: full statement.
      _compareSmall(
        key: 'mangues_de_plus_que_piege',
        level: 3,
        statement:
            'Awa a {a} mangues. Elle en a {b} de plus que Moussa. Combien de '
            'mangues a Moussa\u00a0?',
        check: 'Vérifie\u00a0: {r} + {b} = {a}, Awa a bien {a} mangues.',
        fixed: <String, int>{'a': 84, 'b': 45, 'r': 39},
        draws: <ProblemDraw>[
          _range('a', 20, 100),
          _rangeTo('b', 5, (ProblemValues v) => v['a']! - 5),
          _difference(),
        ],
        trapOf: 'mangues_difference',
      ),
      _compareGap(
        key: 'mangues_difference',
        level: 3,
        statement:
            'Awa a {a} mangues. Moussa en a {b}. Quelle est la différence '
            'entre leurs mangues\u00a0?',
        check: 'Vérifie\u00a0: {b} + {r} = {a} mangues.',
        fixed: <String, int>{'a': 84, 'b': 39, 'r': 45},
        draws: <ProblemDraw>[
          _range('a', 20, 100),
          _rangeTo('b', 5, (ProblemValues v) => v['a']! - 5),
          _difference(),
        ],
      ),
      _groups(
        key: 'biscuits_partages_piege',
        level: 3,
        statement:
            'Moussa a {a} paquets de {b} biscuits. Il veut les partager avec '
            'ses amis. Combien de biscuits a-t-il à partager\u00a0?',
        check: 'Vérifie\u00a0: {a} × {b} = {r} biscuits.',
        fixed: <String, int>{'a': 4, 'b': 12, 'r': 48},
        draws: <ProblemDraw>[
          _range('a', 2, 9),
          _range('b', 2, 12),
          _product(),
        ],
        trapOf: 'biscuits_paquets',
      ),
      _groups(
        key: 'biscuits_paquets',
        level: 3,
        statement:
            'Au marché, Moussa achète des biscuits par paquets de {b}. Il '
            'prend {a} paquets. Combien de biscuits a-t-il\u00a0?',
        check: 'Vérifie\u00a0: {a} × {b} = {r} biscuits.',
        fixed: <String, int>{'a': 4, 'b': 12, 'r': 48},
        draws: <ProblemDraw>[
          _range('a', 2, 9),
          _range('b', 2, 12),
          _product(),
        ],
      ),
      _ratio(
        key: 'mangues_deux_fois_plus',
        level: 3,
        statement:
            'Aminata a {a} mangues. Fatou en a {b} fois plus. Combien de '
            'mangues Fatou a-t-elle\u00a0?',
        check: 'Vérifie\u00a0: {a} × {b} = {r} mangues.',
        fixed: <String, int>{'a': 25, 'b': 2, 'r': 50},
        draws: <ProblemDraw>[
          _range('b', 2, 4),
          _range('a', 5, 50),
          _product(),
        ],
      ),
      _ratioHalf(
        key: 'mangues_moitie_piege',
        level: 3,
        statement:
            'Aminata a {a} mangues. Elle a la moitié des mangues de Fatou. '
            'Combien de mangues Fatou a-t-elle\u00a0?',
        check: 'Vérifie\u00a0: {r} ÷ 2 = {a}, Aminata a bien la moitié.',
        fixed: <String, int>{'a': 25, 'r': 50},
        draws: <ProblemDraw>[
          _range('a', 5, 50),
          DeriveDraw('r', (ProblemValues v) => 2 * v['a']!),
        ],
        trapOf: 'mangues_deux_fois_plus',
      ),
      _takeAway(
        key: 'achat_sachet_eau',
        level: 3,
        statement:
            "Au départ, Ibrahima a {a} {currency}. Il achète un sachet d'eau "
            "à {b} {currency}. Combien d'argent lui reste-t-il à la "
            'fin\u00a0?',
        check: 'Vérifie\u00a0: {b} + {r} = {a} {currency}.',
        fixed: <String, int>{'a': 100, 'b': 25, 'r': 75},
        draws: <ProblemDraw>[
          const ChoiceDraw('a', <int>[50, 75, 100]),
          const ChoiceDraw('b', <int>[25, 50]),
          _difference(),
        ],
        accepts: (ProblemValues v) => v['b']! < v['a']!,
      ),
      _together(
        key: 'awa_marche_francs',
        level: 3,
        statement:
            'Awa achète des mangues à {a} {currency} et du thé à {b} '
            '{currency}. Quel est le total\u00a0?',
        check: 'Vérifie\u00a0: {a} + {b} = {r} {currency}.',
        fixed: <String, int>{'a': 50, 'b': 25, 'r': 75},
        draws: <ProblemDraw>[
          const ChoiceDraw('a', <int>[25, 50, 75]),
          const ChoiceDraw('b', <int>[25, 50, 75]),
          _sum(),
        ],
      ),
      _share(
        key: 'rangees_tabaski',
        level: 3,
        statement:
            'Pour la Tabaski, on met {a} chaises en {b} rangées égales dans '
            'la cour. Combien de chaises y a-t-il dans chaque rangée\u00a0?',
        check: 'Vérifie\u00a0: {b} × {r} = {a} chaises.',
        fixed: <String, int>{'a': 48, 'b': 6, 'r': 8},
        draws: <ProblemDraw>[
          _range('b', 2, 10),
          _range('r', 2, 9),
          _dividend(),
        ],
      ),
      _compareBig(
        key: 'awa_moussa_plus',
        level: 3,
        statement:
            'Moussa a {a} {currency}. Awa en a {b} de plus que lui. Combien '
            'de {currency} Awa a-t-elle\u00a0?',
        check: 'Vérifie\u00a0: {a} + {b} = {r} {currency}.',
        fixed: <String, int>{'a': 25, 'b': 75, 'r': 100},
        draws: <ProblemDraw>[
          const ChoiceDraw('a', <int>[25, 50]),
          const ChoiceDraw('b', <int>[25, 50, 75]),
          _sum(),
        ],
      ),
    ],
  );

  // Draw helpers.

  static ProblemDraw _range(String name, int low, int high) =>
      RangeDraw(name, min: (_) => low, max: (_) => high);

  static ProblemDraw _rangeTo(
    String name,
    int low,
    int Function(ProblemValues drawn) high,
  ) => RangeDraw(name, min: (_) => low, max: high);

  static ProblemDraw _sum() =>
      DeriveDraw('r', (ProblemValues v) => v['a']! + v['b']!);

  static ProblemDraw _difference() =>
      DeriveDraw('r', (ProblemValues v) => v['a']! - v['b']!);

  static ProblemDraw _product() =>
      DeriveDraw('r', (ProblemValues v) => v['a']! * v['b']!);

  static ProblemDraw _dividend() =>
      DeriveDraw('a', (ProblemValues v) => v['b']! * v['r']!);

  // Forms of the table.

  static ProblemTemplate _make({
    required String key,
    required int level,
    required MathOperator operation,
    required BarModelShape shape,
    required BarRole unknown,
    required Map<BarRole, ProblemRef> roles,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    bool isRemoval = false,
    String? trapOf,
    bool Function(ProblemValues values)? accepts,
  }) {
    return ProblemTemplate(
      problemKey: key,
      level: level,
      operation: operation,
      shape: shape,
      unknown: unknown,
      roles: roles,
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      isRemoval: isRemoval,
      trapOf: trapOf,
      accepts: accepts,
    );
  }

  /// `reunir`: `tout=r ; partie1=a ; partie2=b`.
  static ProblemTemplate _together({
    required String key,
    required int level,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    String? trapOf,
    bool Function(ProblemValues values)? accepts,
  }) {
    return _make(
      key: key,
      level: level,
      operation: MathOperator.add,
      shape: BarModelShape.partWhole,
      unknown: BarRole.whole,
      roles: <BarRole, ProblemRef>{
        BarRole.partA: _a,
        BarRole.partB: _b,
        BarRole.whole: _r,
      },
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      trapOf: trapOf,
      accepts: accepts,
    );
  }

  /// `retirer`: `tout=a ; partie=b ; reste=r`.
  static ProblemTemplate _takeAway({
    required String key,
    required int level,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    String? trapOf,
    bool Function(ProblemValues values)? accepts,
  }) {
    return _make(
      key: key,
      level: level,
      operation: MathOperator.subtract,
      shape: BarModelShape.partWhole,
      unknown: BarRole.partB,
      isRemoval: true,
      roles: <BarRole, ProblemRef>{
        BarRole.whole: _a,
        BarRole.partA: _b,
        BarRole.partB: _r,
      },
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      trapOf: trapOf,
      accepts: accepts,
    );
  }

  /// `retirer` with the whole sought: `tout=r ; partie=b ; reste=a`.
  static ProblemTemplate _takeAwayWhole({
    required String key,
    required int level,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    String? trapOf,
  }) {
    return _make(
      key: key,
      level: level,
      operation: MathOperator.add,
      shape: BarModelShape.partWhole,
      unknown: BarRole.whole,
      isRemoval: true,
      roles: <BarRole, ProblemRef>{
        BarRole.whole: _r,
        BarRole.partA: _b,
        BarRole.partB: _a,
      },
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      trapOf: trapOf,
    );
  }

  /// `comparer`, the gap sought: `grand=a ; petit=b ; ecart=r`.
  static ProblemTemplate _compareGap({
    required String key,
    required int level,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    String? trapOf,
  }) {
    return _make(
      key: key,
      level: level,
      operation: MathOperator.subtract,
      shape: BarModelShape.compare,
      unknown: BarRole.gap,
      roles: <BarRole, ProblemRef>{
        BarRole.big: _a,
        BarRole.small: _b,
        BarRole.gap: _r,
      },
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      trapOf: trapOf,
    );
  }

  /// `comparer`, the bigger bar sought: `grand=r ; petit=a ; ecart=b`.
  static ProblemTemplate _compareBig({
    required String key,
    required int level,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    String? trapOf,
  }) {
    return _make(
      key: key,
      level: level,
      operation: MathOperator.add,
      shape: BarModelShape.compare,
      unknown: BarRole.big,
      roles: <BarRole, ProblemRef>{
        BarRole.small: _a,
        BarRole.gap: _b,
        BarRole.big: _r,
      },
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      trapOf: trapOf,
    );
  }

  /// `comparer`, the smaller bar sought: `grand=a ; ecart=b ; petit=r`.
  static ProblemTemplate _compareSmall({
    required String key,
    required int level,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    String? trapOf,
  }) {
    return _make(
      key: key,
      level: level,
      operation: MathOperator.subtract,
      shape: BarModelShape.compare,
      unknown: BarRole.small,
      roles: <BarRole, ProblemRef>{
        BarRole.big: _a,
        BarRole.gap: _b,
        BarRole.small: _r,
      },
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      trapOf: trapOf,
    );
  }

  /// `groupes`: `groupes=a ; taille=b ; tout=r`.
  static ProblemTemplate _groups({
    required String key,
    required int level,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    String? trapOf,
  }) {
    return _make(
      key: key,
      level: level,
      operation: MathOperator.multiply,
      shape: BarModelShape.groups,
      unknown: BarRole.total,
      roles: <BarRole, ProblemRef>{
        BarRole.groups: _a,
        BarRole.each: _b,
        BarRole.total: _r,
      },
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      trapOf: trapOf,
    );
  }

  /// `partage`: `tout=a ; parts=b ; part=r`.
  static ProblemTemplate _share({
    required String key,
    required int level,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    String? trapOf,
  }) {
    return _make(
      key: key,
      level: level,
      operation: MathOperator.divide,
      shape: BarModelShape.groups,
      unknown: BarRole.each,
      roles: <BarRole, ProblemRef>{
        BarRole.total: _a,
        BarRole.groups: _b,
        BarRole.each: _r,
      },
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      trapOf: trapOf,
    );
  }

  /// `groupement`: `tout=a ; taille=b ; groupes=r`.
  static ProblemTemplate _count({
    required String key,
    required int level,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    String? trapOf,
  }) {
    return _make(
      key: key,
      level: level,
      operation: MathOperator.divide,
      shape: BarModelShape.groups,
      unknown: BarRole.groups,
      roles: <BarRole, ProblemRef>{
        BarRole.total: _a,
        BarRole.each: _b,
        BarRole.groups: _r,
      },
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      trapOf: trapOf,
    );
  }

  /// `comparer` multiplicatif: `grand=r ; petit=a ; fois=b`.
  static ProblemTemplate _ratio({
    required String key,
    required int level,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    String? trapOf,
  }) {
    return _make(
      key: key,
      level: level,
      operation: MathOperator.multiply,
      shape: BarModelShape.ratio,
      unknown: BarRole.big,
      roles: <BarRole, ProblemRef>{
        BarRole.small: _a,
        BarRole.times: _b,
        BarRole.big: _r,
      },
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      trapOf: trapOf,
    );
  }

  /// `comparer` multiplicatif, `fois=2` constant: `grand=r ; petit=a`.
  static ProblemTemplate _ratioHalf({
    required String key,
    required int level,
    required String statement,
    required String check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    String? trapOf,
  }) {
    return _make(
      key: key,
      level: level,
      operation: MathOperator.multiply,
      shape: BarModelShape.ratio,
      unknown: BarRole.big,
      roles: <BarRole, ProblemRef>{
        BarRole.small: _a,
        BarRole.times: const ProblemRef.constant(2),
        BarRole.big: _r,
      },
      statement: statement,
      check: check,
      fixed: fixed,
      draws: draws,
      trapOf: trapOf,
    );
  }
}
