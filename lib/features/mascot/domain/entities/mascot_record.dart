import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:kid_matix/features/mascot/domain/services/mascot_rules.dart';
import 'package:meta/meta.dart';

/// What is stored about the mascot of a player: the choices of the child.
@immutable
final class MascotRecord {
  /// Creates the record.
  MascotRecord({
    required this.name,
    required List<MascotAccessory> worn,
    required this.celebratedStage,
  }) : worn = List<MascotAccessory>.unmodifiable(worn);

  /// Record of a player who never changed the mascot.
  const MascotRecord.initial()
    : name = MascotRules.defaultName,
      worn = const <MascotAccessory>[],
      celebratedStage = MascotRules.firstStage;

  /// Name of the mascot.
  final String name;

  /// Accessories the child put on.
  final List<MascotAccessory> worn;

  /// Highest stage already celebrated.
  final int celebratedStage;
}
