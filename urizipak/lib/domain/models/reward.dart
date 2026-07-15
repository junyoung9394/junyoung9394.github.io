/// 보상 정책 모델.
///
/// 어떤 행동이 얼마의 AppMoney를 주는지는 전부 여기에서만 정의한다.
/// 새 보상을 추가할 때는 [RewardEvent] 케이스만 추가하면 된다.
library;

enum RewardFrequency {
  /// 계정 생애 1회만 지급.
  once,

  /// 하루 1회 지급.
  daily,

  /// 발생할 때마다 지급.
  everyTime,
}

enum RewardEvent {
  firstTransaction('첫 거래 기록', '🎉', 500, RewardFrequency.once),
  firstGoal('첫 목표 등록', '🌱', 500, RewardFrequency.once),
  savingSuccess('목표 저축 성공', '🐷', 100, RewardFrequency.everyTime),
  goalAchieved('목표 달성', '🏆', 1000, RewardFrequency.everyTime),
  dailyCheckIn('오늘의 출석', '📅', 50, RewardFrequency.daily),
  recordStreak7('7일 연속 기록', '🔥', 300, RewardFrequency.everyTime),
  budgetKept('이번 달 예산 지키기', '🛡️', 500, RewardFrequency.everyTime);

  const RewardEvent(this.label, this.emoji, this.amount, this.frequency);

  final String label;
  final String emoji;

  /// 지급 AppMoney.
  final int amount;
  final RewardFrequency frequency;
}
