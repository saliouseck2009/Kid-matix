import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/widgets/choice_segments.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_choice_entity.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_cubit.dart';

/// The domains of the app side by side, the one shown filled, such as
/// "Multiplication" and "Nombres"; the choice comes from the enclosing
/// [DomainChoiceCubit].
class DomainSwitch extends StatelessWidget {
  /// Most domains shown side by side; more scroll sideways.
  static const int maxSideBySide = 3;

  /// Creates the switch of [choice].
  const DomainSwitch({required this.choice, super.key});

  /// Domains and the one shown.
  final DomainChoiceEntity choice;

  @override
  Widget build(BuildContext context) {
    return ChoiceSegments<String>(
      choices: choice.domainIds,
      selected: choice.selectedId,
      labelOf: context.l10n.domainName,
      semanticLabelOf: context.l10n.domainSpokenName,
      onSelected: context.read<DomainChoiceCubit>().select,
      // Five domains do not fit side by side at a large text size.
      isScrollable: choice.domainIds.length > maxSideBySide,
    );
  }
}
