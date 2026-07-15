/// 로컬(Local-First) 리포지토리 구현 모음.
///
/// 각 구현은 [LocalStore] 위의 JSON 직렬화로 동작한다.
/// Firebase 연동 시 이 파일은 그대로 두고 Firestore 구현을 추가한 뒤
/// app/di.dart에서 바인딩만 교체한다.
library;

import 'dart:convert';

import '../../domain/models/app_money.dart';
import '../../domain/models/asset_item.dart';
import '../../domain/models/character.dart';
import '../../domain/models/room.dart';
import '../../domain/models/saving_goal.dart';
import '../../domain/models/transaction_entry.dart';
import '../../domain/repositories/repositories.dart';
import 'json_collection.dart';
import 'local_store.dart';

class LocalTransactionRepository implements TransactionRepository {
  LocalTransactionRepository(LocalStore store)
    : _collection = JsonCollection<TransactionEntry>(
        store: store,
        storageKey: 'transactions',
        toJson: (e) => e.toJson(),
        fromJson: TransactionEntry.fromJson,
        idOf: (e) => e.id,
      );

  final JsonCollection<TransactionEntry> _collection;

  @override
  Future<List<TransactionEntry>> loadAll() => _collection.loadAll();

  @override
  Future<void> save(TransactionEntry entry) => _collection.upsert(entry);

  @override
  Future<void> delete(String id) => _collection.deleteById(id);
}

class LocalGoalRepository implements GoalRepository {
  LocalGoalRepository(LocalStore store)
    : _goals = JsonCollection<SavingGoal>(
        store: store,
        storageKey: 'goals',
        toJson: (g) => g.toJson(),
        fromJson: SavingGoal.fromJson,
        idOf: (g) => g.id,
      ),
      _contributions = JsonCollection<GoalContribution>(
        store: store,
        storageKey: 'goal_contributions',
        toJson: (c) => c.toJson(),
        fromJson: GoalContribution.fromJson,
        idOf: (c) => c.id,
      );

  final JsonCollection<SavingGoal> _goals;
  final JsonCollection<GoalContribution> _contributions;

  @override
  Future<List<SavingGoal>> loadGoals() => _goals.loadAll();

  @override
  Future<void> saveGoal(SavingGoal goal) => _goals.upsert(goal);

  @override
  Future<void> deleteGoal(String id) async {
    await _goals.deleteById(id);
    final remaining = (await _contributions.loadAll())
        .where((c) => c.goalId != id)
        .toList();
    await _contributions.saveAll(remaining);
  }

  @override
  Future<List<GoalContribution>> loadContributions(String goalId) async {
    final all = await _contributions.loadAll();
    return all.where((c) => c.goalId == goalId).toList();
  }

  @override
  Future<void> saveContribution(GoalContribution contribution) =>
      _contributions.upsert(contribution);
}

class LocalAssetRepository implements AssetRepository {
  LocalAssetRepository(LocalStore store)
    : _collection = JsonCollection<AssetItem>(
        store: store,
        storageKey: 'assets',
        toJson: (a) => a.toJson(),
        fromJson: AssetItem.fromJson,
        idOf: (a) => a.id,
      );

  final JsonCollection<AssetItem> _collection;

  @override
  Future<List<AssetItem>> loadAll() => _collection.loadAll();

  @override
  Future<void> save(AssetItem item) => _collection.upsert(item);

  @override
  Future<void> delete(String id) => _collection.deleteById(id);
}

/// MVP용 시세 조회: 항상 null을 돌려 수동 입력 평가액을 쓰게 한다.
/// 국내 주식 API 연동 시 이 클래스 대신 API 구현을 바인딩한다.
class ManualStockPriceRepository implements StockPriceRepository {
  const ManualStockPriceRepository();

  @override
  Future<int?> currentPrice(String ticker) async => null;
}

class LocalAppMoneyRepository implements AppMoneyRepository {
  LocalAppMoneyRepository(LocalStore store)
    : _collection = JsonCollection<AppMoneyEntry>(
        store: store,
        storageKey: 'app_money_ledger',
        toJson: (e) => e.toJson(),
        fromJson: AppMoneyEntry.fromJson,
        idOf: (e) => e.id,
      );

  final JsonCollection<AppMoneyEntry> _collection;

  @override
  Future<List<AppMoneyEntry>> loadLedger() => _collection.loadAll();

  @override
  Future<void> append(AppMoneyEntry entry) => _collection.upsert(entry);
}

class LocalInventoryRepository implements InventoryRepository {
  LocalInventoryRepository(this._store);

  final LocalStore _store;

  static const String _key = 'inventory_owned';

  @override
  Future<Set<String>> loadOwnedItemIds() async {
    final raw = await _store.read(_key);
    if (raw == null || raw.isEmpty) return {};
    return (jsonDecode(raw) as List<dynamic>).cast<String>().toSet();
  }

  @override
  Future<void> saveOwnedItemIds(Set<String> ids) =>
      _store.write(_key, jsonEncode(ids.toList()));
}

class LocalCharacterRepository implements CharacterRepository {
  LocalCharacterRepository(this._store);

  final LocalStore _store;

  static const String _key = 'character_profiles';

  @override
  Future<Map<PartnerSlot, CharacterProfile>> loadProfiles() async {
    final raw = await _store.read(_key);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as List<dynamic>;
    final profiles = decoded.map(
      (e) => CharacterProfile.fromJson(e as Map<String, dynamic>),
    );
    return {for (final p in profiles) p.slot: p};
  }

  @override
  Future<void> saveProfiles(Map<PartnerSlot, CharacterProfile> profiles) {
    final encoded = jsonEncode(profiles.values.map((p) => p.toJson()).toList());
    return _store.write(_key, encoded);
  }
}

class LocalRoomRepository implements RoomRepository {
  LocalRoomRepository(this._store);

  final LocalStore _store;

  static const String _key = 'room';

  @override
  Future<RoomModel?> loadRoom() async {
    final raw = await _store.read(_key);
    if (raw == null || raw.isEmpty) return null;
    return RoomModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveRoom(RoomModel room) =>
      _store.write(_key, jsonEncode(room.toJson()));
}

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._store);

  final LocalStore _store;

  @override
  Future<String?> getString(String key) => _store.read('settings.$key');

  @override
  Future<void> setString(String key, String value) =>
      _store.write('settings.$key', value);
}
