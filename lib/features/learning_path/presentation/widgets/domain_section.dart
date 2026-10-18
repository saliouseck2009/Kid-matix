import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_choice_entity.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_cubit.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/domain_switch.dart';

/// Cards of the Profile that follow one domain, under the switch of the
/// domains when the app has two or more; the choice comes from the
/// enclosing [DomainChoiceCubit] and is the same as on the map.
class DomainSection extends StatelessWidget {
  /// Creates the section; [builder] builds the cards of a domain.
  const DomainSection({required this.builder, super.key});

  /// Gap between the switch and the cards, as between the Profile cards.
  static const double gap = 14;

  /// The cards of the domain [domainId].
  final List<Widget> Function(String domainId) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DomainChoiceCubit, DomainChoiceEntity?>(
      builder: (BuildContext context, DomainChoiceEntity? choice) {
        if (choice == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: <Widget>[
            if (choice.hasChoice) DomainSwitch(choice: choice),
            ...builder(choice.selectedId),
          ],
        );
      },
    );
  }
}
