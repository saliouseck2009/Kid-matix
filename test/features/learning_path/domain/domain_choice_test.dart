import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/learning_path/data/datasources/path_domain_local_data_source_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/path_domain_repository_impl.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_choice_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_domain_choice_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/select_domain_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_domain_choice_use_case.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_cubit.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_use_cases.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/number/domain/services/numbers_domain.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/in_memory_local_storage.dart';

/// [LocalStorage] that cannot be read or written.
final class _BrokenStorage implements LocalStorage {
  @override
  Future<String?> readString({required String key}) async {
    throw Exception('broken');
  }

  @override
  Future<void> remove({required String key}) async {}

  @override
  Future<void> writeString({required String key, required String value}) {
    throw Exception('broken');
  }
}

/// Keeps the errors the Blocs report, as the crash reporter would.
final class _RecordingObserver extends BlocObserver {
  final List<Object> errors = <Object>[];

  @override
  void onError(BlocBase<Object?> bloc, Object error, StackTrace stackTrace) {
    errors.add(error);
    super.onError(bloc, error, stackTrace);
  }
}

void main() {
  late InMemoryLocalStorage storage;
  late PathDomainRepositoryImpl repository;
  late DomainRegistry domains;
  late GetDomainChoiceUseCase getChoice;
  late SelectDomainUseCase selectDomain;

  setUp(() {
    storage = InMemoryLocalStorage();
    repository = PathDomainRepositoryImpl(
      domains: PathDomainLocalDataSourceImpl(storage: storage),
    );
    domains = DomainRegistry()
      ..register(MultiplicationDomain())
      ..register(NumbersDomain());
    getChoice = GetDomainChoiceUseCase(
      repository: repository,
      domains: domains,
    );
    selectDomain = SelectDomainUseCase(repository: repository);
  });

  group('GetDomainChoiceUseCase', () {
    test('shows the multiplication to a player who never chose', () async {
      // Act
      final DomainChoiceEntity actual = (await getChoice(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actual.domainIds, <String>['multiplication', 'numbers']);
      expect(actual.selectedId, 'multiplication');
      expect(actual.hasChoice, isTrue);
    });
    test('shows the domain the player chose, for that player only', () async {
      // Arrange
      await selectDomain(
        params: const LearningPathParams(profileId: 'p1', domainId: 'numbers'),
      );
      // Act
      final DomainChoiceEntity actualFirst = (await getChoice(
        params: 'p1',
      )).requireData;
      final DomainChoiceEntity actualOther = (await getChoice(
        params: 'p2',
      )).requireData;
      // Assert
      expect(actualFirst.selectedId, 'numbers');
      expect(actualOther.selectedId, 'multiplication');
      expect(await storage.readString(key: 'path_domain.p1'), 'numbers');
    });
    test('falls back to the first domain for an unknown one', () async {
      // Arrange
      await storage.writeString(key: 'path_domain.p1', value: 'division');
      // Act
      final DomainChoiceEntity actual = (await getChoice(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actual.selectedId, 'multiplication');
    });
    test('falls back to the first domain when nothing reads', () async {
      // Arrange
      final GetDomainChoiceUseCase inputUseCase = GetDomainChoiceUseCase(
        repository: PathDomainRepositoryImpl(
          domains: PathDomainLocalDataSourceImpl(storage: _BrokenStorage()),
        ),
        domains: domains,
      );
      // Act
      final DomainChoiceEntity actual = (await inputUseCase(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actual.selectedId, 'multiplication');
    });
    test('fails when the app has no domain', () async {
      // Arrange
      final GetDomainChoiceUseCase inputUseCase = GetDomainChoiceUseCase(
        repository: repository,
        domains: DomainRegistry(),
      );
      // Act
      final DataState<DomainChoiceEntity> actual = await inputUseCase(
        params: 'p1',
      );
      // Assert
      expect(actual, isA<DataFailed<DomainChoiceEntity>>());
    });
  });

  group('SelectDomainUseCase', () {
    test('tells the screens of the player only', () async {
      // Arrange
      final WatchDomainChoiceUseCase watch = WatchDomainChoiceUseCase(
        repository: repository,
      );
      final List<String> actualEvents = <String>[];
      final StreamSubscription<void> subscription = watch(
        profileId: 'p1',
      ).listen((_) => actualEvents.add('p1'));
      // Act
      await selectDomain(
        params: const LearningPathParams(profileId: 'p2', domainId: 'numbers'),
      );
      await selectDomain(
        params: const LearningPathParams(profileId: 'p1', domainId: 'numbers'),
      );
      await Future<void>.delayed(Duration.zero);
      // Assert
      expect(actualEvents, <String>['p1']);
      await subscription.cancel();
    });
    test('fails when the preferences cannot be written', () async {
      // Arrange
      final SelectDomainUseCase inputUseCase = SelectDomainUseCase(
        repository: PathDomainRepositoryImpl(
          domains: PathDomainLocalDataSourceImpl(storage: _BrokenStorage()),
        ),
      );
      // Act
      final DataState<void> actual = await inputUseCase(
        params: const LearningPathParams(profileId: 'p1', domainId: 'numbers'),
      );
      // Assert
      expect(
        (actual as DataFailed<void>).exception,
        isA<CacheException>(),
      );
    });
  });

  group('DomainChoiceCubit', () {
    String? selectedOf(DomainChoiceCubit cubit) {
      final DomainChoiceState state = cubit.state;
      return state is DomainChoiceLoaded ? state.choice.selectedId : null;
    }

    DomainChoiceCubit buildCubit() {
      return DomainChoiceCubit(
        profileId: 'p1',
        useCases: DomainChoiceUseCases(
          getChoice: getChoice,
          selectDomain: selectDomain,
          watchChoice: WatchDomainChoiceUseCase(repository: repository),
        ),
      );
    }

    test('reads the choice, then shows and keeps a new one', () async {
      // Arrange
      final DomainChoiceCubit cubit = buildCubit();
      // Act
      await cubit.load();
      // Assert
      expect(selectedOf(cubit), 'multiplication');
      // Act
      await cubit.select('numbers');
      // Assert
      expect(selectedOf(cubit), 'numbers');
      expect(await storage.readString(key: 'path_domain.p1'), 'numbers');
      await cubit.close();
    });
    test('emits a choice once, even read again after its save', () async {
      // Arrange
      final DomainChoiceCubit cubit = buildCubit();
      await cubit.load();
      final List<DomainChoiceState> actualStates = <DomainChoiceState>[];
      final StreamSubscription<DomainChoiceState> subscription = cubit.stream
          .listen(actualStates.add);
      // Act
      await cubit.select('numbers');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      // Assert
      expect(actualStates, hasLength(1));
      expect(selectedOf(cubit), 'numbers');
      await subscription.cancel();
      await cubit.close();
    });
    test('ignores a domain the app does not have', () async {
      // Arrange
      final DomainChoiceCubit cubit = buildCubit();
      await cubit.load();
      // Act
      await cubit.select('division');
      // Assert
      expect(selectedOf(cubit), 'multiplication');
      expect(await storage.readString(key: 'path_domain.p1'), isNull);
      await cubit.close();
    });
    test('fails without a domain instead of reading forever', () async {
      // Arrange
      final DomainChoiceCubit cubit = DomainChoiceCubit(
        profileId: 'p1',
        useCases: DomainChoiceUseCases(
          getChoice: GetDomainChoiceUseCase(
            repository: repository,
            domains: DomainRegistry(),
          ),
          selectDomain: selectDomain,
          watchChoice: WatchDomainChoiceUseCase(repository: repository),
        ),
      );
      // Act
      await cubit.load();
      // Assert
      expect(cubit.state, isA<DomainChoiceFailure>());
      expect(
        (cubit.state as DomainChoiceFailure).errorCode,
        AppErrorCode.validation,
      );
      await cubit.close();
    });
    test('reports a choice it cannot keep and still shows it', () async {
      // Arrange
      final _RecordingObserver observer = _RecordingObserver();
      final BlocObserver previous = Bloc.observer;
      Bloc.observer = observer;
      addTearDown(() => Bloc.observer = previous);
      final PathDomainRepositoryImpl brokenRepository =
          PathDomainRepositoryImpl(
            domains: PathDomainLocalDataSourceImpl(storage: _BrokenStorage()),
          );
      final DomainChoiceCubit cubit = DomainChoiceCubit(
        profileId: 'p1',
        useCases: DomainChoiceUseCases(
          getChoice: GetDomainChoiceUseCase(
            repository: brokenRepository,
            domains: domains,
          ),
          selectDomain: SelectDomainUseCase(repository: brokenRepository),
          watchChoice: WatchDomainChoiceUseCase(repository: brokenRepository),
        ),
      );
      await cubit.load();
      // Act
      await cubit.select('numbers');
      // Assert
      expect(selectedOf(cubit), 'numbers');
      expect(observer.errors.single, isA<CacheException>());
      await cubit.close();
    });
    test('follows a choice made on another screen', () async {
      // Arrange
      final DomainChoiceCubit mapCubit = buildCubit();
      final DomainChoiceCubit profileCubit = buildCubit();
      await mapCubit.load();
      await profileCubit.load();
      // Act
      await profileCubit.select('numbers');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      // Assert
      expect(selectedOf(mapCubit), 'numbers');
      await mapCubit.close();
      await profileCubit.close();
    });
  });
}
