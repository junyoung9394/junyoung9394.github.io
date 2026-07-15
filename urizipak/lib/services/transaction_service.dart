import 'package:flutter/foundation.dart';

import '../core/event_bus.dart';
import '../core/ids.dart';
import '../domain/models/transaction_entry.dart';
import '../domain/repositories/repositories.dart';

/// 한 달치 가계부 요약.
class MonthlySummary {
  const MonthlySummary({
    required this.income,
    required this.expense,
    required this.expenseByCategory,
  });

  final int income;
  final int expense;
  final Map<TransactionCategory, int> expenseByCategory;

  int get net => income - expense;
}

/// 공동 가계부 서비스.
class TransactionService extends ChangeNotifier {
  TransactionService({required this._repository, required this._bus});

  final TransactionRepository _repository;
  final AppEventBus _bus;

  List<TransactionEntry> _entries = [];

  Future<void> init() async {
    _entries = await _repository.loadAll();
    _sort();
    notifyListeners();
  }

  /// 최신순 전체 거래.
  List<TransactionEntry> get entries => List.unmodifiable(_entries);

  List<TransactionEntry> entriesInMonth(int year, int month) => _entries
      .where((e) => e.date.year == year && e.date.month == month)
      .toList();

  Future<TransactionEntry> add({
    required TransactionType type,
    required int amount,
    required TransactionCategory category,
    required DateTime date,
    required RecordedBy recordedBy,
    String memo = '',
  }) async {
    final isFirst = _entries.isEmpty;
    final entry = TransactionEntry(
      id: IdGenerator.next(),
      type: type,
      amount: amount,
      category: category,
      date: date,
      recordedBy: recordedBy,
      memo: memo,
      createdAt: DateTime.now(),
    );
    await _repository.save(entry);
    _entries.add(entry);
    _sort();
    notifyListeners();
    _bus.publish(
      TransactionRecorded(transactionId: entry.id, isFirst: isFirst),
    );
    return entry;
  }

  Future<void> update(TransactionEntry entry) async {
    await _repository.save(entry);
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) _entries[index] = entry;
    _sort();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  MonthlySummary summaryOf(int year, int month) {
    var income = 0;
    var expense = 0;
    final byCategory = <TransactionCategory, int>{};
    for (final entry in entriesInMonth(year, month)) {
      if (entry.type == TransactionType.income) {
        income += entry.amount;
      } else {
        expense += entry.amount;
        byCategory[entry.category] =
            (byCategory[entry.category] ?? 0) + entry.amount;
      }
    }
    return MonthlySummary(
      income: income,
      expense: expense,
      expenseByCategory: byCategory,
    );
  }

  void _sort() {
    _entries.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
    });
  }
}
