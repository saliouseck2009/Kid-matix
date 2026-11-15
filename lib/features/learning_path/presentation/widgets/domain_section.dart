import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_choice_entity.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_cubit.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_state.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/domain_button.dart';

/// Cards of the Profile that follow one domain, under the button of the
/// domain that opens « Mes parcours » when the app has two domains or
/// more; the choice comes from the enclosing [DomainChoiceCubit] and is
/// the same as on the map.
class DomainSection extends StatelessWidget {
  /// Creates the section; [builder] builds the cards of a domain.
  const DomainSection({required this.builder, super.key});

  /// Gap between the button and the cards, as between the Profile cards.
  static const double gap = 14;

  /// The cards of the domain [domainId].
  final List<Widget> Function(String domainId) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DomainChoiceCubit, DomainChoiceState>(
      builder: (BuildContext context, DomainChoiceState state) {
        if (state is! DomainChoiceLoaded) return const SizedBox.shrink();
        final DomainChoiceEntity choice = state.choice;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: <Widget>[
            if (choice.hasChoice) DomainButton(domainId: choice.selectedId),
            ...builder(choice.selectedId),
          ],
        );
      },
    );
  }
}
