import 'package:flutter/foundation.dart';

import '../core/ids.dart';
import '../domain/models/asset_item.dart';
import '../domain/repositories/repositories.dart';

/// 자산 관리 서비스. 현금/예금/적금/주식/ETF/부채와 순자산.
///
/// MVP는 전 유형 수동 입력.
/// 주식/ETF는 [StockPriceRepository]가 시세를 돌려주기 시작하면
/// [refreshMarketPrices]가 보유 수량 × 현재가로 평가액을 자동 갱신한다.
/// (지금의 ManualStockPriceRepository는 항상 null → 수동 입력 유지)
class AssetService extends ChangeNotifier {
  AssetService({required this._repository, required this._stockPrices});

  final AssetRepository _repository;
  final StockPriceRepository _stockPrices;

  List<AssetItem> _items = [];

  Future<void> init() async {
    _items = await _repository.loadAll();
    _sort();
    notifyListeners();
  }

  List<AssetItem> get items => List.unmodifiable(_items);

  List<AssetItem> itemsOfType(AssetType type) =>
      _items.where((a) => a.type == type).toList();

  NetWorthSummary get summary {
    var totalAssets = 0;
    var totalDebt = 0;
    final byType = <AssetType, int>{};
    for (final item in _items) {
      byType[item.type] = (byType[item.type] ?? 0) + item.amount;
      if (item.type.isDebt) {
        totalDebt += item.amount;
      } else {
        totalAssets += item.amount;
      }
    }
    return NetWorthSummary(
      totalAssets: totalAssets,
      totalDebt: totalDebt,
      byType: byType,
    );
  }

  Future<AssetItem> add({
    required AssetType type,
    required String name,
    required int amount,
    String memo = '',
    String? ticker,
    double? quantity,
  }) async {
    final item = AssetItem(
      id: IdGenerator.next(),
      type: type,
      name: name,
      amount: amount,
      memo: memo,
      ticker: ticker,
      quantity: quantity,
      updatedAt: DateTime.now(),
    );
    await _repository.save(item);
    _items.add(item);
    _sort();
    notifyListeners();
    return item;
  }

  Future<void> update(AssetItem item) async {
    final updated = item.copyWith(updatedAt: DateTime.now());
    await _repository.save(updated);
    final index = _items.indexWhere((a) => a.id == item.id);
    if (index >= 0) _items[index] = updated;
    _sort();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    _items.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  /// 주식/ETF 평가액을 시세 API로 갱신한다.
  /// 시세를 못 가져온 종목은 수동 입력 평가액을 유지한다.
  Future<void> refreshMarketPrices() async {
    var changed = false;
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      final isMarketAsset =
          item.type == AssetType.stock || item.type == AssetType.etf;
      if (!isMarketAsset || item.ticker == null || item.quantity == null) {
        continue;
      }
      final price = await _stockPrices.currentPrice(item.ticker!);
      if (price == null) continue;
      final updated = item.copyWith(
        amount: (price * item.quantity!).round(),
        updatedAt: DateTime.now(),
      );
      await _repository.save(updated);
      _items[i] = updated;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void _sort() {
    _items.sort((a, b) {
      final byType = a.type.index.compareTo(b.type.index);
      return byType != 0 ? byType : b.amount.compareTo(a.amount);
    });
  }
}
