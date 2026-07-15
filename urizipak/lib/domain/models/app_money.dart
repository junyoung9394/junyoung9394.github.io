/// 앱 전용 재화(AppMoney) 원장 모델.
///
/// 잔액은 별도 필드로 저장하지 않고 원장(ledger) 합계로 계산한다.
/// 적립은 반드시 RewardService를 통해서만 이루어진다.
library;

enum AppMoneyEntryType {
  reward('보상 적립'),
  purchase('아이템 구매');

  const AppMoneyEntryType(this.label);

  final String label;
}

class AppMoneyEntry {
  const AppMoneyEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  final String id;
  final AppMoneyEntryType type;

  /// 부호 있는 금액. 적립은 양수, 사용은 음수.
  final int amount;

  /// 사용자에게 보여줄 사유 (예: "첫 거래 기록 🎉", "라탄 소파 구매").
  final String reason;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppMoneyEntry.fromJson(Map<String, dynamic> json) {
    return AppMoneyEntry(
      id: json['id'] as String,
      type: AppMoneyEntryType.values.byName(json['type'] as String),
      amount: json['amount'] as int,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
