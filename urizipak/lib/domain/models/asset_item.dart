/// 자산 관리 모델. 현금 / 예금 / 적금 / 주식 / ETF / 부채.
library;

enum AssetType {
  cash('현금', '💵', isDebt: false),
  deposit('예금', '🏦', isDebt: false),
  savings('적금', '🐷', isDebt: false),
  stock('주식', '📈', isDebt: false),
  etf('ETF', '📊', isDebt: false),
  debt('부채', '📉', isDebt: true);

  const AssetType(this.label, this.emoji, {required this.isDebt});

  final String label;
  final String emoji;
  final bool isDebt;
}

class AssetItem {
  const AssetItem({
    required this.id,
    required this.type,
    required this.name,
    required this.amount,
    this.memo = '',
    this.ticker,
    this.quantity,
    required this.updatedAt,
  });

  final String id;
  final AssetType type;
  final String name;

  /// 현재 평가액(원). MVP에서는 전 유형 수동 입력.
  /// 주식/ETF는 향후 시세 API 연동 시 [ticker]와 [quantity]로 자동 평가된다.
  final int amount;
  final String memo;

  /// 주식/ETF 종목 코드 (예: "005930"). API 연동 대비 필드.
  final String? ticker;

  /// 주식/ETF 보유 수량. API 연동 대비 필드.
  final double? quantity;
  final DateTime updatedAt;

  /// 순자산 계산 시 반영되는 부호 있는 금액. 부채는 음수.
  int get signedAmount => type.isDebt ? -amount : amount;

  AssetItem copyWith({
    AssetType? type,
    String? name,
    int? amount,
    String? memo,
    String? ticker,
    double? quantity,
    DateTime? updatedAt,
  }) {
    return AssetItem(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      ticker: ticker ?? this.ticker,
      quantity: quantity ?? this.quantity,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'amount': amount,
    'memo': memo,
    'ticker': ticker,
    'quantity': quantity,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory AssetItem.fromJson(Map<String, dynamic> json) {
    return AssetItem(
      id: json['id'] as String,
      type: AssetType.values.byName(json['type'] as String),
      name: json['name'] as String,
      amount: json['amount'] as int,
      memo: json['memo'] as String? ?? '',
      ticker: json['ticker'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// 자산 전체 요약(순자산). AssetService가 계산해서 내려준다.
class NetWorthSummary {
  const NetWorthSummary({
    required this.totalAssets,
    required this.totalDebt,
    required this.byType,
  });

  final int totalAssets;
  final int totalDebt;
  final Map<AssetType, int> byType;

  int get netWorth => totalAssets - totalDebt;
}
