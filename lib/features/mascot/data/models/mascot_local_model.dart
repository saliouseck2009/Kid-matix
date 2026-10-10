import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_record.dart';

part 'mascot_local_model.g.dart';

/// Row of the `mascot` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class MascotLocalModel {
  /// Creates a row with every column given.
  const MascotLocalModel({
    required this.profileId,
    required this.name,
    required this.wornAccessories,
    required this.celebratedStage,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Builds the row of [mascot] for [profileId], written at [updatedAt].
  factory MascotLocalModel.fromRecord({
    required String profileId,
    required MascotRecord mascot,
    required DateTime updatedAt,
  }) {
    return MascotLocalModel(
      profileId: profileId,
      name: mascot.name,
      wornAccessories: mascot.worn
          .map((MascotAccessory accessory) => accessory.name)
          .join(separator),
      celebratedStage: mascot.celebratedStage,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite`.
  factory MascotLocalModel.fromJson(Map<String, Object?> json) =>
      _$MascotLocalModelFromJson(json);

  /// Separator of the accessory names in [wornAccessories].
  static const String separator = ',';

  /// Player.
  final String profileId;

  /// Name of the mascot.
  final String name;

  /// Names of the accessories worn, separated by [separator].
  final String wornAccessories;

  /// Highest stage already celebrated.
  final int celebratedStage;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$MascotLocalModelToJson(this);

  /// Returns the record of this row; unknown accessory names are skipped.
  MascotRecord toRecord() {
    final Map<String, MascotAccessory> byName = <String, MascotAccessory>{
      for (final MascotAccessory accessory in MascotAccessory.values)
        accessory.name: accessory,
    };
    return MascotRecord(
      name: name,
      worn: <MascotAccessory>[
        for (final String accessoryName in wornAccessories.split(separator))
          if (byName[accessoryName] case final MascotAccessory accessory)
            accessory,
      ],
      celebratedStage: celebratedStage,
    );
  }
}
