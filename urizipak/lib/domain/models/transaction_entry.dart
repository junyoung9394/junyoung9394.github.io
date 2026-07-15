/// 공동 가계부의 거래 한 건.
library;

enum TransactionType {
  expense('지출'),
  income('수입');

  const TransactionType(this.label);

  final String label;
}

enum TransactionCategory {
  food('식비', '🍚'),
  cafe('카페·간식', '☕'),
  transport('교통', '🚌'),
  housing('주거·관리비', '🏠'),
  shopping('쇼핑', '🛍️'),
  health('건강·의료', '💊'),
  leisure('여가·데이트', '🎡'),
  travel('여행', '✈️'),
  gift('선물·경조사', '🎁'),
  salary('급여', '💼'),
  allowance('용돈·보너스', '💌'),
  investment('투자수익', '📈'),
  etc('기타', '📎');

  const TransactionCategory(this.label, this.emoji);

  final String label;
  final String emoji;

  static List<TransactionCategory> forType(TransactionType type) {
    const incomeCategories = [
      TransactionCategory.salary,
      TransactionCategory.allowance,
      TransactionCategory.investment,
      TransactionCategory.etc,
    ];
    return type == TransactionType.income
        ? incomeCategories
        : values
              .where((c) => !incomeCategories.contains(c) || c == etc)
              .toList();
  }
}

/// 거래를 기록한 커플 구성원. 커플 연결(Firebase) 전에는 로컬 사용자 기준.
enum RecordedBy {
  partnerA('남자'),
  partnerB('여자');

  const RecordedBy(this.label);

  final String label;
}

class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.recordedBy,
    this.memo = '',
    required this.createdAt,
  });

  final String id;
  final TransactionType type;

  /// 원 단위 양수 금액. 부호는 [type]으로 판단한다.
  final int amount;
  final TransactionCategory category;
  final DateTime date;
  final RecordedBy recordedBy;
  final String memo;
  final DateTime createdAt;

  /// 지출은 음수, 수입은 양수로 환산한 금액.
  int get signedAmount => type == TransactionType.expense ? -amount : amount;

  TransactionEntry copyWith({
    TransactionType? type,
    int? amount,
    TransactionCategory? category,
    DateTime? date,
    RecordedBy? recordedBy,
    String? memo,
  }) {
    return TransactionEntry(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      recordedBy: recordedBy ?? this.recordedBy,
      memo: memo ?? this.memo,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'category': category.name,
    'date': date.toIso8601String(),
    'recordedBy': recordedBy.name,
    'memo': memo,
    'createdAt': createdAt.toIso8601String(),
  };

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    return TransactionEntry(
      id: json['id'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      amount: json['amount'] as int,
      category: TransactionCategory.values.byName(json['category'] as String),
      date: DateTime.parse(json['date'] as String),
      recordedBy: RecordedBy.values.byName(json['recordedBy'] as String),
      memo: json['memo'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
