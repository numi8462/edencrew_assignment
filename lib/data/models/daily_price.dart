import '../../core/format/price_format.dart';

/// 일별 시세 HTML 한 행을 옮긴 모델. 상세 화면의 차트와 표에서 모두 사용합니다.
class DailyPrice {
  const DailyPrice({
    required this.date,
    required this.close,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
    required this.changeAmount,
  });

  /// `yyyyMMdd` 기준으로 정규화된 날짜.
  final DateTime date;
  final int close;
  final int open;
  final int high;
  final int low;
  final int volume;

  /// 전일 대비 등락액. Naver가 행마다 부호(상승/하락/보합)와 함께 제공하는 값을 그대로 부호화해 저장합니다.
  final int changeAmount;

  double get changeRate {
    final int previousClose = close - changeAmount;
    return previousClose == 0 ? 0 : changeAmount / previousClose;
  }

  PriceDirection get direction => directionOf(changeAmount);
}
