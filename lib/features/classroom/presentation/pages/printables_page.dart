import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/printables_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/printables_state.dart';
import 'package:kid_matix/features/classroom/presentation/report/printable_files.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_page_header.dart';

/// « Fiches à imprimer »: a sheet of exercises of a unit, with its
/// answers, and the cards of the math words, as PDF for the share sheet.
/// No mockup: built with the design system (F31).
class PrintablesPage extends StatelessWidget {
  /// Creates the page over the [domains]; the Cubit comes from the route.
  const PrintablesPage({
    required this.domains,
    required this.onBack,
    super.key,
  });

  /// The learning domains.
  final DomainRegistry domains;

  /// Goes back to « Mes classes ».
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<PrintablesCubit, PrintablesState>(
            listenWhen: (PrintablesState before, PrintablesState after) =>
                before.isBusy && !after.isBusy,
            listener: _showOutcome,
            builder: (BuildContext context, PrintablesState state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.space24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSizes.space16,
                  children: <Widget>[
                    ClassroomPageHeader(
                      title: context.l10n.classroomPrintablesOpen,
                      onBack: onBack,
                    ),
                    Text(context.l10n.classroomPrintablesHint),
                    _ExercisesCard(domains: domains, state: state),
                    _WordsCard(isBusy: state.isBusy),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showOutcome(BuildContext context, PrintablesState state) {
    final String? message = switch (state.errorCode) {
      AppErrorCode.validation => context.l10n.classroomPrintablesNotPrintable,
      null => state.isShared ? context.l10n.classroomPrintablesShared : null,
      _ => context.l10n.classroomErrorGeneric,
    };
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ExercisesCard extends StatelessWidget {
  const _ExercisesCard({required this.domains, required this.state});

  final DomainRegistry domains;
  final PrintablesState state;

  @override
  Widget build(BuildContext context) {
    final PrintablesCubit cubit = context.read<PrintablesCubit>();
    final LearningDomain? domain = domains.find(state.domainId);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space12,
        children: <Widget>[
          Text(
            context.l10n.classroomPrintablesExercisesTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          DropdownButtonFormField<String>(
            initialValue: state.domainId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.l10n.classroomPrintablesDomain,
            ),
            items: <DropdownMenuItem<String>>[
              for (final LearningDomain each in domains.domains)
                DropdownMenuItem<String>(
                  value: each.id,
                  child: Text(context.l10n.domainName(each.id)),
                ),
            ],
            onChanged: (String? id) {
              final LearningDomain? chosen = id == null
                  ? null
                  : domains.find(id);
              if (chosen == null || chosen.units.isEmpty) return;
              cubit.choose(
                domainId: chosen.id,
                unitKey: chosen.units.first.key,
              );
            },
          ),
          DropdownButtonFormField<String>(
            key: ValueKey<String>('units-${state.domainId}'),
            initialValue: state.unitKey,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.l10n.classroomPrintablesUnit,
            ),
            items: <DropdownMenuItem<String>>[
              for (final LearningUnit unit
                  in domain?.units ?? const <LearningUnit>[])
                DropdownMenuItem<String>(
                  value: unit.key,
                  child: Text(
                    context.l10n.unitName(state.domainId, unit.key),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (String? key) {
              if (key != null) {
                cubit.choose(domainId: state.domainId, unitKey: key);
              }
            },
          ),
          DepthButton(
            label: context.l10n.classroomPrintablesExercises,
            icon: Icons.print_rounded,
            variant: DepthButtonVariant.secondary,
            onPressed: state.isBusy
                ? null
                : () {
                    final PrintableFiles files = PrintableFiles(
                      l10n: context.l10n,
                    );
                    cubit.printExercises(
                      (sheet, day, language) => files.exerciseSheetOf(
                        sheet,
                        day: day,
                        helpLanguage: language,
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

class _WordsCard extends StatelessWidget {
  const _WordsCard({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final PrintablesCubit cubit = context.read<PrintablesCubit>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space12,
        children: <Widget>[
          Text(
            context.l10n.classroomPrintablesWordsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          DepthButton(
            label: context.l10n.classroomPrintablesWords,
            icon: Icons.style_rounded,
            variant: DepthButtonVariant.secondary,
            onPressed: isBusy
                ? null
                : () {
                    final PrintableFiles files = PrintableFiles(
                      l10n: context.l10n,
                    );
                    cubit.printWords(
                      (sheet, day) => files.wordCardsOf(sheet, day: day),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
