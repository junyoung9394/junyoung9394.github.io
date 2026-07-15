import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../../core/money.dart';
import '../../domain/models/asset_item.dart';
import '../../services/asset_service.dart';

/// 자산 관리 화면. 현금/예금/적금/주식/ETF/부채와 순자산.
/// MVP는 수동 입력. 주식/ETF는 시세 API 연동 대비 필드(ticker/quantity) 지원.
class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assets = AppServicesScope.of(context).assets;
    return Scaffold(
      appBar: AppBar(title: const Text('우리 자산')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssetForm(context, assets),
        icon: const Icon(Icons.add),
        label: const Text('자산 추가'),
      ),
      body: ListenableBuilder(
        listenable: assets,
        builder: (context, _) {
          final summary = assets.summary;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _NetWorthCard(summary: summary),
              const SizedBox(height: 8),
              for (final type in AssetType.values)
                if (assets.itemsOfType(type).isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                    child: Text(
                      '${type.emoji} ${type.label}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  for (final item in assets.itemsOfType(type))
                    _AssetTile(item: item, service: assets),
                ],
              if (assets.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      '우리의 자산을 등록해 보세요.\n'
                      '모이는 순자산이 한눈에 보여요 📊',
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _showAssetForm(
  BuildContext context,
  AssetService assets, {
  AssetItem? existing,
}) {
  final nameController = TextEditingController(text: existing?.name);
  final amountController = TextEditingController(
    text: existing?.amount.toString(),
  );
  final tickerController = TextEditingController(text: existing?.ticker);
  var type = existing?.type ?? AssetType.cash;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final isMarket = type == AssetType.stock || type == AssetType.etf;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? '자산 추가' : '자산 수정',
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final assetType in AssetType.values)
                        ChoiceChip(
                          label: Text('${assetType.emoji} ${assetType.label}'),
                          selected: type == assetType,
                          onSelected: existing == null
                              ? (_) => setSheetState(() => type = assetType)
                              : null,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '이름 (예: 청년도약계좌)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: type.isDebt ? '남은 금액' : '평가액',
                      suffixText: '원',
                    ),
                  ),
                  if (isMarket) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: tickerController,
                      decoration: const InputDecoration(
                        labelText: '종목 코드 (선택, 예: 005930)',
                        helperText: '시세 API 연동 시 자동 평가에 사용돼요',
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final amount = int.tryParse(
                          amountController.text.replaceAll(',', ''),
                        );
                        if (name.isEmpty || amount == null || amount < 0) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(content: Text('이름과 금액을 확인해 주세요')),
                          );
                          return;
                        }
                        final ticker = tickerController.text.trim();
                        if (existing == null) {
                          await assets.add(
                            type: type,
                            name: name,
                            amount: amount,
                            ticker: ticker.isEmpty ? null : ticker,
                          );
                        } else {
                          await assets.update(
                            existing.copyWith(
                              name: name,
                              amount: amount,
                              ticker: ticker.isEmpty ? null : ticker,
                            ),
                          );
                        }
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      child: const Text('저장'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _NetWorthCard extends StatelessWidget {
  const _NetWorthCard({required this.summary});

  final NetWorthSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '우리의 순자산',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatWon(summary.netWorth),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '자산 ${formatWon(summary.totalAssets)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '부채 ${formatWon(summary.totalDebt)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  const _AssetTile({required this.item, required this.service});

  final AssetItem item;
  final AssetService service;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) => service.remove(item.id),
      child: ListTile(
        title: Text(item.name),
        subtitle: item.ticker != null ? Text(item.ticker!) : null,
        trailing: Text(
          '${item.type.isDebt ? '-' : ''}${formatWon(item.amount)}',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        onTap: () => _showAssetForm(context, service, existing: item),
      ),
    );
  }
}
