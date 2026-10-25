import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/printables_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/pages/printables_page.dart';

/// Builds « Fiches à imprimer » (F31-07), in the teacher area.
final class PrintablePages {
  /// Creates the factory.
  const PrintablePages({
    required this._useCases,
    required this._domains,
    required this._clock,
  });

  final PrintableUseCases _useCases;
  final DomainRegistry _domains;
  final Clock _clock;

  /// The button of « Mes classes ».
  Widget buildOpenButton({required VoidCallback onOpen}) {
    return Builder(
      builder: (BuildContext context) => DepthButton(
        label: context.l10n.classroomPrintablesOpen,
        icon: Icons.print_rounded,
        variant: DepthButtonVariant.secondary,
        onPressed: onOpen,
      ),
    );
  }

  /// The page of the printable sheets, on the first unit of the first
  /// domain.
  Widget buildPage({required VoidCallback onBack}) {
    final LearningDomain first = _domains.domains.first;
    return BlocProvider<PrintablesCubit>(
      create: (_) => PrintablesCubit(
        domainId: first.id,
        unitKey: first.units.first.key,
        useCases: _useCases,
        clock: _clock,
      ),
      child: PrintablesPage(domains: _domains, onBack: onBack),
    );
  }
}
