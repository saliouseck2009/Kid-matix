import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/progress_reset_service.dart';
import 'package:kid_matix/core/services/reward_service.dart';
import 'package:kid_matix/core/services/xp_award_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_total_xp_use_case.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_entity.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer_status.dart';
import 'package:kid_matix/features/shop/domain/usecases/buy_shop_item_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/get_active_theme_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/get_shop_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/shop_item_params.dart';
import 'package:kid_matix/features/shop/domain/usecases/use_shop_item_use_case.dart';

import '../helpers/data_state_test_extension.dart';
import '../helpers/in_memory_local_storage.dart';
import 'helpers/test_app.dart';

/// The shop over the real wiring and an on-disk database: coins earned
/// by a quiz and a duel, a purchase, the avatar worn and the theme
/// applied, then the progress reset that takes the coins back.
void main() {
  late Directory databaseFolder;

  setUp(() async {
    databaseFolder = await Directory.systemTemp.createTemp('kid_matix_');
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: InMemoryLocalStorage(),
    );
  });

  tearDown(() async {
    await TestApp.stop();
    await databaseFolder.delete(recursive: true);
  });

  Future<ShopEntity> readShop(String profileId) async {
    return (await sl<GetShopUseCase>()(params: profileId)).requireData;
  }

  Future<void> playFirstStage(String profileId) async {
    final QuizBloc bloc = TestApp.quizBloc();
    await TestApp.startQuiz(
      bloc,
      TestApp.stageRequest(
        profileId: profileId,
        unitKey: 'mul:1',
        stage: StageKind.discovery,
      ),
    );
    await TestApp.playToEnd(bloc);
    await bloc.close();
  }

  test('earns coins by playing, buys, wears and resets', () async {
    // Arrange: a new player wins a stage, a badge and a duel.
    final ProfileEntity player = await TestApp.createPlayer('Awa');
    expect((await readShop(player.id)).balance, 0);
    await playFirstStage(player.id);
    await sl<XpAwardService>().awardXp(
      profileId: player.id,
      xp: 600,
      sourceKey: 'duel',
    );
    final int totalXp = (await sl<GetTotalXpUseCase>()(
      params: player.id,
    )).requireData;
    final int badges = (await sl<RewardService>().readBadgeKeys(
      profileId: player.id,
    )).requireData.length;
    // Act
    final ShopEntity actualEarned = await readShop(player.id);
    // Assert: one coin every 10 XP, quiz and duel, plus 10 per badge.
    expect(actualEarned.balance, totalXp ~/ 10 + 10 * badges);
    expect(actualEarned.balance, greaterThanOrEqualTo(80));
    expect(
      actualEarned.findOffer('avatar:fox')!.status,
      ShopOfferStatus.affordable,
    );
    // Act: the fox is bought, worn, and the lavender theme stays.
    final DataState<void> actualPurchase = await sl<BuyShopItemUseCase>()(
      params: ShopItemParams(profileId: player.id, itemId: 'avatar:fox'),
    );
    final DataState<void> actualAgain = await sl<BuyShopItemUseCase>()(
      params: ShopItemParams(profileId: player.id, itemId: 'avatar:fox'),
    );
    await sl<UseShopItemUseCase>()(
      params: ShopItemParams(profileId: player.id, itemId: 'avatar:fox'),
    );
    final ShopEntity actualAfter = await readShop(player.id);
    final ProfileEntity actualPlayer = (await sl<GetProfileUseCase>()(
      params: player.id,
    )).requireData;
    // Assert
    expect(actualPurchase, isA<DataSuccess<void>>());
    expect(actualAgain.exceptionOrNull?.code, AppErrorCode.conflict);
    expect(actualAfter.balance, actualEarned.balance - 80);
    expect(actualAfter.findOffer('avatar:fox')!.status, ShopOfferStatus.inUse);
    expect(actualPlayer.avatar, ProfileAvatar.fox);
    // Act: the progress is reset.
    await sl<ProgressResetService>().resetProgress(profileId: player.id);
    final ShopEntity actualReset = await readShop(player.id);
    final AppColorTheme actualTheme = (await sl<GetActiveThemeUseCase>()(
      params: player.id,
    )).requireData;
    // Assert: no coins, no purchase; the fox stays worn.
    expect(actualReset.balance, 0);
    expect(actualReset.findOffer('avatar:fox')!.status, ShopOfferStatus.inUse);
    expect(
      actualReset.findOffer('avatar:panda')!.status,
      ShopOfferStatus.tooExpensive,
    );
    expect(actualTheme, AppColorTheme.lavender);
  });
}
