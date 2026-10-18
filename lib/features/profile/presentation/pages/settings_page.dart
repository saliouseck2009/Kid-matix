import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/choice_segments.dart';
import 'package:kid_matix/features/profile/domain/entities/daily_goal.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/settings_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/settings_state.dart';
import 'package:kid_matix/features/profile/presentation/widgets/nickname_confirm_dialog.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_error_message.dart';
import 'package:kid_matix/features/profile/presentation/widgets/settings_parts.dart';

/// The settings of the player (mockup 13): sounds, game, reminder,
/// language, backup and the actions on the player.
/// Other features add rows to the game section, such as the leaderboard
/// switch, and fill the reminder section.
class SettingsPage extends StatelessWidget {
  /// Creates the page; the settings come from the enclosing Cubit.
  const SettingsPage({
    required this.onBack,
    this.gameRows = const <Widget>[],
    this.backupSection,
    this.reminderRows = const <Widget>[],
    this.languageRows = const <Widget>[],
    super.key,
  });

  /// Goes back to the Profile tab.
  final VoidCallback onBack;

  /// Rows of other features, at the end of the game section.
  final List<Widget> gameRows;

  /// The "Sauvegarde" section, or `null`.
  final Widget? backupSection;

  /// Rows of the « Rappel » section, hidden when empty.
  final List<Widget> reminderRows;

  /// Rows of the « Langue » section, hidden when empty.
  final List<Widget> languageRows;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<SettingsCubit, SettingsState>(
            listenWhen: (SettingsState previous, SettingsState current) =>
                current is SettingsLoaded &&
                (current.wasReset || current.errorCode != null),
            listener: _showOutcome,
            builder: (BuildContext context, SettingsState state) {
              return switch (state) {
                SettingsLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                SettingsFailure(:final errorCode) => Center(
                  child: Text(errorCode.toProfileMessage(context.l10n)),
                ),
                SettingsLoaded() => _SettingsView(
                  state: state,
                  onBack: onBack,
                  gameRows: gameRows,
                  backupSection: backupSection,
                  reminderRows: reminderRows,
                  languageRows: languageRows,
                ),
              };
            },
          ),
        ),
      ),
    );
  }

  void _showOutcome(BuildContext context, SettingsState state) {
    if (state is! SettingsLoaded) return;
    final String message = switch (state.errorCode) {
      final code? => code.toProfileMessage(context.l10n),
      null => context.l10n.resetProgressDone,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({
    required this.state,
    required this.onBack,
    required this.gameRows,
    required this.backupSection,
    required this.reminderRows,
    required this.languageRows,
  });

  static const double _gap = 20;

  final SettingsLoaded state;
  final VoidCallback onBack;
  final List<Widget> gameRows;
  final Widget? backupSection;
  final List<Widget> reminderRows;
  final List<Widget> languageRows;

  Future<void> _reset(BuildContext context) async {
    final SettingsCubit cubit = context.read<SettingsCubit>();
    if (await confirmProgressReset(context, nickname: state.nickname)) {
      await cubit.resetProgress();
    }
  }

  Future<void> _delete(BuildContext context) async {
    final SettingsCubit cubit = context.read<SettingsCubit>();
    if (await confirmProfileDeletion(context, nickname: state.nickname)) {
      await cubit.deleteProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsCubit cubit = context.read<SettingsCubit>();
    final ProfileSettingsEntity settings = state.settings;
    final Color band = Theme.of(context).scaffoldBackgroundColor;
    return ListView(
      padding: const EdgeInsets.all(AppSizes.space24),
      children: <Widget>[
        Row(
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
                  context.l10n.settingsTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _gap),
        SettingsSection(
          title: context.l10n.settingsSoundSection,
          rows: <Widget>[
            SettingsSwitchRow(
              label: context.l10n.settingsSound,
              value: settings.isSoundEnabled,
              onChanged: (bool isOn) => cubit.update(
                (ProfileSettingsEntity old) =>
                    old.copyWith(isSoundEnabled: isOn),
              ),
            ),
            SettingsSwitchRow(
              label: context.l10n.settingsVibration,
              value: settings.isVibrationEnabled,
              onChanged: (bool isOn) => cubit.update(
                (ProfileSettingsEntity old) =>
                    old.copyWith(isVibrationEnabled: isOn),
              ),
            ),
          ],
        ),
        const SizedBox(height: _gap),
        SettingsSection(
          title: context.l10n.settingsGameSection,
          rows: <Widget>[
            SettingsChoiceRow(
              label: context.l10n.settingsTimer,
              choices: ChoiceSegments<TimerMode>(
                choices: TimerMode.values,
                selected: settings.timerMode,
                backgroundColor: band,
                labelOf: (TimerMode mode) => switch (mode) {
                  TimerMode.normal => context.l10n.settingsTimerNormal,
                  TimerMode.relaxed => context.l10n.settingsTimerRelaxed,
                  TimerMode.off => context.l10n.settingsTimerOff,
                },
                onSelected: (TimerMode mode) => cubit.update(
                  (ProfileSettingsEntity old) => old.copyWith(timerMode: mode),
                ),
              ),
            ),
            SettingsChoiceRow(
              label: context.l10n.settingsDailyGoal,
              choices: ChoiceSegments<DailyGoal>(
                choices: DailyGoal.values,
                selected: settings.dailyGoal,
                backgroundColor: band,
                labelOf: (DailyGoal goal) =>
                    context.l10n.settingsDailyGoalXp(goal.xp),
                onSelected: (DailyGoal goal) => cubit.update(
                  (ProfileSettingsEntity old) => old.copyWith(dailyGoal: goal),
                ),
              ),
            ),
            SettingsSwitchRow(
              label: context.l10n.settingsUnlockAll,
              value: settings.isEverythingUnlocked,
              onChanged: (bool isOn) => cubit.update(
                (ProfileSettingsEntity old) =>
                    old.copyWith(isEverythingUnlocked: isOn),
              ),
            ),
            SettingsSwitchRow(
              label: context.l10n.settingsReducedMotion,
              value: settings.isReducedMotionEnabled,
              onChanged: (bool isOn) => cubit.update(
                (ProfileSettingsEntity old) =>
                    old.copyWith(isReducedMotionEnabled: isOn),
              ),
            ),
            SettingsSwitchRow(
              label: context.l10n.settingsReadAloud,
              value: settings.isReadAloudEnabled,
              onChanged: (bool isOn) => cubit.update(
                (ProfileSettingsEntity old) =>
                    old.copyWith(isReadAloudEnabled: isOn),
              ),
            ),
            ...gameRows,
          ],
        ),
        if (reminderRows.isNotEmpty) ...<Widget>[
          const SizedBox(height: _gap),
          SettingsSection(
            title: context.l10n.settingsReminderSection,
            rows: reminderRows,
          ),
        ],
        if (languageRows.isNotEmpty) ...<Widget>[
          const SizedBox(height: _gap),
          SettingsSection(
            title: context.l10n.settingsLanguageSection,
            rows: languageRows,
          ),
        ],
        const SizedBox(height: _gap),
        if (backupSection case final Widget section) ...<Widget>[
          section,
          const SizedBox(height: _gap),
        ],
        SettingsSection(
          title: context.l10n.settingsPlayerSection,
          rows: <Widget>[
            SettingsDangerRow(
              label: context.l10n.resetProgressButton,
              onTap: () => _reset(context),
            ),
            SettingsDangerRow(
              label: context.l10n.deleteProfileButton,
              onTap: () => _delete(context),
            ),
          ],
        ),
      ],
    );
  }
}
