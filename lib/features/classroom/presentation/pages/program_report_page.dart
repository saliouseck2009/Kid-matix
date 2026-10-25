import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/program_periods_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/report_export_card.dart';

/// Builds the report card over the periods of every class.
typedef ProgramCardBuilder = Widget Function(List<AssessmentPeriod> periods);

/// « Rapport d'école ou de programme »: every class of the device,
/// compared between two periods, anonymous only. No mockup: built with
/// the design system (F31).
class ProgramReportPage extends StatelessWidget {
  /// Creates the page; the Cubit comes from the route.
  const ProgramReportPage({
    required this.onBack,
    required this.cardOf,
    super.key,
  });

  /// Goes back to « Mes classes ».
  final VoidCallback onBack;

  /// The report card.
  final ProgramCardBuilder cardOf;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSizes.space16,
              children: <Widget>[
                ClassroomPageHeader(
                  title: context.l10n.classroomProgramOpen,
                  onBack: onBack,
                ),
                BlocBuilder<ProgramPeriodsCubit, List<AssessmentPeriod>?>(
                  builder:
                      (BuildContext context, List<AssessmentPeriod>? periods) {
                        if (periods == null) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (periods.isEmpty) {
                          return ReportPlaceholderCard(
                            title: context.l10n.classroomProgramOpen,
                            message: context.l10n.classroomProgramEmpty,
                          );
                        }
                        return cardOf(periods);
                      },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
