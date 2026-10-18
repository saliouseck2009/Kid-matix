import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/services/code_challenge_rules.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenge_share_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_challenge_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_entry_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/pages/challenge_code_page.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_labels.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_share_button.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/code_outcome_view.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/shared_code_card.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Builds the challenge by code for the router: « Défier un ami » on the
/// results, the code screen and the comparison of a game replayed from a
/// code.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class CodeChallengePages {
  /// Creates the factory.
  const CodeChallengePages({required this._useCases, required this._domains});

  static const int _defaultTableCount = 12;

  final CodeChallengeUseCases _useCases;
  final DomainRegistry _domains;

  /// « Défier un ami » at the end of a free training or a time attack
  /// played for [sourceKey] with [score] right answers; `null` for
  /// another game. [onShare] opens the code made.
  Widget? buildShareButton({
    required String? sourceKey,
    required int score,
    required ValueChanged<String> onShare,
  }) {
    final ChallengeSource? source = ChallengeSource.tryParse(sourceKey);
    if (source is! TrainingSource && source is! TimeAttackSource) return null;
    return BlocProvider<ChallengeShareCubit>(
      create: (_) => ChallengeShareCubit(encode: _useCases.encode),
      child: Builder(
        builder: (BuildContext context) => ChallengeShareButton(
          label: context.l10n.challengeShareButton,
          sourceKey: source!.toKey(),
          score: score,
          onShare: onShare,
        ),
      ),
    );
  }

  /// The code screen: [code] to give when it is one, then the entry of a
  /// code; [onPlay] plays a valid code by its source key.
  Widget buildCodePage({
    required String? code,
    required VoidCallback onBack,
    required ValueChanged<String> onPlay,
  }) {
    final ChallengeCode? shared = _readCode(code);
    return BlocProvider<CodeEntryCubit>(
      create: (_) =>
          CodeEntryCubit(buildQuizFromCode: _useCases.buildQuizFromCode),
      child: Builder(
        builder: (BuildContext context) => ChallengeCodePage(
          onBack: onBack,
          onPlay: onPlay,
          sharedCode: shared == null
              ? null
              : SharedCodeCard(
                  code: code!,
                  modeLabel: ChallengeLabels.describeCodeMode(
                    shared,
                    context.l10n,
                  ),
                  tablesLabel: _describeTables(
                    shared,
                    context.l10n,
                    isLineStart: true,
                  ),
                  scoreToBeat: shared.scoreToBeat,
                ),
        ),
      ),
    );
  }

  /// The comparison that replaces the results of a game replayed from a
  /// code, played for [sourceKey] with [score] right answers; `null` for
  /// another game.
  Widget? buildOutcome({
    required String? sourceKey,
    required int score,
    required ValueChanged<String> onShare,
    required VoidCallback onBack,
    Widget? xpLabel,
    Widget? recordCard,
  }) {
    final ChallengeSource? source = ChallengeSource.tryParse(sourceKey);
    if (source is! CodeChallengeSource) return null;
    return BlocProvider<ChallengeShareCubit>(
      create: (_) => ChallengeShareCubit(encode: _useCases.encode),
      child: Builder(
        builder: (BuildContext context) => CodeOutcomeView(
          subtitle: context.l10n.challengeCodeSubtitle(
            ChallengeLabels.describeCodeMode(source.code, context.l10n),
            _describeTables(source.code, context.l10n),
          ),
          scoreToBeat: source.code.scoreToBeat,
          score: score,
          sourceKey: source.toKey(),
          onShare: onShare,
          onBack: onBack,
          xpLabel: xpLabel,
          recordCard: recordCard,
        ),
      ),
    );
  }

  ChallengeCode? _readCode(String? code) {
    if (code == null) return null;
    final ChallengeSource? source = ChallengeSource.tryParse(
      CodeChallengeSource.keyOf(code),
    );
    return source is CodeChallengeSource ? source.code : null;
  }

  String _describeTables(
    ChallengeCode code,
    AppLocalizations l10n, {
    bool isLineStart = false,
  }) {
    return ChallengeLabels.describeTables(
      code.tables,
      l10n,
      tableCount:
          _domains.find(CodeChallengeRules.domainId)?.units.length ??
          _defaultTableCount,
      isLineStart: isLineStart,
    );
  }
}
