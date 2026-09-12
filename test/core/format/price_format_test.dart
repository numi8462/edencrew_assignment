import 'package:edencrew_assignment_starter/core/format/price_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('등락액 부호로 방향을 판정한다', () {
    expect(directionOf(100), PriceDirection.up);
    expect(directionOf(-100), PriceDirection.down);
    expect(directionOf(0), PriceDirection.flat);
  });

  test('가격은 천 단위 쉼표만 붙인다', () {
    expect(formatPrice(259500), '259,500');
  });

  test('등락은 부호와 퍼센트를 함께 보여준다', () {
    expect(formatChange(-400, -0.0022), '-400 (-0.22%)');
    expect(formatChange(9500, 0.0353), '+9,500 (+3.53%)');
    expect(formatChange(0, 0), '0 (0.00%)');
  });
}
