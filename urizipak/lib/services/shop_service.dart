import 'package:flutter/foundation.dart';

import '../domain/models/item.dart';
import '../domain/repositories/repositories.dart';

/// 상점 서비스. 판매 카탈로그 제공.
///
/// MVP는 더미 카탈로그([DummyShopCatalogRepository]),
/// 추후 Firebase 카탈로그 구현으로 교체 (이 서비스는 수정 없음).
class ShopService extends ChangeNotifier {
  ShopService({required this._catalogRepository});

  final ShopCatalogRepository _catalogRepository;

  List<ItemModel> _catalog = [];

  Future<void> init() async {
    _catalog = await _catalogRepository.loadCatalog();
    notifyListeners();
  }

  List<ItemModel> get catalog => List.unmodifiable(_catalog);

  ItemModel? itemById(String id) {
    for (final item in _catalog) {
      if (item.id == id) return item;
    }
    return null;
  }

  Map<ItemCategory, List<ItemModel>> get catalogByCategory {
    final grouped = <ItemCategory, List<ItemModel>>{};
    for (final item in _catalog) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }
}
