import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_quiz_specs.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenge_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenges_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/session_record_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/training_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/pages/challenges_page.dart';
import 'package:kid_matix/features/challenge/presentation/pages/training_page.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_labels.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/new_record_card.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Where the results of a challenge go back to.
enum ChallengeOrigin {
  /// The training tab.
  training,

  /// The challenges tab.
  challenges,
}

/// Builds the pages of the free training and the challenges for the
/// router, and turns their source keys into quizzes.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class ChallengePages {
  /// Creates the factory.
  const ChallengePages({required this._useCases, required this._domains});

  /// Domain of the tables offered.
  static const String domainId = LearningDomainIds.multiplication;

  final ChallengeUseCases _useCases;
  final DomainRegistry _domains;
  static const ChallengeQuizSpecs _specs = ChallengeQuizSpecs();

  /// The training tab of [profileId]; [onLaunch] plays the source key
  /// of the training chosen.
  Widget buildTrainingPage({
    required String profileId,
    required ValueChanged<String> onLaunch,
  }) {
    final List<LearningUnit> units = <LearningUnit>[
      ...?_domains.find(domainId)?.path,
    ]..sort((LearningUnit a, LearningUnit b) => a.number.compareTo(b.number));
    return BlocProvider<TrainingCubit>(
      key: ValueKey<String>('training-$profileId'),
      create: (_) =>
          TrainingCubit(profileId: profileId, useCases: _useCases)..load(),
      child: Builder(
        builder: (BuildContext context) => TrainingPage(
          units: units,
          labels: ChallengeLabels(domainId: domainId, l10n: context.l10n),
          onLaunch: (TrainingSource choice) => onLaunch(choice.toKey()),
        ),
      ),
    );
  }

  /// The challenges tab of [profileId]; [onPlay] plays a source key.
  Widget buildChallengesPage({
    required String profileId,
    required ValueChanged<String> onPlay,
  }) {
    return BlocProvider<ChallengesCubit>(
      key: ValueKey<String>('challenges-$profileId'),
      create: (_) =>
          ChallengesCubit(profileId: profileId, useCases: _useCases)..load(),
      child: ChallengesPage(
        onPlay: (ChallengeSource source) => onPlay(source.toKey()),
      ),
    );
  }

  /// "Nouveau record !" on the results of [sessionId], when it set one.
  Widget buildRecordCard({required String sessionId}) {
    return BlocProvider<SessionRecordCubit>(
      create: (_) => SessionRecordCubit(
        sessionId: sessionId,
        getSessionRecord: _useCases.getSessionRecord,
      )..load(),
      child: BlocBuilder<SessionRecordCubit, RecordEntity?>(
        builder: (BuildContext context, RecordEntity? record) => record == null
            ? const SizedBox.shrink()
            : NewRecordCard(record: record),
      ),
    );
  }

  /// The quiz played for [sourceKey], or `null` when it is not a quiz of
  /// the challenges.
  QuizSpec? specOf(String sourceKey) {
    final ChallengeSource? source = ChallengeSource.tryParse(sourceKey);
    final LearningDomain? domain = _domains.find(domainId);
    if (source == null || domain == null) return null;
    return _specs.specOf(domain: domain, source: source);
  }

  /// Where the results of a quiz played for [sourceKey] go back to, or
  /// `null` when it is not a quiz of the challenges.
  ChallengeOrigin? originOf(String? sourceKey) {
    return switch (ChallengeSource.tryParse(sourceKey)) {
      TrainingSource() => ChallengeOrigin.training,
      TimeAttackSource() => ChallengeOrigin.challenges,
      null => null,
    };
  }

  /// Name of the quiz played for [sourceKey], such as "Contre-la-montre",
  /// or `null`.
  String? describeSource(String? sourceKey, AppLocalizations l10n) {
    return ChallengeLabels.describeSource(sourceKey, l10n);
  }
}
