import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../../core/money.dart';
import '../../domain/models/transaction_entry.dart';
import 'ledger_view_model.dart';
import 'transaction_form_sheet.dart';

/// 공동 가계부 화면.
class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  LedgerViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= LedgerViewModel(
      transactions: AppServicesScope.of(context).transactions,
    );
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    return Scaffold(
      appBar: AppBar(title: const Text('공동 가계부')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTransactionFormSheet(context, viewModel),
        icon: const Icon(Icons.edit),
        label: const Text('기록'),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final grouped = viewModel.entriesByDay;
          final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
          final summary = viewModel.summary;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _MonthNavigator(viewModel: viewModel),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SummaryItem(label: '수입', amount: summary.income),
                      _SummaryItem(label: '지출', amount: -summary.expense),
                      _SummaryItem(label: '합계', amount: summary.net),
                    ],
                  ),
                ),
              ),
              if (days.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      '이번 달 기록이 아직 없어요.\n'
                      '첫 기록엔 보상 코인이 기다리고 있어요! 🪙',
                    ),
                  ),
                ),
              for (final day in days) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                  child: Text(
                    '${day.month}월 ${day.day}일',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                for (final entry in grouped[day]!)
                  _TransactionTile(entry: entry, viewModel: viewModel),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({required this.viewModel});

  final LedgerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: viewModel.previousMonth,
        ),
        Text(
          '${viewModel.year}년 ${viewModel.month}월',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: viewModel.nextMonth,
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(
          formatSignedWon(amount),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: amount >= 0 ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.entry, required this.viewModel});

  final TransactionEntry entry;
  final LedgerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = entry.type == TransactionType.expense;
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => viewModel.remove(entry.id),
      child: ListTile(
        leading: Text(
          entry.category.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(entry.memo.isNotEmpty ? entry.memo : entry.category.label),
        subtitle: Text('${entry.category.label} · ${entry.recordedBy.label}'),
        trailing: Text(
          formatSignedWon(entry.signedAmount),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: isExpense ? null : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
