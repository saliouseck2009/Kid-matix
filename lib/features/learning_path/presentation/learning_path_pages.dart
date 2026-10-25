import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/services/stage_quiz_specs.dart';
import 'package:kid_matix/features/learning_path/domain/services/unit_domain_resolver.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_cubit.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_history_cubit.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_history_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/pages/discovery_page.dart';
import 'package:kid_matix/features/learning_path/presentation/pages/learning_path_page.dart';
import 'package:kid_matix/features/learning_path/presentation/pages/placement_test_page.dart';
import 'package:kid_matix/features/learning_path/presentation/pages/table_detail_page.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/domain_section.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/monsters_card.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_header.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_card.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_slots.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Builds the pages of the learning path for the router, and turns its
/// stages into quiz specs.
///
/// The map shows the domain the player chose; a unit, a stage or a review
/// finds its own domain from its key, so every other page follows it.
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class LearningPathPages {
  /// Creates the factory.
  const LearningPathPages({
    required this._useCases,
    required this._placement,
    required this._placementHistory,
    required this._domainChoice,
    required this._domains,
    required this._clock,
    this._specs = const StageQuizSpecs(),
    this._resolver = const UnitDomainResolver(),
  });

  final LearningPathUseCases _useCases;
  final PlacementUseCases _placement;
  final PlacementHistoryUseCases _placementHistory;
  final DomainChoiceUseCases _domainChoice;
  final DomainRegistry _domains;
  final Clock _clock;
  final StageQuizSpecs _specs;
  final UnitDomainResolver _resolver;

  /// The map of the path of [profileId], in the domain they chose; a new
  /// player gets a new map. [banner] goes above the map, such as « Le
  /// devoir de la classe » of a pupil.
  Widget buildLearningPathPage({
    required String profileId,
    required ValueChanged<String> onOpenTable,
    required ValueChanged<StageSource> onPlay,
    PathHeaderSlots? header,
    Widget? mascot,
    Widget? banner,
  }) {
    return LearningPathPage(
      key: ValueKey<String>(profileId),
      profileId: profileId,
      useCases: _useCases,
      domainChoice: _domainChoice,
      onOpenTable: onOpenTable,
      onPlay: onPlay,
      header: header,
      mascot: mascot,
      banner: banner,
    );
  }

  /// The placement test offered to [profileId] once created; [slots] give
  /// the question card and the keypad of the quiz, [onDone] opens the
  /// path.
  Widget buildPlacementTestPage({
    required String profileId,
    required PlacementSlots slots,
    required VoidCallback onDone,
  }) {
    return PlacementTestPage(
      key: ValueKey<String>('placement-$profileId'),
      profileId: profileId,
      useCases: _placement,
      clock: _clock,
      slots: slots,
      onDone: onDone,
    );
  }

  /// "Mon niveau de départ" of [profileId], for the Profile tab: the
  /// levels of their latest placement test with its date, the earlier
  /// tests, and [onRetake] to take the test again.
  Widget buildPlacementCard({
    required String profileId,
    required VoidCallback onRetake,
  }) {
    return BlocProvider<PlacementHistoryCubit>(
      key: ValueKey<String>('placement-card-$profileId'),
      create: (_) => PlacementHistoryCubit(
        profileId: profileId,
        useCases: _placementHistory,
      )..load(),
      child: PlacementCard(onRetake: onRetake),
    );
  }

  /// The cards of [profileId] that follow one domain, for the Profile tab:
  /// the switch of the domains, then the cards [builder] gives for the
  /// domain chosen, the same as on the map.
  Widget buildDomainSection({
    required String profileId,
    required List<Widget> Function(String domainId) builder,
  }) {
    return BlocProvider<DomainChoiceCubit>(
      key: ValueKey<String>('domain-section-$profileId'),
      create: (_) =>
          DomainChoiceCubit(profileId: profileId, useCases: _domainChoice)
            ..load(),
      child: DomainSection(builder: builder),
    );
  }

  /// "Mes monstres" of [profileId] in [domainId], for the Profile tab;
  /// [onOpenLittle] opens the screen of the little monsters, or is `null`
  /// to leave its link out.
  Widget buildMonstersCard({
    required String profileId,
    required String domainId,
    VoidCallback? onOpenLittle,
  }) {
    final LearningPathParams params = LearningPathParams(
      profileId: profileId,
      domainId: domainId,
    );
    return BlocProvider<LearningPathBloc>(
      key: ValueKey<String>('monsters-$profileId-$domainId'),
      create: (_) =>
          LearningPathBloc(params: params, useCases: _useCases)
            ..add(const LearningPathStarted()),
      child: MonstersCard(domainId: domainId, onOpenLittle: onOpenLittle),
    );
  }

  /// The detail of the unit [unitKey].
  Widget buildTableDetailPage({
    required String profileId,
    required String unitKey,
    required VoidCallback onBack,
    required ValueChanged<StageSource> onPlay,
    required VoidCallback onShowTable,
  }) {
    final LearningDomain? domain = _domainOf(unitKey);
    if (domain == null) return const SizedBox.shrink();
    return TableDetailPage(
      params: LearningPathParams(profileId: profileId, domainId: domain.id),
      unitKey: unitKey,
      useCases: _useCases,
      onBack: onBack,
      onPlay: onPlay,
      onShowTable: onShowTable,
    );
  }

  /// Every item of the unit [unitKey] and its tip; [onPlay] starts the
  /// Discovery questions, or is `null` to only show the unit.
  Widget buildDiscoveryPage({
    required String unitKey,
    required VoidCallback onClose,
    VoidCallback? onPlay,
  }) {
    final LearningDomain? domain = _domainOf(unitKey);
    final LearningUnit? unit = domain?.findUnit(unitKey);
    if (domain == null || unit == null) return const SizedBox.shrink();
    return DiscoveryPage(
      domain: domain,
      unit: unit,
      onClose: onClose,
      onPlay: onPlay,
    );
  }

  /// Whether [source] shows the whole table before its questions.
  bool startsWithTable(StageSource source) {
    return source.stage == StageKind.discovery;
  }

  /// The quiz of the stage [sourceKey], or `null` when it is not one.
  QuizSpec? specOf(String sourceKey) {
    final StageSource? source = StageSource.tryParse(sourceKey);
    if (source == null) return null;
    final LearningDomain? domain = _domainOf(source.unitKey);
    if (domain == null) return null;
    return _specs.specOf(domain: domain, source: source);
  }

  /// The table to go back to after the quiz of [sourceKey], or `null` to
  /// go back to the map.
  String? tableOf(String? sourceKey) {
    final StageSource? source = StageSource.tryParse(sourceKey);
    if (source == null || source.stage == StageKind.review) return null;
    return source.unitKey;
  }

  /// Name of the stage of [sourceKey], such as "Entraînement", or `null`
  /// when it is not a stage.
  String? describeSource(String? sourceKey, AppLocalizations l10n) {
    final StageSource? source = StageSource.tryParse(sourceKey);
    if (source == null) return null;
    final String domainId =
        _domainOf(source.unitKey)?.id ?? LearningDomainIds.multiplication;
    return PathLabels(domainId: domainId, l10n: l10n).stageName(source.stage);
  }

  LearningDomain? _domainOf(String unitKey) {
    return _resolver.domainOf(domains: _domains, unitKey: unitKey);
  }
}
