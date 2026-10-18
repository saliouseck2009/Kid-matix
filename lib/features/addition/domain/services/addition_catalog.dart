import 'package:kid_matix/features/addition/domain/entities/arithmetic_fact.dart';
import 'package:kid_matix/features/addition/domain/entities/arithmetic_unit.dart';

/// The nine units of the additions and subtractions and their facts, in
/// the order of the learning path.
///
/// The units up to 20 are built from fact families: the subtractions of
/// `sub10` and `sub20` are the families of the additions of `add10` and
/// `add20`, so a mistake on `7 + 8` can recall `8 + 7`, and `15 − 7`
/// recalls `15 − 8`.
///
/// Every key here is released content: changing one loses the progress
/// stored under it. Add facts or units, never rename them.
abstract final class AdditionCatalog {
  static ArithmeticFact _add(int left, int right) =>
      ArithmeticFact.add(left, right);

  static ArithmeticFact _sub(int left, int right) =>
      ArithmeticFact.subtract(left, right);

  /// The two orders of each pair: `(2, 3)` gives `2 + 3` and `3 + 2`.
  static List<ArithmeticFact> _bothWays(List<(int, int)> pairs) {
    return <ArithmeticFact>[
      for (final (int a, int b) in pairs) ...<ArithmeticFact>[
        _add(a, b),
        _add(b, a),
      ],
    ];
  }

  /// Both subtractions of each whole: `(15, 7)` gives `15 − 7` and
  /// `15 − 8`.
  static List<ArithmeticFact> _bothTakeAways(List<(int, int)> wholes) {
    return <ArithmeticFact>[
      for (final (int whole, int part) in wholes) ...<ArithmeticFact>[
        _sub(whole, part),
        _sub(whole, whole - part),
      ],
    ];
  }

  /// 1. Additions jusqu'à 10: sums from 3 to 9, both orders.
  static final ArithmeticUnit add10 = ArithmeticUnit(
    slug: 'add10',
    number: 1,
    aid: ArithmeticAid.numberLine,
    facts: _bothWays(const <(int, int)>[
      (1, 2),
      (2, 3),
      (2, 4),
      (3, 4),
      (3, 5),
      (4, 5),
    ]),
  );

  /// 2. Compléments à 10: what to add to 1 to 9 to make 10.
  static final ArithmeticUnit toTen = ArithmeticUnit(
    slug: 'toten',
    number: 2,
    aid: ArithmeticAid.completeToTen,
    facts: <ArithmeticFact>[
      for (int left = 1; left <= 9; left++) _add(left, 10 - left),
    ],
  );

  /// 3. Additions jusqu'à 20: sums from 11 to 17 that cross the ten, both
  /// orders.
  static final ArithmeticUnit add20 = ArithmeticUnit(
    slug: 'add20',
    number: 3,
    aid: ArithmeticAid.numberLine,
    facts: _bothWays(const <(int, int)>[
      (4, 7),
      (5, 7),
      (6, 7),
      (6, 8),
      (7, 8),
      (7, 9),
      (8, 9),
    ]),
  );

  /// 4. Soustractions jusqu'à 10: the families of the additions of
  /// `add10` and of 10 = 3 + 7.
  static final ArithmeticUnit sub10 = ArithmeticUnit(
    slug: 'sub10',
    number: 4,
    aid: ArithmeticAid.numberLine,
    facts: _bothTakeAways(const <(int, int)>[
      (3, 1),
      (5, 2),
      (6, 2),
      (7, 3),
      (8, 3),
      (9, 4),
      (10, 3),
    ]),
  );

  /// 5. Soustractions jusqu'à 20: the families of the additions of
  /// `add20`.
  static final ArithmeticUnit sub20 = ArithmeticUnit(
    slug: 'sub20',
    number: 5,
    aid: ArithmeticAid.numberLine,
    facts: _bothTakeAways(const <(int, int)>[
      (11, 4),
      (12, 5),
      (13, 6),
      (14, 6),
      (15, 7),
      (16, 7),
      (17, 8),
    ]),
  );

  /// 6. Additions jusqu'à 100 sans retenue: the ones make less than 10.
  static final ArithmeticUnit add100 = ArithmeticUnit(
    slug: 'add100',
    number: 6,
    aid: ArithmeticAid.tenBundles,
    facts: <ArithmeticFact>[
      _add(23, 14),
      _add(31, 25),
      _add(42, 36),
      _add(15, 44),
      _add(52, 27),
      _add(61, 38),
      _add(34, 45),
      _add(71, 26),
      _add(18, 61),
      _add(53, 32),
    ],
  );

  /// 7. Soustractions jusqu'à 100 sans retenue: the ones can be taken.
  static final ArithmeticUnit sub100 = ArithmeticUnit(
    slug: 'sub100',
    number: 7,
    aid: ArithmeticAid.tenBundles,
    facts: <ArithmeticFact>[
      _sub(47, 23),
      _sub(58, 34),
      _sub(69, 25),
      _sub(86, 42),
      _sub(75, 31),
      _sub(98, 57),
      _sub(64, 12),
      _sub(79, 45),
      _sub(55, 21),
      _sub(88, 63),
    ],
  );

  /// 8. Additions avec retenue: the ones make 10 or more.
  static final ArithmeticUnit carry = ArithmeticUnit(
    slug: 'carry',
    number: 8,
    aid: ArithmeticAid.tenBundles,
    facts: <ArithmeticFact>[
      _add(27, 15),
      _add(38, 24),
      _add(46, 37),
      _add(19, 25),
      _add(58, 26),
      _add(35, 48),
      _add(67, 18),
      _add(29, 34),
      _add(75, 16),
      _add(49, 43),
    ],
  );

  /// 9. Soustractions avec retenue: a ten is broken to take the ones.
  static final ArithmeticUnit borrow = ArithmeticUnit(
    slug: 'borrow',
    number: 9,
    aid: ArithmeticAid.tenBundles,
    facts: <ArithmeticFact>[
      _sub(42, 17),
      _sub(63, 28),
      _sub(51, 26),
      _sub(74, 38),
      _sub(85, 49),
      _sub(92, 67),
      _sub(56, 29),
      _sub(81, 35),
      _sub(70, 43),
      _sub(64, 36),
    ],
  );

  /// Every unit, in the order of the learning path.
  static final List<ArithmeticUnit> units = List<ArithmeticUnit>.unmodifiable(
    <ArithmeticUnit>[
      add10,
      toTen,
      add20,
      sub10,
      sub20,
      add100,
      sub100,
      carry,
      borrow,
    ],
  );
}
