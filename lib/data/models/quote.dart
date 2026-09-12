import '../../core/format/price_format.dart';

/// 실시간 시세 endpoint 응답 하나를 옮긴 모델.
class Quote {
  const Quote({
    required this.symbol,
    required this.currentPrice,
    required this.previousClose,
    required this.open,
    required this.high,
    required this.low,
    required this.accumulatedVolume,
    required this.listedShares,
  });

  final String symbol;
  final int currentPrice;
  final int previousClose;
  final int open;
  final int high;
  final int low;
  final int accumulatedVolume;
  final int listedShares;

  /// 전일 대비 등락액. `nv - pcv`.
  int get changeAmount => currentPrice - previousClose;

  /// 전일 대비 등락률. `(nv - pcv) / pcv`.
  double get changeRate => previousClose == 0 ? 0 : changeAmount / previousClose;

  PriceDirection get direction => directionOf(changeAmount);

  /// 시가총액. `nv * countOfListedStock`.
  int get marketCap => currentPrice * listedShares;
}
