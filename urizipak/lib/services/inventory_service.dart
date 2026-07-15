import 'package:flutter/foundation.dart';

import '../core/event_bus.dart';
import '../domain/models/item.dart';
import '../domain/repositories/repositories.dart';
import 'app_money_ledger.dart';

/// 이미 보유한 아이템을 다시 구매하려 할 때.
class AlreadyOwnedException implements Exception {
  const AlreadyOwnedException(this.itemId);

  final String itemId;
}

/// 인벤토리 서비스. 보유 아이템 관리 + 구매(AppMoney 차감의 유일한 진입점).
///
/// 착용은 CharacterManager, 배치는 RoomService가 담당한다.
/// (그 둘은 이 서비스를 모른다 — 소유 검증은 ViewModel이
/// [owns]로 확인한 뒤 각 서비스를 호출한다.)
class InventoryService extends ChangeNotifier {
  InventoryService({
    required this._repository,
    required this._ledger,
    required this._bus,
  });

  final InventoryRepository _repository;
  final AppMoneyLedger _ledger;
  final AppEventBus _bus;

  Set<String> _ownedIds = {};

  Future<void> init() async {
    _ownedIds = await _repository.loadOwnedItemIds();
    notifyListeners();
  }

  Set<String> get ownedIds => Set.unmodifiable(_ownedIds);

  bool owns(String itemId) => _ownedIds.contains(itemId);

  /// AppMoney로 아이템을 구매한다.
  ///
  /// 잔액 부족 시 [InsufficientAppMoneyException],
  /// 중복 구매 시 [AlreadyOwnedException].
  Future<void> purchase(ItemModel item) async {
    if (owns(item.id)) throw AlreadyOwnedException(item.id);
    await _ledger.debit(amount: item.price, reason: '${item.name} 구매');
    _ownedIds.add(item.id);
    await _repository.saveOwnedItemIds(_ownedIds);
    notifyListeners();
    _bus.publish(ItemPurchased(itemId: item.id));
  }

  /// 아이템 삭제(정리). 환불은 하지 않는다.
  Future<void> discard(String itemId) async {
    if (!_ownedIds.remove(itemId)) return;
    await _repository.saveOwnedItemIds(_ownedIds);
    notifyListeners();
  }
}
