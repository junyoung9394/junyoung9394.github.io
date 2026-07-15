import 'package:flutter/foundation.dart';

import '../../domain/models/transaction_entry.dart';
import '../../services/transaction_service.dart';

/// 가계부 화면의 프레젠테이션 로직: 월 이동 + 일자별 그룹핑.
class LedgerViewModel extends ChangeNotifier {
  LedgerViewModel({required this._transactions}) {
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _transactions.addListener(notifyListeners);
  }

  final TransactionService _transactions;

  late int _year;
  late int _month;

  int get year => _year;

  int get month => _month;

  MonthlySummary get summary => _transactions.summaryOf(_year, _month);

  /// 날짜(일) → 그날의 거래 목록. 최신 날짜가 먼저.
  Map<DateTime, List<TransactionEntry>> get entriesByDay {
    final grouped = <DateTime, List<TransactionEntry>>{};
    for (final entry in _transactions.entriesInMonth(_year, _month)) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      grouped.putIfAbsent(day, () => []).add(entry);
    }
    return grouped;
  }

  void previousMonth() {
    final prev = DateTime(_year, _month - 1);
    _year = prev.year;
    _month = prev.month;
    notifyListeners();
  }

  void nextMonth() {
    final next = DateTime(_year, _month + 1);
    _year = next.year;
    _month = next.month;
    notifyListeners();
  }

  Future<void> add({
    required TransactionType type,
    required int amount,
    required TransactionCategory category,
    required DateTime date,
    required RecordedBy recordedBy,
    String memo = '',
  }) {
    return _transactions.add(
      type: type,
      amount: amount,
      category: category,
      date: date,
      recordedBy: recordedBy,
      memo: memo,
    );
  }

  Future<void> remove(String id) => _transactions.remove(id);

  @override
  void dispose() {
    _transactions.removeListener(notifyListeners);
    super.dispose();
  }
}
