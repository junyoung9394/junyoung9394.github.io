import 'package:flutter/foundation.dart';

import '../../domain/models/item.dart';
import '../../domain/models/room.dart';
import '../../services/inventory_service.dart';
import '../../services/room_service.dart';
import '../../services/shop_service.dart';

/// 우리 공간 화면의 프레젠테이션 로직.
///
/// 서비스 간 조율(소유 검증 → 배치)은 서비스가 아니라 여기서 한다.
class RoomViewModel extends ChangeNotifier {
  RoomViewModel({
    required this._room,
    required this._inventory,
    required this._shop,
  }) {
    _room.addListener(notifyListeners);
    _inventory.addListener(notifyListeners);
    _shop.addListener(notifyListeners);
  }

  final RoomService _room;
  final InventoryService _inventory;
  final ShopService _shop;

  RoomModel get room => _room.room;

  /// 슬롯에 배치된 아이템 (없으면 null).
  ItemModel? placedItem(RoomSlot slot) {
    final id = _room.room.itemAt(slot);
    return id == null ? null : _shop.itemById(id);
  }

  /// 해당 슬롯에 배치할 수 있는 보유 아이템 목록.
  List<ItemModel> ownedItemsFor(RoomSlot slot) => _shop.catalog
      .where((item) => item.roomSlot == slot && _inventory.owns(item.id))
      .toList();

  Future<void> place(RoomSlot slot, ItemModel item) async {
    if (!_inventory.owns(item.id)) return; // 소유 검증
    await _room.placeItem(slot, item.id);
  }

  Future<void> clear(RoomSlot slot) => _room.clearSlot(slot);

  @override
  void dispose() {
    _room.removeListener(notifyListeners);
    _inventory.removeListener(notifyListeners);
    _shop.removeListener(notifyListeners);
    super.dispose();
  }
}
