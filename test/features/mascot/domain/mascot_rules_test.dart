import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/entities/accessory_slot.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_entity.dart';
import 'package:kid_matix/features/mascot/domain/services/mascot_rules.dart';
import 'package:kid_matix/features/mascot/domain/usecases/get_mascot_use_case.dart';
import 'package:kid_matix/features/mascot/domain/usecases/update_mascot_use_cases.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/mascot_fakes.dart';

const MascotRules _rules = MascotRules();

void main() {
  group('MascotRules stages', () {
    final Map<int, int> expectedStages = <int, int>{
      1: 1,
      4: 1,
      5: 2,
      9: 2,
      10: 3,
      19: 3,
      20: 4,
      30: 5,
      55: 5,
    };
    for (final MapEntry<int, int> entry in expectedStages.entries) {
      test('puts level ${entry.key} at stage ${entry.value}', () {
        // Assert
        expect(_rules.stageOf(entry.key), entry.value);
      });
    }
    test('gives the level of the next stage', () {
      // Assert
      expect(_rules.nextStageLevel(1), 5);
      expect(_rules.nextStageLevel(4), 30);
      expect(_rules.nextStageLevel(5), isNull);
    });
  });

  group('MascotRules accessories', () {
    test('unlocks one accessory per crown, in order', () {
      // Act
      final Set<MascotAccessory> actualAccessories = _rules.unlockedBy(
        crowns: 3,
        badgeKeys: const <String>{},
      );
      // Assert
      expect(actualAccessories, <MascotAccessory>{
        MascotAccessory.cap,
        MascotAccessory.roundGlasses,
        MascotAccessory.cape,
      });
    });
    test('unlocks the accessories of the badges', () {
      // Act
      final Set<MascotAccessory> actualAccessories = _rules.unlockedBy(
        crowns: 0,
        badgeKeys: const <String>{
          'regular',
          'lightning',
          'allFacts',
          'perfect',
        },
      );
      // Assert
      expect(actualAccessories, <MascotAccessory>{
        MascotAccessory.partyHat,
        MascotAccessory.lightningGoggles,
        MascotAccessory.goldenCape,
      });
    });
    test('has 12 crown accessories and 3 badge ones', () {
      // Assert
      expect(
        MascotAccessory.values.where(
          (MascotAccessory a) => a.crownRank != null,
        ),
        hasLength(12),
      );
      expect(
        _rules.unlockedBy(crowns: 12, badgeKeys: const <String>{}),
        hasLength(12),
      );
    });
    test('wears only earned accessories, one per slot', () {
      // Act
      final Map<AccessorySlot, MascotAccessory> actualWorn = _rules.wornAmong(
        wearing: const <MascotAccessory>[
          MascotAccessory.cap,
          MascotAccessory.wizardHat,
          MascotAccessory.cape,
        ],
        unlocked: const <MascotAccessory>{
          MascotAccessory.cap,
          MascotAccessory.wizardHat,
        },
      );
      // Assert
      expect(actualWorn, <AccessorySlot, MascotAccessory>{
        AccessorySlot.head: MascotAccessory.wizardHat,
      });
    });
    test('cleans the name of the mascot', () {
      // Assert
      expect(_rules.cleanName('  Bouboule  '), 'Bouboule');
      expect(_rules.cleanName('   '), 'Lim');
      expect(_rules.cleanName('Supercalifragilistique'), 'Supercalifra');
    });
  });

  group('Mascot use cases', () {
    late InMemoryMascotRepository repository;
    late FixedRewardService rewards;
    late FixedCrownService crowns;
    late GetMascotUseCase getMascot;
    late UpdateMascotUseCases update;

    setUp(() {
      repository = InMemoryMascotRepository();
      rewards = FixedRewardService(level: 6, badges: <String>{'regular'});
      crowns = FixedCrownService(crowns: 1);
      getMascot = GetMascotUseCase(
        repository: repository,
        rewards: rewards,
        crowns: crowns,
      );
      update = UpdateMascotUseCases(repository: repository);
    });

    test('builds the mascot of a player', () async {
      // Act
      final MascotEntity actualMascot = (await getMascot(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actualMascot.name, 'Lim');
      expect(actualMascot.stage, 2);
      expect(actualMascot.nextStageLevel, 10);
      expect(actualMascot.unlocked, <MascotAccessory>{
        MascotAccessory.cap,
        MascotAccessory.partyHat,
      });
      expect(actualMascot.worn, isEmpty);
      expect(actualMascot.isNewStage, isTrue);
    });
    test('renames it, dresses it and remembers the celebration', () async {
      // Act
      await update.rename(profileId: 'p1', name: 'Bouboule');
      await update.toggleAccessory(
        profileId: 'p1',
        accessory: MascotAccessory.cap,
      );
      await update.toggleAccessory(
        profileId: 'p1',
        accessory: MascotAccessory.partyHat,
      );
      await update.markCelebrated(profileId: 'p1', stage: 2);
      final MascotEntity actualMascot = (await getMascot(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actualMascot.name, 'Bouboule');
      expect(actualMascot.worn, <AccessorySlot, MascotAccessory>{
        AccessorySlot.head: MascotAccessory.partyHat,
      });
      expect(actualMascot.isNewStage, isFalse);
    });
    test('takes an accessory off when it is worn again', () async {
      // Arrange
      await update.toggleAccessory(
        profileId: 'p1',
        accessory: MascotAccessory.cap,
      );
      // Act
      await update.toggleAccessory(
        profileId: 'p1',
        accessory: MascotAccessory.cap,
      );
      // Assert
      expect(repository.records['p1']!.worn, isEmpty);
    });
    test('never celebrates a stage twice, nor goes back', () async {
      // Arrange
      await update.markCelebrated(profileId: 'p1', stage: 3);
      // Act
      await update.markCelebrated(profileId: 'p1', stage: 2);
      // Assert
      expect(repository.records['p1']!.celebratedStage, 3);
    });
    test('fails when a source cannot be read', () async {
      // Arrange
      rewards.failure = const CacheException();
      // Act
      final AppException? actualException = (await getMascot(
        params: 'p1',
      )).exceptionOrNull;
      repository.failure = const CacheException();
      final AppException? actualUpdate = (await update.rename(
        profileId: 'p1',
        name: 'Bob',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
      expect(actualUpdate, isA<CacheException>());
    });
  });
}
