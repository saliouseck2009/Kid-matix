import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_challenge_gauge.dart';

/// The gauge of the class challenge above « Qui es-tu ? », so the whole
/// class sees it; nothing until it is read.
class ClassChallengeHeader extends StatelessWidget {
  /// Creates the header; the Cubit comes from the slot.
  const ClassChallengeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassOverviewCubit, ClassOverviewState>(
      builder: (BuildContext context, ClassOverviewState state) {
        if (state is! ClassOverviewLoaded) return const SizedBox.shrink();
        return AppCard(
          child: ClassChallengeGauge(challenge: state.overview.challenge),
        );
      },
    );
  }
}
