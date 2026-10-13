import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';

part 'shop_choice_local_model.g.dart';

/// Row of the `shop_choice` table: the theme a player applied.
@JsonSerializable(fieldRename: FieldRename.snake)
final class ShopChoiceLocalModel {
  /// Creates a row with every column given.
  const ShopChoiceLocalModel({
    required this.profileId,
    required this.themeId,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Reads a row returned by `sqflite`.
  factory ShopChoiceLocalModel.fromJson(Map<String, Object?> json) =>
      _$ShopChoiceLocalModelFromJson(json);

  /// Player.
  final String profileId;

  /// Name of the theme, such as `ocean`.
  final String themeId;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$ShopChoiceLocalModelToJson(this);

  /// Returns the theme of this row; an unknown name gives the default.
  AppColorTheme toTheme() {
    return AppColorTheme.values.asNameMap()[themeId] ?? AppColorTheme.lavender;
  }
}
