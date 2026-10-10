import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/services/stage_quiz_specs.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/pages/discovery_page.dart';
import 'package:kid_matix/features/learning_path/presentation/pages/learning_path_page.dart';
import 'package:kid_matix/features/learning_path/presentation/pages/table_detail_page.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_header.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Builds the pages of the learning path for the router, and turns its
/// stages into quiz specs.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class LearningPathPages {
  /// Creates the factory.
  const LearningPathPages({
    required this._useCases,
    required this._domains,
    this._specs = const StageQuizSpecs(),
  });

  /// Domain of the learning path of version 1.0.
  static const String domainId = LearningDomainIds.multiplication;

  final LearningPathUseCases _useCases;
  final DomainRegistry _domains;
  final StageQuizSpecs _specs;

  /// The map of the path of [profileId]; a new player gets a new map.
  Widget buildLearningPathPage({
    required String profileId,
    required ValueChanged<String> onOpenTable,
    required ValueChanged<StageSource> onPlay,
    PathHeaderSlots? header,
    Widget? mascot,
  }) {
    return LearningPathPage(
      key: ValueKey<String>(profileId),
      params: _paramsOf(profileId),
      useCases: _useCases,
      onOpenTable: onOpenTable,
      onPlay: onPlay,
      header: header,
      mascot: mascot,
    );
  }

  /// The detail of the table [unitKey].
  Widget buildTableDetailPage({
    required String profileId,
    required String unitKey,
    required VoidCallback onBack,
    required ValueChanged<StageSource> onPlay,
    required VoidCallback onShowTable,
  }) {
    return TableDetailPage(
      params: _paramsOf(profileId),
      unitKey: unitKey,
      useCases: _useCases,
      onBack: onBack,
      onPlay: onPlay,
      onShowTable: onShowTable,
    );
  }

  /// The whole table [unitKey] and its tip; [onPlay] starts the Discovery
  /// questions, or is `null` to only show the table.
  Widget buildDiscoveryPage({
    required String unitKey,
    required VoidCallback onClose,
    VoidCallback? onPlay,
  }) {
    final LearningDomain? domain = _domains.find(domainId);
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
    final LearningDomain? domain = _domains.find(domainId);
    if (source == null || domain == null) return null;
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
    return PathLabels(domainId: domainId, l10n: l10n).stageName(source.stage);
  }

  LearningPathParams _paramsOf(String profileId) {
    return LearningPathParams(profileId: profileId, domainId: domainId);
  }
}
