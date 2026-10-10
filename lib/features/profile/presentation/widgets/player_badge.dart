import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_state.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_view.dart';

/// The active player at the top of the map: avatar, nickname and level.
class PlayerBadge extends StatelessWidget {
  /// Creates the badge; the player comes from the enclosing Cubit.
  const PlayerBadge({super.key});

  static const double _avatarSize = 48;

  @override
  Widget build(BuildContext context) {
    final ProfileEntity? profile = switch (context
        .watch<ProfileTabCubit>()
        .state) {
      ProfileTabLoaded(:final profile) => profile,
      _ => null,
    };
    if (profile == null) return const SizedBox(height: _avatarSize);
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      child: Row(
        spacing: 10,
        children: <Widget>[
          ProfileAvatarView(
            avatar: profile.avatar,
            color: profile.color,
            size: _avatarSize,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  profile.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge,
                ),
                Text(
                  context.l10n.profileLevel(profile.level),
                  style: textTheme.bodySmall?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
