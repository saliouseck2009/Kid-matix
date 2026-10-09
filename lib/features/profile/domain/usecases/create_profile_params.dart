import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:meta/meta.dart';

/// What a player chooses when creating their profile.
@immutable
final class CreateProfileParams {
  /// Creates the parameters of a profile creation.
  const CreateProfileParams({
    required this.nickname,
    required this.avatar,
    required this.color,
  });

  /// Nickname as typed; it is cleaned before being stored.
  final String nickname;

  /// Chosen character.
  final ProfileAvatar avatar;

  /// Chosen color.
  final ProfileColor color;
}
