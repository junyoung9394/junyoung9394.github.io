import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/event_bus.dart';
import '../domain/models/room.dart';
import '../domain/repositories/repositories.dart';

/// 우리 공간(방) 서비스. Slot 방식 고정 배치, 드래그 없음.
///
/// 배치할 아이템의 소유 검증은 호출자(ViewModel이 InventoryService로) 책임.
class RoomService extends ChangeNotifier {
  RoomService({
    required this._repository,
    required this._bus,
    required this._initialThemeId,
  });

  final RoomRepository _repository;
  final AppEventBus _bus;
  final String _initialThemeId;

  late RoomModel _room = RoomModel.initial(_initialThemeId);
  StreamSubscription<ThemeChanged>? _themeSubscription;

  Future<void> init() async {
    _room =
        (await _repository.loadRoom()) ?? RoomModel.initial(_initialThemeId);
    // 계절은 열 때마다 현재 날짜 기준으로 갱신 (계절 한정 데코 대비).
    _room = _room.copyWith(season: RoomSeason.fromDate(DateTime.now()));
    _themeSubscription = _bus.on<ThemeChanged>().listen(
      (e) => _applyTheme(e.themeId),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _themeSubscription?.cancel();
    super.dispose();
  }

  RoomModel get room => _room;

  /// 가구/반려동물을 슬롯에 배치한다.
  Future<void> placeItem(RoomSlot slot, String itemId) async {
    if (slot == RoomSlot.pet) {
      await _update(_room.copyWith(petItemId: itemId));
    } else {
      final furniture = Map<RoomSlot, String>.from(_room.furniture)
        ..[slot] = itemId;
      await _update(_room.copyWith(furniture: furniture));
    }
  }

  /// 슬롯을 비운다.
  Future<void> clearSlot(RoomSlot slot) async {
    if (slot == RoomSlot.pet) {
      await _update(_room.copyWith(clearPet: true));
    } else {
      final furniture = Map<RoomSlot, String>.from(_room.furniture)
        ..remove(slot);
      await _update(_room.copyWith(furniture: furniture));
    }
  }

  Future<void> setWallpaper(String? itemId) => _update(
    _room.copyWith(wallpaperItemId: itemId, clearWallpaper: itemId == null),
  );

  Future<void> setFloor(String? itemId) =>
      _update(_room.copyWith(floorItemId: itemId, clearFloor: itemId == null));

  Future<void> _applyTheme(String themeId) =>
      _update(_room.copyWith(themeId: themeId), publish: false);

  Future<void> _update(RoomModel next, {bool publish = true}) async {
    _room = next;
    await _repository.saveRoom(next);
    notifyListeners();
    if (publish) _bus.publish(const RoomUpdated());
  }
}
