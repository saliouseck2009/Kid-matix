import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/setting/presentation/bloc/reminder_cubit.dart';
import 'package:kid_matix/features/setting/presentation/bloc/reminder_use_cases.dart';
import 'package:kid_matix/features/setting/presentation/widgets/reminder_settings_rows.dart';

/// Builds the daily reminder rows of the settings screen, for the router.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class ReminderPages {
  /// Creates the factory.
  const ReminderPages({required this._useCases});

  final ReminderUseCases _useCases;

  /// « Rappel quotidien » and « Heure du rappel », for the « Rappel »
  /// section of the settings screen.
  Widget buildSettingsRows() {
    return BlocProvider<ReminderCubit>(
      create: (_) => ReminderCubit(useCases: _useCases)..load(),
      child: const ReminderSettingsRows(),
    );
  }
}
