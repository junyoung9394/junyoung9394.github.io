import 'package:flutter/foundation.dart';

import '../domain/models/app_money.dart';
import 'app_money_ledger.dart';

/// UI가 바라보는 AppMoney의 읽기 전용 창구.
///
/// 잔액 조회와 내역 조회만 제공한다.
/// - 적립은 RewardService.grant()로만
/// - 차감은 InventoryService.purchase()로만
/// 이 클래스에 적립/차감 메서드를 추가하지 말 것.
class AppMoneyService {
  AppMoneyService(this._ledger);

  final AppMoneyLedger _ledger;

  /// 잔액 변경을 구독할 수 있는 Listenable.
  Listenable get listenable => _ledger;

  int get balance => _ledger.balance;

  List<AppMoneyEntry> get history => _ledger.entries;

  bool canAfford(int amount) => _ledger.canAfford(amount);
}
