import 'package:meta/meta.dart';

/// The money of the word problems (lot F30): the name of its unit in the
/// statements, such as "francs".
///
/// The app has one currency for now, the CFA franc. [defaultCurrency] is
/// the one place that picks it: choosing another one by region later is a
/// change there and a new value here, never in a statement.
@immutable
final class Currency {
  /// Creates a currency of ISO [code] whose plural unit is [unitName].
  const Currency({required this.code, required this.unitName});

  /// The CFA franc of West Africa.
  static const Currency cfaFranc = Currency(code: 'XOF', unitName: 'francs');

  /// The currency used when the player's region chooses none.
  static const Currency defaultCurrency = cfaFranc;

  /// ISO 4217 code, such as `XOF`.
  final String code;

  /// Name of the unit in the plural, as the French statements write it.
  final String unitName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}
