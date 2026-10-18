import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_code_codec.dart';

/// The violet card of « Défier un ami »: the game and the score to beat,
/// the code in big characters and the button that copies it.
class SharedCodeCard extends StatelessWidget {
  /// Creates the card of [code].
  const SharedCodeCard({
    required this.code,
    required this.modeLabel,
    required this.tablesLabel,
    required this.scoreToBeat,
    super.key,
  });

  static const double _radius = 28;
  static const double _codeRadius = 20;
  static const double _codeSize = 32;
  static const double _codeSpacing = 2;

  /// The ten characters of the code.
  final String code;

  /// Name of the game, such as "Contre-la-montre".
  final String modeLabel;

  /// Its tables, such as "Tables de 2 et de 5".
  final String tablesLabel;

  /// Right answers to beat.
  final int scoreToBeat;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String formatted = ChallengeCodeCodec.format(code);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: <Widget>[
          _CodeGame(
            modeLabel: modeLabel,
            tablesLabel: tablesLabel,
            scoreToBeat: scoreToBeat,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.space16,
              horizontal: AppSizes.space8,
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(_codeRadius),
            ),
            child: Column(
              spacing: AppSizes.space4,
              children: <Widget>[
                Text(
                  context.l10n.challengeCodeYours,
                  style: textTheme.bodySmall?.copyWith(
                    color: context.palette.mutedText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Semantics(
                  label: context.l10n.challengeCodeSemantics(
                    code.split('').join(' '),
                  ),
                  child: ExcludeSemantics(
                    child: FittedBox(
                      child: Text(
                        formatted,
                        style: textTheme.displaySmall?.copyWith(
                          fontSize: _codeSize,
                          letterSpacing: _codeSpacing,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          DepthButton(
            label: context.l10n.challengeCodeCopy,
            icon: Icons.copy_rounded,
            variant: DepthButtonVariant.accent,
            onPressed: () => _copy(context, formatted),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String copied = context.l10n.challengeCodeCopied;
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }
}

/// The game of the code and the yellow badge of the score to beat.
class _CodeGame extends StatelessWidget {
  const _CodeGame({
    required this.modeLabel,
    required this.tablesLabel,
    required this.scoreToBeat,
  });

  static const double _badgeRadius = 16;
  static const double _scoreSize = 26;

  final String modeLabel;
  final String tablesLabel;
  final int scoreToBeat;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                modeLabel,
                style: textTheme.titleLarge?.copyWith(color: scheme.onPrimary),
              ),
              Text(
                tablesLabel,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
          decoration: BoxDecoration(
            color: scheme.secondary,
            borderRadius: BorderRadius.circular(_badgeRadius),
          ),
          child: Column(
            children: <Widget>[
              Text(
                '$scoreToBeat',
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: _scoreSize,
                  color: scheme.onSecondary,
                ),
              ),
              Text(
                context.l10n.challengeCodeToBeat,
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
