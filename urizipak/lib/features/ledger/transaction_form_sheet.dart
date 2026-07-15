import 'package:flutter/material.dart';

import '../../domain/models/transaction_entry.dart';
import 'ledger_view_model.dart';

/// 거래 입력 바텀시트.
///
/// [광고 정책] 이 흐름(거래 입력)에는 어떤 광고도 노출하지 않는다.
Future<void> showTransactionFormSheet(
  BuildContext context,
  LedgerViewModel viewModel,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _TransactionForm(viewModel: viewModel),
    ),
  );
}

class _TransactionForm extends StatefulWidget {
  const _TransactionForm({required this.viewModel});

  final LedgerViewModel viewModel;

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.food;
  RecordedBy _recordedBy = RecordedBy.partnerA;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = int.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('금액을 확인해 주세요')));
      return;
    }
    setState(() => _saving = true);
    await widget.viewModel.add(
      type: _type,
      amount: amount,
      category: _category,
      date: _date,
      recordedBy: _recordedBy,
      memo: _memoController.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = TransactionCategory.forType(_type);
    if (!categories.contains(_category)) _category = categories.first;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('거래 입력', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SegmentedButton<TransactionType>(
              segments: [
                for (final type in TransactionType.values)
                  ButtonSegment(value: type, label: Text(type.label)),
              ],
              selected: {_type},
              onSelectionChanged: (selection) =>
                  setState(() => _type = selection.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '금액',
                suffixText: '원',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in categories)
                  ChoiceChip(
                    label: Text('${category.emoji} ${category.label}'),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<RecordedBy>(
                    segments: [
                      for (final by in RecordedBy.values)
                        ButtonSegment(value: by, label: Text(by.label)),
                    ],
                    selected: {_recordedBy},
                    onSelectionChanged: (selection) =>
                        setState(() => _recordedBy = selection.first),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text('${_date.month}/${_date.day}'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(labelText: '메모 (선택)'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                child: const Text('기록하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
