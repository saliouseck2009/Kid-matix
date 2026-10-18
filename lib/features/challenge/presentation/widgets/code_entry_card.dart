import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_entry_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_entry_state.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_labels.dart';

/// « Tu as reçu un code ? »: the field where the child types a code and
/// the button that plays it; says why a code is refused.
class CodeEntryCard extends StatefulWidget {
  /// Creates the card.
  const CodeEntryCard({super.key});

  @override
  State<CodeEntryCard> createState() => _CodeEntryCardState();
}

class _CodeEntryCardState extends State<CodeEntryCard> {
  static const double _radius = 28;
  static const double _fieldRadius = 16;
  static const double _fieldTextSize = 22;
  static const int _maxLength = 14;

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(_fieldRadius),
      borderSide: BorderSide(
        color: context.palette.strongBorder,
        width: AppSizes.borderWidth,
      ),
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: BlocBuilder<CodeEntryCubit, CodeEntryState>(
        builder: (BuildContext context, CodeEntryState state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: <Widget>[
              Text(
                context.l10n.challengeCodeEntryTitle,
                style: textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.go,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(_maxLength),
                  const _UpperCaseFormatter(),
                ],
                style: textTheme.titleLarge?.copyWith(fontSize: _fieldTextSize),
                decoration: InputDecoration(
                  hintText: context.l10n.challengeCodeEntryHint,
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border.copyWith(
                    borderSide: border.borderSide.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                onChanged: (_) => context.read<CodeEntryCubit>().edit(),
                onSubmitted: (_) => _submit(context),
              ),
              if (state case CodeEntryRejected(:final error))
                Semantics(
                  liveRegion: true,
                  child: Text(
                    ChallengeLabels.describeCodeError(error, context.l10n),
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ListenableBuilder(
                listenable: _controller,
                builder: (BuildContext context, _) => DepthButton(
                  label: context.l10n.challengeCodePlay,
                  onPressed:
                      _controller.text.trim().isEmpty ||
                          state is CodeEntryChecking
                      ? null
                      : () => _submit(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_controller.text.trim().isEmpty) return;
    context.read<CodeEntryCubit>().submit(_controller.text);
  }
}

/// Shows the code in uppercase, as it is printed.
final class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
