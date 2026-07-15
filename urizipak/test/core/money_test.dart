import 'package:flutter_test/flutter_test.dart';
import 'package:urizipak/core/money.dart';

void main() {
  group('formatComma', () {
    test('천 단위 콤마', () {
      expect(formatComma(0), '0');
      expect(formatComma(999), '999');
      expect(formatComma(1000), '1,000');
      expect(formatComma(1234567), '1,234,567');
    });

    test('음수', () {
      expect(formatComma(-1234567), '-1,234,567');
    });
  });

  test('formatWon / formatSignedWon', () {
    expect(formatWon(50000), '50,000원');
    expect(formatSignedWon(50000), '+50,000원');
    expect(formatSignedWon(-3000), '-3,000원');
  });
}
