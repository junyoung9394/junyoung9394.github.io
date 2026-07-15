import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/event_bus.dart';
import '../data/catalog/dummy_shop_catalog.dart';
import '../data/local/local_couple_connector.dart';
import '../data/local/local_repositories.dart';
import '../data/local/local_store.dart';
import '../services/ads/ad_service.dart';
import '../services/app_money_ledger.dart';
import '../services/app_money_service.dart';
import '../services/asset_service.dart';
import '../services/character_manager.dart';
import '../services/couple_service.dart';
import '../services/goal_service.dart';
import '../services/inventory_service.dart';
import '../services/reward_service.dart';
import '../services/room_service.dart';
import '../services/shop_service.dart';
import '../services/sync/sync_service.dart';
import '../services/theme_service.dart';
import '../services/transaction_service.dart';

/// 조립 루트(Composition Root).
///
/// 우리지갑의 모든 의존성 배선은 여기 한 곳에서만 이루어진다.
/// - 모듈(서비스)들은 서로를 직접 참조하지 않는다 (이벤트 버스로 통신).
/// - Firebase 연동 시: 이 파일에서 Local* 리포지토리를 Firestore 구현으로,
///   LocalOnlySyncService를 FirebaseSyncService로 교체하면 끝.
/// - AdMob 연동 시: NoopAdService를 GoogleAdService로 교체.
class AppServices {
  AppServices._({
    required this.bus,
    required this.appMoney,
    required this.rewards,
    required this.transactions,
    required this.goals,
    required this.assets,
    required this.characters,
    required this.room,
    required this.inventory,
    required this.shop,
    required this.theme,
    required this.couple,
    required this.sync,
    required this.ads,
  });

  final AppEventBus bus;
  final AppMoneyService appMoney;
  final RewardService rewards;
  final TransactionService transactions;
  final GoalService goals;
  final AssetService assets;
  final CharacterManager characters;
  final RoomService room;
  final InventoryService inventory;
  final ShopService shop;
  final ThemeService theme;
  final CoupleService couple;
  final SyncService sync;
  final AdService ads;

  static Future<AppServices> create({LocalStore? storeOverride}) async {
    final store =
        storeOverride ?? SharedPreferencesLocalStore(SharedPreferencesAsync());
    final bus = AppEventBus();

    // ── 리포지토리 (Local First — Firebase 교체 지점) ────────────
    final settingsRepo = LocalSettingsRepository(store);
    final ledger = AppMoneyLedger(LocalAppMoneyRepository(store));

    final theme = ThemeService(settings: settingsRepo, bus: bus);
    await theme.init();

    // ── 서비스 ──────────────────────────────────────────────
    final rewards = RewardService(
      ledger: ledger,
      settings: settingsRepo,
      bus: bus,
    )..start();

    final transactions = TransactionService(
      repository: LocalTransactionRepository(store),
      bus: bus,
    );
    final goals = GoalService(repository: LocalGoalRepository(store), bus: bus);
    final assets = AssetService(
      repository: LocalAssetRepository(store),
      stockPrices: const ManualStockPriceRepository(),
    );
    final characters = CharacterManager(
      repository: LocalCharacterRepository(store),
      settings: settingsRepo,
      bus: bus,
    );
    final room = RoomService(
      repository: LocalRoomRepository(store),
      bus: bus,
      initialThemeId: theme.current.name,
    );
    final inventory = InventoryService(
      repository: LocalInventoryRepository(store),
      ledger: ledger,
      bus: bus,
    );
    final shop = ShopService(
      catalogRepository: const DummyShopCatalogRepository(),
    );
    final couple = CoupleService(
      repository: LocalCoupleRepository(store),
      connector: LocalCoupleConnector(),
      bus: bus,
    );

    await Future.wait([
      ledger.init(),
      transactions.init(),
      goals.init(),
      assets.init(),
      characters.init(),
      room.init(),
      inventory.init(),
      shop.init(),
      couple.init(),
    ]);

    // 앱 실행 = 출석. (캐릭터 celebrate 반응까지 이벤트로 이어진다)
    await rewards.checkDailyAttendance();

    return AppServices._(
      bus: bus,
      appMoney: AppMoneyService(ledger),
      rewards: rewards,
      transactions: transactions,
      goals: goals,
      assets: assets,
      characters: characters,
      room: room,
      inventory: inventory,
      shop: shop,
      theme: theme,
      couple: couple,
      sync: const LocalOnlySyncService(),
      ads: const NoopAdService(),
    );
  }

  void dispose() {
    rewards.dispose();
    bus.dispose();
  }
}

/// 위젯 트리에 [AppServices]를 내려주는 InheritedWidget.
/// ViewModel/화면은 `AppServicesScope.of(context)`로 서비스에 접근한다.
class AppServicesScope extends InheritedWidget {
  const AppServicesScope({
    super.key,
    required this.services,
    required super.child,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppServicesScope>();
    assert(scope != null, 'AppServicesScope가 위젯 트리에 없습니다');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) =>
      services != oldWidget.services;
}
