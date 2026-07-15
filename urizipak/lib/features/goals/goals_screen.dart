import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../../core/money.dart';
import '../../domain/models/saving_goal.dart';
import '../../domain/models/transaction_entry.dart' show RecordedBy;
import '../../services/goal_service.dart';

/// 공동 목표 화면.
///
/// 목표 → 저축 → AppMoney 보상 → 우리 공간 성장으로 이어지는 출발점.
/// [광고 정책] 목표 등록 흐름에는 광고를 노출하지 않는다.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = AppServicesScope.of(context).goals;
    return Scaffold(
      appBar: AppBar(title: const Text('공동 목표')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGoalForm(context, goals),
        icon: const Icon(Icons.add),
        label: const Text('새 목표'),
      ),
      body: ListenableBuilder(
        listenable: goals,
        builder: (context, _) {
          if (goals.goals.isEmpty) {
            return const Center(
              child: Text(
                '함께 이루고 싶은 첫 목표를 세워보세요!\n'
                '제주 여행, 신혼집 보증금, 무엇이든 좋아요 🌱',
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final goal in goals.goals)
                _GoalCard(goal: goal, service: goals),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showGoalForm(BuildContext context, GoalService goals) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    var emoji = '🎯';
    const emojiChoices = ['🎯', '✈️', '🏠', '💍', '🚗', '👶', '🎓', '💻'];

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
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
                    '새 목표',
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final choice in emojiChoices)
                        ChoiceChip(
                          label: Text(choice),
                          selected: emoji == choice,
                          onSelected: (_) =>
                              setSheetState(() => emoji = choice),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: '목표 이름 (예: 제주 여행)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '목표 금액',
                      suffixText: '원',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final amount = int.tryParse(
                          amountController.text.replaceAll(',', ''),
                        );
                        if (title.isEmpty || amount == null || amount <= 0) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(content: Text('목표 이름과 금액을 확인해 주세요')),
                          );
                          return;
                        }
                        await goals.create(
                          title: title,
                          emoji: emoji,
                          targetAmount: amount,
                        );
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      child: const Text('목표 세우기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.service});

  final SavingGoal goal;
  final GoalService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(goal.title, style: theme.textTheme.titleMedium),
                ),
                if (goal.isAchieved)
                  const Chip(
                    label: Text('달성! 🏆'),
                    visualDensity: VisualDensity.compact,
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => service.remove(goal.id),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: goal.progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatWon(goal.savedAmount)} / ${formatWon(goal.targetAmount)}',
                  style: theme.textTheme.labelMedium,
                ),
                Text(
                  '${(goal.progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (!goal.isAchieved) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.savings_outlined, size: 18),
                  label: const Text('저축하기'),
                  onPressed: () => _showContributeSheet(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showContributeSheet(BuildContext context) {
    final amountController = TextEditingController();
    var contributedBy = RecordedBy.partnerA;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${goal.emoji} ${goal.title}에 저축',
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '남은 금액 ${formatWon(goal.remainingAmount)}',
                    style: Theme.of(sheetContext).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: '저축 금액',
                      suffixText: '원',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<RecordedBy>(
                    segments: [
                      for (final by in RecordedBy.values)
                        ButtonSegment(value: by, label: Text(by.label)),
                    ],
                    selected: {contributedBy},
                    onSelectionChanged: (selection) =>
                        setSheetState(() => contributedBy = selection.first),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final amount = int.tryParse(
                          amountController.text.replaceAll(',', ''),
                        );
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(content: Text('금액을 확인해 주세요')),
                          );
                          return;
                        }
                        await service.contribute(
                          goalId: goal.id,
                          amount: amount,
                          contributedBy: contributedBy,
                        );
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      child: const Text('저축 기록'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
