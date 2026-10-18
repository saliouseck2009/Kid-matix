import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/entities/player_identity.dart';

/// Draws the avatar of [player], [size] wide; given by the router, since
/// the avatars belong to the profile feature.
typedef LeaderboardAvatarBuilder = Widget Function(
  PlayerIdentity player,
  double size,
);
