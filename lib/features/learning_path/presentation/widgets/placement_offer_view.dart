import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';

/// The placement test offered at the end of the profile creation, with
/// « Passer ». No mockup: derived from the results screen.
class PlacementOfferView extends StatelessWidget {
  /// Creates the offer.
  const PlacementOfferView({
    required this.onStart,
    this.onSkip,
    super.key,
  });

  static const double _mascotSize = 140;

  /// Starts the test.
  final VoidCallback onStart;

  /// Skips the test, or `null` when it cannot be skipped (a class
  /// assessment).
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space16,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                spacing: AppSizes.space16,
                children: <Widget>[
                  const SizedBox(height: AppSizes.space24),
                  const MascotIllustration(
                    size: _mascotSize,
                    mood: MascotMood.happy,
                  ),
                  Semantics(
                    header: true,
                    child: Text(
                      context.l10n.placementOfferTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall,
                    ),
                  ),
                  Text(
                    context.l10n.placementOfferMessage,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: context.palette.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          DepthButton(
            label: context.l10n.placementOfferStart,
            onPressed: onStart,
          ),
          if (onSkip case final VoidCallback skip)
            DepthButton(
              label: context.l10n.placementOfferSkip,
              variant: DepthButtonVariant.secondary,
              onPressed: skip,
            ),
        ],
      ),
    );
  }
}
