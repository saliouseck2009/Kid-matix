import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/mascot/domain/services/mascot_rules.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_cubit.dart';

/// Field to rename the mascot, and its button.
class MascotNameField extends StatefulWidget {
  /// Creates the field, filled with [name].
  const MascotNameField({required this.name, super.key});

  /// Current name of the mascot.
  final String name;

  @override
  State<MascotNameField> createState() => _MascotNameFieldState();
}

class _MascotNameFieldState extends State<MascotNameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.name,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        TextField(
          controller: _controller,
          maxLength: MascotRules.maxNameLength,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: context.l10n.mascotNameLabel),
        ),
        DepthButton(
          label: context.l10n.mascotRename,
          variant: DepthButtonVariant.secondary,
          onPressed: () {
            FocusScope.of(context).unfocus();
            context.read<MascotCubit>().rename(_controller.text);
          },
        ),
      ],
    );
  }
}
