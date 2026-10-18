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
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/pages/discovery_page.dart';
import 'package:kid_matix/features/learning_path/presentation/pages/learning_path_page.dart';
import 'package:kid_matix/features/learning_path/presentation/pages/placement_test_page.dart';
import 'package:kid_matix/features/learning_path/presentation/pages/table_detail_page.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/monsters_card.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_header.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_slots.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Builds the pages of the learning path for the router, and turns its
/// stages into quiz specs.
///
/// A unit, a stage or a review finds its own domain from its key, so
/// every page follows it.
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class LearningPathPages {
  /// Creates the factory.
  const LearningPathPages({
    required this._useCases,
    required this._placement,
    required this._domains,
    required this._clock,
    this._specs = const StageQuizSpecs(),
    this._resolver = const UnitDomainResolver(),
  });

  /// Domain of the placement test of version 1.0.
  static const String placementDomainId = LearningDomainIds.multiplication;

  final LearningPathUseCases _useCases;
  final PlacementUseCases _placement;
  final DomainRegistry _domains;
  final Clock _clock;
  final StageQuizSpecs _specs;
  final UnitDomainResolver _resolver;

  /// The map of the path of [profileId] in the multiplication; a new
  /// player gets a new map.
  Widget buildLearningPathPage({
    required String profileId,
    required ValueChanged<String> onOpenTable,
    required ValueChanged<StageSource> onPlay,
    PathHeaderSlots? header,
    Widget? mascot,
  }) {
    return LearningPathPage(
      key: ValueKey<String>(profileId),
      params: LearningPathParams(
        profileId: profileId,
        domainId: LearningDomainIds.multiplication,
      ),
      useCases: _useCases,
      onOpenTable: onOpenTable,
      onPlay: onPlay,
      header: header,
      mascot: mascot,
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
      params: LearningPathParams(
        profileId: profileId,
        domainId: placementDomainId,
      ),
      useCases: _placement,
      clock: _clock,
      slots: slots,
      onDone: onDone,
    );
  }

  /// "Mes monstres" of [profileId] in [domainId], for the Profile tab;
  /// [onOpenLittle] opens the screen of the little monsters, or is `null`
  /// to leave its link out.
  Widget buildMonstersCard({
    required String profileId,
    String domainId = LearningDomainIds.multiplication,
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
