import 'package:flutter/foundation.dart';

import '../../domain/models/item.dart';
import '../../services/app_money_ledger.dart';
import '../../services/app_money_service.dart';
import '../../services/inventory_service.dart';
import '../../services/shop_service.dart';

/// 구매 시도 결과 (UI 메시지 매핑용).
enum PurchaseResult { success, alreadyOwned, notEnoughMoney }

/// 상점 화면의 프레젠테이션 로직.
class ShopViewModel extends ChangeNotifier {
  ShopViewModel({
    required this._shop,
    required this._inventory,
    required this._appMoney,
  }) {
    _shop.addListener(notifyListeners);
    _inventory.addListener(notifyListeners);
    _appMoney.listenable.addListener(notifyListeners);
  }

  final ShopService _shop;
  final InventoryService _inventory;
  final AppMoneyService _appMoney;

  int get balance => _appMoney.balance;

  Map<ItemCategory, List<ItemModel>> get catalogByCategory =>
      _shop.catalogByCategory;

  bool owns(String itemId) => _inventory.owns(itemId);

  bool canAfford(ItemModel item) => _appMoney.canAfford(item.price);

  Future<PurchaseResult> purchase(ItemModel item) async {
    try {
      await _inventory.purchase(item);
      return PurchaseResult.success;
    } on AlreadyOwnedException {
      return PurchaseResult.alreadyOwned;
    } on InsufficientAppMoneyException {
      return PurchaseResult.notEnoughMoney;
    }
  }

  @override
  void dispose() {
    _shop.removeListener(notifyListeners);
    _inventory.removeListener(notifyListeners);
    _appMoney.listenable.removeListener(notifyListeners);
    super.dispose();
  }
}
