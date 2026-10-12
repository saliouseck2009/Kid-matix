import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_state.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_avatar_builder.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_chase_banner.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_podium.dart';
import 'package:kid_matix/features/reward/presentation/widgets/leaderboard_row.dart';

/// The weekly leaderboard of the phone (mockup 19): the players ranked by
/// the XP earned since Monday, the three first on a podium, and what the
/// active player needs to catch up.
class LeaderboardPage extends StatelessWidget {
  /// Creates the page; the ranking comes from the enclosing Cubit.
  const LeaderboardPage({
    required this.avatarOf,
    required this.onBack,
    super.key,
  });

  /// Draws the avatars of the players.
  final LeaderboardAvatarBuilder avatarOf;

  /// Goes back to the Profile tab.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _LeaderboardHeader(onBack: onBack),
              Expanded(
                child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
                  builder: (BuildContext context, LeaderboardState state) {
                    return switch (state) {
                      LeaderboardLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      LeaderboardFailure(:final errorCode) =>
                        _LeaderboardFailureView(errorCode: errorCode),
                      LeaderboardLoaded() => _LeaderboardView(
                        state: state,
                        avatarOf: avatarOf,
                      ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader({required this.onBack});

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSizes.space24,
    20,
    AppSizes.space24,
    AppSizes.space16,
  );

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: Row(
        spacing: AppSizes.space12,
        children: <Widget>[
          AppIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: context.l10n.commonBack,
            onPressed: onBack,
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                context.l10n.leaderboardTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardView extends StatelessWidget {
  const _LeaderboardView({required this.state, required this.avatarOf});

  static const double _gap = AppSizes.space16;
  static const double _rowGap = AppSizes.space12;
  static const EdgeInsets _sides = EdgeInsets.symmetric(
    horizontal: AppSizes.space24,
  );

  final LeaderboardLoaded state;
  final LeaderboardAvatarBuilder avatarOf;

  @override
  Widget build(BuildContext context) {
    final List<LeaderboardEntry> entries = state.leaderboard.entries;
    final List<LeaderboardEntry> others = entries
        .skip(LeaderboardPodium.size)
        .toList();
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: _sides,
          sliver: SliverList.list(
            children: <Widget>[
              const _WeekLine(),
              const SizedBox(height: _gap),
              LeaderboardPodium(
                entries: entries.take(LeaderboardPodium.size).toList(),
                activeProfileId: state.activeProfileId,
                avatarOf: avatarOf,
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: _sides.copyWith(top: _gap),
          sliver: SliverList.separated(
            itemCount: others.length,
            separatorBuilder: (_, _) => const SizedBox(height: _rowGap),
            itemBuilder: (BuildContext context, int index) {
              final LeaderboardEntry entry = others[index];
              return LeaderboardRow(
                key: ValueKey<String>(entry.player.id),
                entry: entry,
                rank: LeaderboardPodium.size + index + 1,
                isActive: entry.player.id == state.activeProfileId,
                avatarOf: avatarOf,
              );
            },
          ),
        ),
        if (state.chase case final chase?)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.space24,
                _gap,
                AppSizes.space24,
                AppSizes.space24,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: LeaderboardChaseBanner(chase: chase),
              ),
            ),
          ),
      ],
    );
  }
}

/// "XP gagnés cette semaine" and the pill "Remise à zéro lundi".
class _WeekLine extends StatelessWidget {
  const _WeekLine();

  static const EdgeInsets _pillPadding = EdgeInsets.symmetric(
    horizontal: AppSizes.space12,
    vertical: 6,
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSizes.space8,
      runSpacing: AppSizes.space8,
      children: <Widget>[
        Text(
          context.l10n.leaderboardWeekLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Container(
          padding: _pillPadding,
          decoration: BoxDecoration(
            color: context.palette.tint,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          child: Text(
            context.l10n.leaderboardResetHint,
            style: theme.textTheme.labelMedium?.copyWith(
              color: context.palette.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardFailureView extends StatelessWidget {
  const _LeaderboardFailureView({required this.errorCode});

  final AppErrorCode errorCode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.space24,
          children: <Widget>[
            Semantics(
              liveRegion: true,
              child: Text(
                errorCode == AppErrorCode.cache
                    ? context.l10n.errorStorage
                    : context.l10n.errorUnknown,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            DepthButton(
              label: context.l10n.commonRetry,
              onPressed: context.read<LeaderboardCubit>().load,
            ),
          ],
        ),
      ),
    );
  }
}
