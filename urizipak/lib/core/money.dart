/// 금액 관련 유틸리티.
///
/// 우리지갑의 모든 금액은 원(₩) 단위의 정수(int)로 다룬다.
/// 부동소수점 오차를 피하기 위해 double을 사용하지 않는다.
library;

/// 1234567 -> "1,234,567"
String formatComma(int amount) {
  final negative = amount < 0;
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return negative ? '-$buffer' : buffer.toString();
}

/// 1234567 -> "1,234,567원"
String formatWon(int amount) => '${formatComma(amount)}원';

/// "+1,234원" / "-1,234원" 처럼 부호를 강제 표기.
String formatSignedWon(int amount) =>
    amount >= 0 ? '+${formatWon(amount)}' : formatWon(amount);
