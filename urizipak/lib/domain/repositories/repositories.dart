/// 데이터 접근 계약(인터페이스) 모음.
///
/// [설계 원칙 — Local First]
/// 서비스 계층은 이 인터페이스에만 의존한다.
/// 현재 구현은 로컬 저장소(data/local/*)이며,
/// Firebase 연동 시 이 인터페이스의 Firestore 구현만 추가하고
/// 조립 루트(app/di.dart)에서 갈아끼우면 된다. 서비스/UI는 수정하지 않는다.
library;

import '../models/app_money.dart';
import '../models/asset_item.dart';
import '../models/character.dart';
import '../models/couple.dart';
import '../models/item.dart';
import '../models/room.dart';
import '../models/saving_goal.dart';
import '../models/transaction_entry.dart';

abstract interface class TransactionRepository {
  Future<List<TransactionEntry>> loadAll();

  Future<void> save(TransactionEntry entry);

  Future<void> delete(String id);
}

abstract interface class GoalRepository {
  Future<List<SavingGoal>> loadGoals();

  Future<void> saveGoal(SavingGoal goal);

  Future<void> deleteGoal(String id);

  Future<List<GoalContribution>> loadContributions(String goalId);

  Future<void> saveContribution(GoalContribution contribution);
}

abstract interface class AssetRepository {
  Future<List<AssetItem>> loadAll();

  Future<void> save(AssetItem item);

  Future<void> delete(String id);
}

/// 주식/ETF 시세 조회 계약.
///
/// MVP에서는 수동 입력 평가액을 그대로 돌려주는 구현([data/local/manual_stock_price_repository.dart])을 쓰고,
/// 향후 국내 주식 API(KIS, 한국투자증권 등) 구현으로 교체한다.
abstract interface class StockPriceRepository {
  /// 종목의 현재가(원)를 조회한다. 조회 불가 시 null.
  Future<int?> currentPrice(String ticker);
}

abstract interface class AppMoneyRepository {
  Future<List<AppMoneyEntry>> loadLedger();

  Future<void> append(AppMoneyEntry entry);
}

abstract interface class InventoryRepository {
  /// 보유 아이템 ID 목록.
  Future<Set<String>> loadOwnedItemIds();

  Future<void> saveOwnedItemIds(Set<String> ids);
}

abstract interface class CharacterRepository {
  Future<Map<PartnerSlot, CharacterProfile>> loadProfiles();

  Future<void> saveProfiles(Map<PartnerSlot, CharacterProfile> profiles);
}

abstract interface class RoomRepository {
  Future<RoomModel?> loadRoom();

  Future<void> saveRoom(RoomModel room);
}

/// 상점 카탈로그 계약. MVP는 로컬 더미 데이터, 추후 Firebase Remote Config/Firestore.
abstract interface class ShopCatalogRepository {
  Future<List<ItemModel>> loadCatalog();
}

/// 커플 연결 상태 저장 계약.
abstract interface class CoupleRepository {
  Future<CoupleLink?> load();

  Future<void> save(CoupleLink link);
}

/// 커플 연결(페어링) 동작 계약.
///
/// MVP 구현([data/local/local_couple_connector.dart])은 코드 형식만 검증하는
/// 로컬 시뮬레이션이다. Firebase 연동 시 초대 코드를 Firestore
/// invites/{code} 문서로 발급/검증하는 구현으로 교체한다 (docs/FIREBASE.md 참고).
abstract interface class CoupleConnector {
  /// 내 초대 코드를 발급한다.
  Future<String> issueInviteCode();

  /// 상대방의 초대 코드로 연결한다. 성공 시 연결된 [CoupleLink] 반환.
  Future<CoupleLink> connectWithCode(String code);

  /// 연결을 해제한다.
  Future<void> disconnect();
}

/// 앱 설정 + 보상 지급 이력 등 단순 key-value 상태 저장 계약.
abstract interface class SettingsRepository {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);
}
