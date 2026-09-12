import 'package:intl/intl.dart';

/// 등락 방향. 국내 시장 관행에 따라 상승은 빨강, 하락은 파랑으로 표시합니다.
enum PriceDirection { up, down, flat }

PriceDirection directionOf(num changeAmount) {
  if (changeAmount > 0) return PriceDirection.up;
  if (changeAmount < 0) return PriceDirection.down;
  return PriceDirection.flat;
}

final NumberFormat _priceFormat = NumberFormat('#,###');
final NumberFormat _rateFormat = NumberFormat('0.00');

/// 현재가 등: 천 단위 구분 쉼표만 붙입니다. (예: `259,500`)
String formatPrice(num price) => _priceFormat.format(price);

/// 전일 대비 등락액과 등락률을 함께 표시합니다. (예: `-400 (-0.22%)`, `0 (0.00%)`)
String formatChange(num changeAmount, double changeRate) {
  final String sign = changeAmount > 0 ? '+' : (changeAmount < 0 ? '-' : '');
  final String amount = _priceFormat.format(changeAmount.abs());
  final String rate = _rateFormat.format(changeRate.abs() * 100);
  return '$sign$amount ($sign$rate%)';
}
