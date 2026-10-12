import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_entry_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_entry_state.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/code_entry_card.dart';

/// « Défier un ami » (mockup 20): the code of the game just played when
/// there is one, then the entry of a code received from a friend; « J'ai
/// un code » shows the entry alone.
class ChallengeCodePage extends StatelessWidget {
  /// Creates the page; [sharedCode] is the card of the code to give, or
  /// `null` for the entry alone.
  const ChallengeCodePage({
    required this.onBack,
    required this.onPlay,
    this.sharedCode,
    super.key,
  });

  /// Goes back to the challenges.
  final VoidCallback onBack;

  /// Plays the game of a valid code, by its source key.
  final ValueChanged<String> onPlay;

  /// The card of the code to give, or `null`.
  final Widget? sharedCode;

  @override
  Widget build(BuildContext context) {
    final Widget? shared = sharedCode;
    return BackToParent(
      onBack: onBack,
      child: BlocListener<CodeEntryCubit, CodeEntryState>(
        listenWhen: (_, CodeEntryState state) => state is CodeEntryAccepted,
        listener: (BuildContext context, CodeEntryState state) =>
            onPlay((state as CodeEntryAccepted).sourceKey),
        child: Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: AppSizes.space24,
              ),
              children: <Widget>[
                _Header(
                  title: shared == null
                      ? context.l10n.challengeCodeCardTitle
                      : context.l10n.challengeShareButton,
                  onBack: onBack,
                ),
                const SizedBox(height: AppSizes.space16),
                if (shared != null) ...<Widget>[
                  shared,
                  const SizedBox(height: AppSizes.space16),
                  Text(
                    context.l10n.challengeCodeShareHint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.palette.mutedText,
                    ),
                  ),
                  const SizedBox(height: AppSizes.space16),
                  const _OrDivider(),
                  const SizedBox(height: AppSizes.space16),
                ],
                const CodeEntryCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        AppIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: context.l10n.commonBack,
          onPressed: onBack,
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ],
    );
  }
}

/// The line with « ou » between the code shown and the code entry.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final Widget line = Expanded(
      child: Container(
        height: AppSizes.borderWidth,
        color: context.palette.border,
      ),
    );
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        line,
        Text(
          context.l10n.challengeCodeOr,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.palette.mutedText),
        ),
        line,
      ],
    );
  }
}
