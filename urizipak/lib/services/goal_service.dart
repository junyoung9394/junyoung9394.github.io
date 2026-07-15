import 'package:flutter/foundation.dart';

import '../core/event_bus.dart';
import '../core/ids.dart';
import '../domain/models/saving_goal.dart';
import '../domain/models/transaction_entry.dart' show RecordedBy;
import '../domain/repositories/repositories.dart';

/// 공동 목표 서비스.
///
/// [목표 → 저축 → AppMoney → 우리 공간 성장] 파이프라인의 시작점.
/// 이 서비스는 이벤트를 발행할 뿐 보상/캐릭터를 직접 알지 못한다.
/// - 저축 기록 → [GoalContributionAdded] → RewardService가 저축 보상 지급
/// - 목표 달성 → [GoalAchieved] → RewardService가 달성 보상 지급
/// - 지급된 AppMoney → 상점 구매 → 우리 공간 성장
class GoalService extends ChangeNotifier {
  GoalService({required this._repository, required this._bus});

  final GoalRepository _repository;
  final AppEventBus _bus;

  List<SavingGoal> _goals = [];

  Future<void> init() async {
    _goals = await _repository.loadGoals();
    _sort();
    notifyListeners();
  }

  List<SavingGoal> get goals => List.unmodifiable(_goals);

  List<SavingGoal> get activeGoals =>
      _goals.where((g) => !g.isAchieved).toList();

  Future<SavingGoal> create({
    required String title,
    required String emoji,
    required int targetAmount,
    DateTime? deadline,
  }) async {
    final isFirst = _goals.isEmpty;
    final goal = SavingGoal(
      id: IdGenerator.next(),
      title: title,
      emoji: emoji,
      targetAmount: targetAmount,
      deadline: deadline,
      createdAt: DateTime.now(),
    );
    await _repository.saveGoal(goal);
    _goals.add(goal);
    _sort();
    notifyListeners();
    _bus.publish(GoalCreated(goalId: goal.id, isFirst: isFirst));
    return goal;
  }

  /// 목표에 저축을 기록한다. 목표 금액에 도달하면 달성 처리까지 수행한다.
  Future<SavingGoal> contribute({
    required String goalId,
    required int amount,
    required RecordedBy contributedBy,
    String memo = '',
  }) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index < 0) {
      throw ArgumentError.value(goalId, 'goalId', '존재하지 않는 목표');
    }

    final contribution = GoalContribution(
      id: IdGenerator.next(),
      goalId: goalId,
      amount: amount,
      date: DateTime.now(),
      contributedBy: contributedBy,
      memo: memo,
    );
    await _repository.saveContribution(contribution);

    var goal = _goals[index].copyWith(
      savedAmount: _goals[index].savedAmount + amount,
    );
    final justAchieved =
        !goal.isAchieved && goal.savedAmount >= goal.targetAmount;
    if (justAchieved) {
      goal = goal.copyWith(achievedAt: DateTime.now());
    }
    await _repository.saveGoal(goal);
    _goals[index] = goal;
    notifyListeners();

    _bus.publish(GoalContributionAdded(goalId: goalId, amount: amount));
    if (justAchieved) {
      _bus.publish(GoalAchieved(goalId: goalId));
    }
    return goal;
  }

  Future<List<GoalContribution>> contributionsOf(String goalId) =>
      _repository.loadContributions(goalId);

  Future<void> remove(String goalId) async {
    await _repository.deleteGoal(goalId);
    _goals.removeWhere((g) => g.id == goalId);
    notifyListeners();
  }

  void _sort() {
    _goals.sort((a, b) {
      if (a.isAchieved != b.isAchieved) return a.isAchieved ? 1 : -1;
      return b.createdAt.compareTo(a.createdAt);
    });
  }
}
