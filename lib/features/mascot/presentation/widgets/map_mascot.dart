import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/services/game_feedback_service.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_cubit.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_state.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_growth_celebration.dart';

/// The mascot on the map, next to the current table, with a speech
/// [bubble]; it celebrates its growth to a new stage once, as soon as the
/// map shows it.
class MapMascot extends StatefulWidget {
  /// Creates the mascot with its [bubble].
  const MapMascot({required this.bubble, required this.feedback, super.key});

  /// What the mascot says, such as the daily goal reminder.
  final Widget bubble;

  /// Sound and vibration of the growth celebration.
  final GameFeedbackService feedback;

  @override
  State<MapMascot> createState() => _MapMascotState();
}

class _MapMascotState extends State<MapMascot> {
  static const double _size = 96;

  bool _isCelebrating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _celebrateIfNew(context.read<MascotCubit>().state);
    });
  }

  Future<void> _celebrateIfNew(MascotState state) async {
    if (_isCelebrating || state is! MascotLoaded || !state.mascot.isNewStage) {
      return;
    }
    _isCelebrating = true;
    await context.read<MascotCubit>().markCelebrated(state.mascot.stage);
    if (mounted) {
      await showMascotGrowth(context, state.mascot, feedback: widget.feedback);
    }
    _isCelebrating = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MascotCubit, MascotState>(
      listener: (BuildContext context, MascotState state) =>
          _celebrateIfNew(state),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: AppSizes.space8,
        children: <Widget>[
          const MascotIllustration(size: _size),
          Flexible(child: widget.bubble),
        ],
      ),
    );
  }
}
