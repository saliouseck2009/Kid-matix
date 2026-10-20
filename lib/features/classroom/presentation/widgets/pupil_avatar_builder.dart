import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/entities/player_identity.dart';

/// Draws the avatar of a pupil, [size] wide; given by the profile
/// feature, which owns the avatars.
typedef PupilAvatarBuilder = Widget Function(
  PlayerIdentity player,
  double size,
);
