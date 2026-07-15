/// 공동 목표(저축 목표) 모델.
library;

import 'transaction_entry.dart' show RecordedBy;

class SavingGoal {
  const SavingGoal({
    required this.id,
    required this.title,
    required this.emoji,
    required this.targetAmount,
    this.savedAmount = 0,
    this.deadline,
    required this.createdAt,
    this.achievedAt,
  });

  final String id;
  final String title;
  final String emoji;

  /// 목표 금액(원).
  final int targetAmount;

  /// 지금까지 모은 금액(원). 불입 기록의 합계와 항상 일치해야 한다.
  final int savedAmount;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime? achievedAt;

  bool get isAchieved => achievedAt != null;

  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  int get remainingAmount =>
      (targetAmount - savedAmount) < 0 ? 0 : targetAmount - savedAmount;

  SavingGoal copyWith({
    String? title,
    String? emoji,
    int? targetAmount,
    int? savedAmount,
    DateTime? deadline,
    DateTime? achievedAt,
  }) {
    return SavingGoal(
      id: id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'emoji': emoji,
    'targetAmount': targetAmount,
    'savedAmount': savedAmount,
    'deadline': deadline?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'achievedAt': achievedAt?.toIso8601String(),
  };

  factory SavingGoal.fromJson(Map<String, dynamic> json) {
    return SavingGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String? ?? '🎯',
      targetAmount: json['targetAmount'] as int,
      savedAmount: json['savedAmount'] as int? ?? 0,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      achievedAt: json['achievedAt'] != null
          ? DateTime.parse(json['achievedAt'] as String)
          : null,
    );
  }
}

/// 목표에 대한 저축(불입) 기록 한 건.
class GoalContribution {
  const GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    required this.contributedBy,
    this.memo = '',
  });

  final String id;
  final String goalId;
  final int amount;
  final DateTime date;
  final RecordedBy contributedBy;
  final String memo;

  Map<String, dynamic> toJson() => {
    'id': id,
    'goalId': goalId,
    'amount': amount,
    'date': date.toIso8601String(),
    'contributedBy': contributedBy.name,
    'memo': memo,
  };

  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    return GoalContribution(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      amount: json['amount'] as int,
      date: DateTime.parse(json['date'] as String),
      contributedBy: RecordedBy.values.byName(json['contributedBy'] as String),
      memo: json['memo'] as String? ?? '',
    );
  }
}
