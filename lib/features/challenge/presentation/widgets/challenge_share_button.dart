import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenge_share_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenge_share_state.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_error_message.dart';

/// A button that makes the code of a game, then opens it with [onShare]:
/// « Défier un ami » on the results, « Renvoyer un défi » on the
/// comparison. Needs a [ChallengeShareCubit] above it.
class ChallengeShareButton extends StatelessWidget {
  /// Creates the button showing [label].
  const ChallengeShareButton({
    required this.label,
    required this.sourceKey,
    required this.score,
    required this.onShare,
    this.variant = DepthButtonVariant.secondary,
    super.key,
  });

  /// Text of the button.
  final String label;

  /// Source key of the game played.
  final String sourceKey;

  /// Its right answers: the score to beat.
  final int score;

  /// Opens the code made.
  final ValueChanged<String> onShare;

  /// Visual weight of the button.
  final DepthButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChallengeShareCubit, ChallengeShareState>(
      listener: (BuildContext context, ChallengeShareState state) {
        switch (state) {
          case ChallengeShareReady(:final String code):
            onShare(code);
          case ChallengeShareFailed(:final errorCode):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorCode.toChallengeMessage(context.l10n)),
              ),
            );
          case ChallengeShareIdle() || ChallengeSharing():
            break;
        }
      },
      builder: (BuildContext context, ChallengeShareState state) {
        return DepthButton(
          label: label,
          variant: variant,
          onPressed: state is ChallengeSharing
              ? null
              : () => context.read<ChallengeShareCubit>().share(
                  sourceKey: sourceKey,
                  score: score,
                ),
        );
      },
    );
  }
}
