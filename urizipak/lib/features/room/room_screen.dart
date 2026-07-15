import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../../core/money.dart';
import '../../domain/models/item.dart';
import '../../domain/models/room.dart';
import '../character/character_controller.dart';
import '../settings/settings_screen.dart';
import 'room_view_model.dart';
import 'widgets/room_view.dart';

/// 우리 공간 — 앱을 열면 가장 먼저 보이는 화면.
///
/// 숫자(가계부)보다 집과 캐릭터가 먼저다.
class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  RoomViewModel? _viewModel;
  CharacterController? _male;
  CharacterController? _female;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) return;
    final services = AppServicesScope.of(context);
    _viewModel = RoomViewModel(
      room: services.room,
      inventory: services.inventory,
      shop: services.shop,
    );
    _male = CharacterController(
      manager: services.characters,
      slot: services.characters.profiles.first.slot,
    );
    _female = CharacterController(
      manager: services.characters,
      slot: services.characters.profiles.last.slot,
    );
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    _male?.dispose();
    _female?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = AppServicesScope.of(context);
    final viewModel = _viewModel!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('우리 공간'),
        actions: [
          _AppMoneyPill(
            listenable: services.appMoney.listenable,
            balance: () => services.appMoney.balance,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          viewModel,
          services.transactions,
          services.goals,
          services.theme,
        ]),
        builder: (context, _) {
          final now = DateTime.now();
          final summary = services.transactions.summaryOf(now.year, now.month);
          final activeGoals = services.goals.activeGoals;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RoomView(
                viewModel: viewModel,
                maleController: _male!,
                femaleController: _female!,
                onSlotTap: (slot) => _openSlotSheet(slot),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${viewModel.room.season.label}의 우리 집',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryColumn(
                          label: '${now.month}월 수입',
                          value: formatWon(summary.income),
                        ),
                      ),
                      Expanded(
                        child: _SummaryColumn(
                          label: '${now.month}월 지출',
                          value: formatWon(summary.expense),
                        ),
                      ),
                      Expanded(
                        child: _SummaryColumn(
                          label: '남은 돈',
                          value: formatWon(summary.net),
                          emphasize: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (activeGoals.isNotEmpty) ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '우리의 다음 목표 ${activeGoals.first.emoji}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(activeGoals.first.title),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: activeGoals.first.progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatWon(activeGoals.first.savedAmount)} / '
                          '${formatWon(activeGoals.first.targetAmount)}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openSlotSheet(RoomSlot slot) async {
    final viewModel = _viewModel!;
    final owned = viewModel.ownedItemsFor(slot);
    final placed = viewModel.placedItem(slot);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${slot.label} 슬롯',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            if (owned.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '아직 이 자리에 놓을 아이템이 없어요.\n'
                  '목표를 이루고 코인을 모아 상점에서 만나요!',
                ),
              )
            else
              for (final ItemModel item in owned)
                ListTile(
                  leading: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(item.name),
                  trailing: placed?.id == item.id
                      ? const Icon(Icons.check_circle)
                      : null,
                  onTap: () {
                    viewModel.place(slot, item);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            if (placed != null)
              ListTile(
                leading: const Icon(Icons.remove_circle_outline),
                title: const Text('비우기'),
                onTap: () {
                  viewModel.clear(slot);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _AppMoneyPill extends StatelessWidget {
  const _AppMoneyPill({required this.listenable, required this.balance});

  final Listenable listenable;
  final int Function() balance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) => Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '🪙 ${formatComma(balance())}',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: emphasize ? theme.colorScheme.primary : null,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
