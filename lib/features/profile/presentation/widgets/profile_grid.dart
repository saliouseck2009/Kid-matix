import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_pill.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_limits.dart';
import 'package:kid_matix/features/profile/presentation/widgets/new_player_card.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_card.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_card_frame.dart';
import 'package:kid_matix/features/profile/presentation/widgets/who_is_playing_header.dart';

/// Scrolling content of "Qui joue ?": header, player cards and limit hint.
class ProfileGrid extends StatelessWidget {
  /// Creates the grid of [profiles].
  const ProfileGrid({
    required this.profiles,
    required this.canAddProfile,
    required this.onProfileTap,
    required this.onNewPlayerTap,
    this.footerOf,
    super.key,
  });

  static const int _columnCount = 2;
  static const String _sampleText = 'Ag';
  static const double _cardGap = AppSizes.space16;
  static const EdgeInsets _screenPadding = EdgeInsets.fromLTRB(
    AppSizes.space24,
    40,
    AppSizes.space24,
    AppSizes.space24,
  );

  /// Players to show, oldest first.
  final List<ProfileEntity> profiles;

  /// Whether the "new player" card is shown.
  final bool canAddProfile;

  /// Called with the player whose card is tapped.
  final ValueChanged<ProfileEntity> onProfileTap;

  /// Called when the "new player" card is tapped.
  final VoidCallback onNewPlayerTap;

  /// Footer of the card of a player, such as their streak pill, or `null`.
  final Widget Function(String profileId)? footerOf;

  @override
  Widget build(BuildContext context) {
    final int cardCount = profiles.length + (canAddProfile ? 1 : 0);
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: _screenPadding.copyWith(bottom: AppSizes.space24),
          sliver: const SliverToBoxAdapter(child: WhoIsPlayingHeader()),
        ),
        SliverPadding(
          padding: _screenPadding.copyWith(top: 0, bottom: 0),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _columnCount,
              mainAxisSpacing: _cardGap,
              crossAxisSpacing: _cardGap,
              mainAxisExtent: _measureCardHeight(context),
            ),
            itemCount: cardCount,
            itemBuilder: (BuildContext context, int index) {
              if (index == profiles.length) {
                return NewPlayerCard(onTap: onNewPlayerTap);
              }
              final ProfileEntity profile = profiles[index];
              return ProfileCard(
                key: ValueKey<String>(profile.id),
                profile: profile,
                onTap: () => onProfileTap(profile),
                footer: footerOf?.call(profile.id),
              );
            },
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: _screenPadding.copyWith(top: AppSizes.space24),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                context.l10n.profileLimitHint(ProfileLimits.maxProfiles),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Height of a card for the current text size, so large system text
  /// never overflows the fixed-height grid cells.
  double _measureCardHeight(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    return ProfileCardFrame.depth +
        ProfileCard.padding.vertical +
        ProfileCard.avatarSize +
        ProfileCard.gap * 2 +
        _measureLine(scaler, textTheme.titleLarge) +
        _measureLine(scaler, textTheme.bodySmall) +
        (footerOf == null
            ? 0
            : ProfileCard.gap + _measurePill(scaler, textTheme));
  }

  /// Height of a pill footer, such as the streak.
  double _measurePill(TextScaler scaler, TextTheme textTheme) {
    final double line = _measureLine(scaler, textTheme.labelLarge);
    final double content = line > AppPill.iconSize ? line : AppPill.iconSize;
    return content + AppPill.verticalPadding * 2;
  }

  double _measureLine(TextScaler scaler, TextStyle? style) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: _sampleText, style: style),
      textScaler: scaler,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final double height = painter.height;
    painter.dispose();
    return height;
  }
}
