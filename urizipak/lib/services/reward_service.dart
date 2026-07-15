import 'dart:async';

import '../core/event_bus.dart';
import '../domain/models/reward.dart';
import '../domain/repositories/repositories.dart';
import 'app_money_ledger.dart';

/// AppMoney 적립의 유일한 진입점.
///
/// 다른 모듈은 이 서비스를 직접 호출하지 않는다.
/// 각 모듈이 발행한 도메인 이벤트(거래 기록, 목표 생성, 저축, 달성)를
/// 이 서비스가 구독해서 보상 정책([RewardEvent])에 따라 지급한다.
/// 지급 결과는 [RewardGranted] 이벤트로 다시 발행되어
/// 캐릭터 반응(celebrate) 등으로 이어진다.
class RewardService {
  RewardService({
    required this._ledger,
    required this._settings,
    required this._bus,
  });

  final AppMoneyLedger _ledger;
  final SettingsRepository _settings;
  final AppEventBus _bus;

  final List<StreamSubscription<AppEvent>> _subscriptions = [];

  static const String _streakCountKey = 'reward.streak.count';
  static const String _streakDateKey = 'reward.streak.lastDate';

  /// 이벤트 구독을 시작한다. 조립 루트(di)에서 1회 호출.
  void start() {
    _subscriptions
      ..add(_bus.on<TransactionRecorded>().listen(_onTransactionRecorded))
      ..add(_bus.on<GoalCreated>().listen(_onGoalCreated))
      ..add(_bus.on<GoalContributionAdded>().listen(_onContributionAdded))
      ..add(_bus.on<GoalAchieved>().listen(_onGoalAchieved));
  }

  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  Future<void> _onTransactionRecorded(TransactionRecorded event) async {
    if (event.isFirst) await grant(RewardEvent.firstTransaction);
    await _updateRecordStreak();
  }

  Future<void> _onGoalCreated(GoalCreated event) async {
    if (event.isFirst) await grant(RewardEvent.firstGoal);
  }

  Future<void> _onContributionAdded(GoalContributionAdded event) =>
      grant(RewardEvent.savingSuccess);

  Future<void> _onGoalAchieved(GoalAchieved event) =>
      grant(RewardEvent.goalAchieved);

  /// 앱 실행 시 조립 루트에서 호출: 오늘의 출석 보상.
  Future<void> checkDailyAttendance() => grant(RewardEvent.dailyCheckIn);

  /// 보상 지급. 지급 빈도 정책을 검사한 뒤 원장에 적립하고 이벤트를 발행한다.
  ///
  /// 실제로 지급되었으면 true, 정책(1회성/일일 중복)에 걸려
  /// 지급되지 않았으면 false.
  Future<bool> grant(RewardEvent event) async {
    if (!await _isGrantable(event)) return false;
    await _markGranted(event);

    final label = '${event.label} ${event.emoji}';
    final entry = await _ledger.credit(amount: event.amount, reason: label);
    _bus.publish(
      RewardGranted(rewardId: entry.id, amount: event.amount, label: label),
    );
    return true;
  }

  Future<bool> _isGrantable(RewardEvent event) async {
    switch (event.frequency) {
      case RewardFrequency.once:
        return await _settings.getString(_onceKey(event)) == null;
      case RewardFrequency.daily:
        final last = await _settings.getString(_dailyKey(event));
        return last != _today();
      case RewardFrequency.everyTime:
        return true;
    }
  }

  Future<void> _markGranted(RewardEvent event) async {
    switch (event.frequency) {
      case RewardFrequency.once:
        await _settings.setString(_onceKey(event), _today());
      case RewardFrequency.daily:
        await _settings.setString(_dailyKey(event), _today());
      case RewardFrequency.everyTime:
        break;
    }
  }

  /// 연속 기록 스트릭. 7일을 채울 때마다 보상을 지급하고 다시 센다.
  Future<void> _updateRecordStreak() async {
    final today = _today();
    final lastDate = await _settings.getString(_streakDateKey);
    if (lastDate == today) return; // 오늘은 이미 반영됨

    final yesterday = _dateString(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final previous =
        int.tryParse(await _settings.getString(_streakCountKey) ?? '') ?? 0;
    final count = lastDate == yesterday ? previous + 1 : 1;

    await _settings.setString(_streakDateKey, today);
    if (count >= 7) {
      await _settings.setString(_streakCountKey, '0');
      await grant(RewardEvent.recordStreak7);
    } else {
      await _settings.setString(_streakCountKey, '$count');
    }
  }

  String _onceKey(RewardEvent event) => 'reward.once.${event.name}';

  String _dailyKey(RewardEvent event) => 'reward.daily.${event.name}';

  String _today() => _dateString(DateTime.now());

  String _dateString(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
