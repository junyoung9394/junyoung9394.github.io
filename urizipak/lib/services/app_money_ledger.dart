import 'package:flutter/foundation.dart';

import '../core/ids.dart';
import '../domain/models/app_money.dart';
import '../domain/repositories/repositories.dart';

/// AppMoney 잔액이 부족할 때 던져지는 예외.
class InsufficientAppMoneyException implements Exception {
  const InsufficientAppMoneyException({
    required this.balance,
    required this.required,
  });

  final int balance;
  final int required;

  @override
  String toString() =>
      'InsufficientAppMoneyException(balance: $balance, required: $required)';
}

/// AppMoney 내부 원장.
///
/// [중요한 규칙]
/// 이 클래스는 서비스 계층 내부 전용이다. UI/ViewModel은 절대 직접 쓰지 않는다.
/// - 적립([credit])의 유일한 호출자는 RewardService다.
/// - 차감([debit])의 유일한 호출자는 InventoryService(구매)다.
/// `money +=` 같은 직접 조작을 막기 위해 잔액은 저장하지 않고
/// 원장 엔트리의 합으로만 계산한다.
class AppMoneyLedger extends ChangeNotifier {
  AppMoneyLedger(this._repository);

  final AppMoneyRepository _repository;

  List<AppMoneyEntry> _entries = [];
  int _balance = 0;

  Future<void> init() async {
    _entries = await _repository.loadLedger();
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _balance = _entries.fold(0, (sum, e) => sum + e.amount);
    notifyListeners();
  }

  int get balance => _balance;

  /// 최신순 원장 내역.
  List<AppMoneyEntry> get entries => List.unmodifiable(_entries);

  bool canAfford(int amount) => _balance >= amount;

  /// 보상 적립. RewardService 전용.
  Future<AppMoneyEntry> credit({required int amount, required String reason}) {
    assert(amount > 0, '적립 금액은 양수여야 한다');
    return _append(
      AppMoneyEntry(
        id: IdGenerator.next(),
        type: AppMoneyEntryType.reward,
        amount: amount,
        reason: reason,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// 구매 차감. InventoryService 전용.
  Future<AppMoneyEntry> debit({required int amount, required String reason}) {
    assert(amount > 0, '차감 금액은 양수여야 한다');
    if (_balance < amount) {
      throw InsufficientAppMoneyException(balance: _balance, required: amount);
    }
    return _append(
      AppMoneyEntry(
        id: IdGenerator.next(),
        type: AppMoneyEntryType.purchase,
        amount: -amount,
        reason: reason,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<AppMoneyEntry> _append(AppMoneyEntry entry) async {
    await _repository.append(entry);
    _entries.insert(0, entry);
    _balance += entry.amount;
    notifyListeners();
    return entry;
  }
}
