import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/entities/player_identity.dart';

/// Draws the avatar of [player], [size] wide; given by the router, since
/// the drawings belong to the profile feature.
typedef ShopAvatarBuilder = Widget Function(PlayerIdentity player, double size);
