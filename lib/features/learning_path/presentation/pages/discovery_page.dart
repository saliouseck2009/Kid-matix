import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/tip_card.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/unit_facts_grid.dart';

/// The Discovery stage: the whole table and its tip, then "À moi de
/// jouer" starts its questions. Opened by "Voir la table" without the
/// button to play.
class DiscoveryPage extends StatelessWidget {
  /// Creates the page of [unit] in [domain].
  const DiscoveryPage({
    required this.domain,
    required this.unit,
    required this.onClose,
    this.onPlay,
    super.key,
  });

  /// Domain of the table.
  final LearningDomain domain;

  /// Table shown.
  final LearningUnit unit;

  /// Leaves the page.
  final VoidCallback onClose;

  /// Starts the questions, or `null` when the page only shows the table.
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final PathLabels labels = PathLabels(
      domainId: domain.id,
      l10n: context.l10n,
    );
    final VoidCallback? play = onPlay;
    return BackToParent(
      onBack: onClose,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 18,
              children: <Widget>[
                _DiscoveryTopBar(isPlaying: play != null, onClose: onClose),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 18,
                      children: <Widget>[
                        Semantics(
                          header: true,
                          child: Text(
                            context.l10n.pathDiscoveryTitle(unit.number),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        UnitFactsGrid(
                          facts: unit.items.map(_describe).toList(),
                        ),
                        TipCard(tip: labels.unitTip(unit.number)),
                      ],
                    ),
                  ),
                ),
                if (play != null)
                  DepthButton(
                    label: context.l10n.pathDiscoveryStart,
                    onPressed: play,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PromptToken> _describe(LearningItem item) => domain.describeItem(item);
}

/// Close cross and empty progress bar while playing; back arrow alone
/// when the page only shows the table.
class _DiscoveryTopBar extends StatelessWidget {
  const _DiscoveryTopBar({required this.isPlaying, required this.onClose});

  final bool isPlaying;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        AppIconButton(
          icon: isPlaying ? Icons.close_rounded : Icons.arrow_back_rounded,
          tooltip: isPlaying
              ? context.l10n.quizQuitTooltip
              : context.l10n.commonBack,
          onPressed: onClose,
        ),
        if (isPlaying)
          Expanded(
            child: AppProgressBar(
              value: 0,
              semanticLabel: context.l10n.pathDiscoveryProgress,
            ),
          ),
      ],
    );
  }
}
