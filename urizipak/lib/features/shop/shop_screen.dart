import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../../core/money.dart';
import '../../domain/models/item.dart';
import 'shop_view_model.dart';

/// 상점 화면. AppMoney로 우리 공간을 꾸밀 아이템을 산다.
///
/// 목표를 이루고 받은 코인이 다시 우리 공간의 성장으로 이어지는 순환의 끝점.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ShopViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) return;
    final services = AppServicesScope.of(context);
    _viewModel = ShopViewModel(
      shop: services.shop,
      inventory: services.inventory,
      appMoney: services.appMoney,
    );
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  Future<void> _buy(ItemModel item) async {
    final result = await _viewModel!.purchase(item);
    if (!mounted) return;
    final message = switch (result) {
      PurchaseResult.success =>
        '${item.emoji} ${item.name} 구매 완료! 우리 공간에 배치해 보세요',
      PurchaseResult.alreadyOwned => '이미 가지고 있는 아이템이에요',
      PurchaseResult.notEnoughMoney => '코인이 부족해요. 기록하고 저축하면 코인이 모여요 🪙',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel!;
    return Scaffold(
      appBar: AppBar(title: const Text('상점')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final grouped = viewModel.catalogByCategory;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Card(
                child: ListTile(
                  leading: const Text('🪙', style: TextStyle(fontSize: 28)),
                  title: const Text('보유 코인'),
                  trailing: Text(
                    formatComma(viewModel.balance),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              for (final entry in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                  child: Text(
                    entry.key.label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                for (final item in entry.value)
                  _ShopItemTile(
                    item: item,
                    owned: viewModel.owns(item.id),
                    affordable: viewModel.canAfford(item),
                    onBuy: () => _buy(item),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ShopItemTile extends StatelessWidget {
  const _ShopItemTile({
    required this.item,
    required this.owned,
    required this.affordable,
    required this.onBuy,
  });

  final ItemModel item;
  final bool owned;
  final bool affordable;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(item.emoji, style: const TextStyle(fontSize: 28)),
        title: Row(
          children: [
            Flexible(child: Text(item.name)),
            if (item.rarity != ItemRarity.common) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.rarity.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: item.description.isNotEmpty ? Text(item.description) : null,
        trailing: owned
            ? const Chip(
                label: Text('보유중'),
                visualDensity: VisualDensity.compact,
              )
            : FilledButton.tonal(
                onPressed: onBuy,
                style: affordable
                    ? null
                    : FilledButton.styleFrom(
                        foregroundColor: theme.colorScheme.outline,
                      ),
                child: Text('🪙 ${formatComma(item.price)}'),
              ),
      ),
    );
  }
}
