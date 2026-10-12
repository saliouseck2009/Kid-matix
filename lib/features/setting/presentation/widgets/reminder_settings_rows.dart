import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';
import 'package:kid_matix/features/setting/presentation/bloc/reminder_cubit.dart';
import 'package:kid_matix/features/setting/presentation/bloc/reminder_state.dart';

/// The rows of the « Rappel » section of the settings screen (mockup 13):
/// « Rappel quotidien » and « Heure du rappel », for the whole phone.
///
/// Drawn like the other rows of the settings; the time is greyed while
/// the reminder is off. A refused permission is explained in a snack bar.
class ReminderSettingsRows extends StatelessWidget {
  /// Creates the rows; the settings come from the enclosing Cubit.
  const ReminderSettingsRows({super.key});

  static const double _dividerThickness = 2;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReminderCubit, ReminderState>(
      listenWhen: (ReminderState previous, ReminderState current) =>
          current is ReminderLoaded && current.errorCode != null,
      listener: _showError,
      builder: (BuildContext context, ReminderState state) {
        final ReminderLoaded? loaded = state is ReminderLoaded ? state : null;
        final bool canChange = loaded != null && !loaded.isSaving;
        final ReminderSettings settings =
            loaded?.settings ?? ReminderSettings.initial;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ReminderSwitchRow(
              isEnabled: settings.isEnabled,
              canChange: canChange,
            ),
            Divider(
              height: _dividerThickness,
              thickness: _dividerThickness,
              color: context.palette.tint,
            ),
            _ReminderTimeRow(
              time: settings.time,
              canChange: canChange && settings.isEnabled,
            ),
          ],
        );
      },
    );
  }

  void _showError(BuildContext context, ReminderState state) {
    if (state is! ReminderLoaded) return;
    final String message = switch (state.errorCode) {
      AppErrorCode.permissionDenied =>
        context.l10n.settingsReminderPermissionDenied,
      _ => context.l10n.settingsReminderError,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReminderSwitchRow extends StatelessWidget {
  const _ReminderSwitchRow({required this.isEnabled, required this.canChange});

  final bool isEnabled;
  final bool canChange;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          context.l10n.settingsReminderDaily,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        value: isEnabled,
        onChanged: canChange
            ? (bool value) =>
                  context.read<ReminderCubit>().setEnabled(isEnabled: value)
            : null,
      ),
    );
  }
}

class _ReminderTimeRow extends StatelessWidget {
  const _ReminderTimeRow({required this.time, required this.canChange});

  final ReminderTime time;
  final bool canChange;

  Future<void> _pickTime(BuildContext context) async {
    final ReminderCubit cubit = context.read<ReminderCubit>();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: time.hour, minute: time.minute),
    );
    if (picked == null) return;
    await cubit.setTime(
      time: ReminderTime(hour: picked.hour, minute: picked.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String shownTime = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: time.hour, minute: time.minute),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color? color = canChange ? null : context.palette.mutedText;
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: canChange,
        child: InkWell(
          onTap: canChange ? () => _pickTime(context) : null,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget + AppSizes.space8,
            ),
            child: Row(
              spacing: AppSizes.space12,
              children: <Widget>[
                Expanded(
                  child: Text(
                    context.l10n.settingsReminderTime,
                    style: textTheme.bodyLarge?.copyWith(color: color),
                  ),
                ),
                Text(
                  shownTime,
                  style: textTheme.titleMedium?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
