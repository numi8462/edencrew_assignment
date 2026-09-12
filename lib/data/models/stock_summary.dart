/// 종목의 기본 정보(이름 · 코드 · 시장). 검색 / 관심 / 상세 화면에서 공통으로 씁니다.
class StockSummary {
  const StockSummary({
    required this.symbol,
    required this.name,
    required this.marketLabel,
  });

  /// 6자리 종목코드. (예: `005930`)
  final String symbol;

  final String name;

  /// 시장 표기. (예: `코스피`, `코스닥`)
  final String marketLabel;

  /// 관심 상태 저장 등에 쓰는 canonical id. (`domestic:{symbol}`)
  String get canonicalId => 'domestic:$symbol';

  @override
  bool operator ==(Object other) =>
      other is StockSummary && other.symbol == symbol;

  @override
  int get hashCode => symbol.hashCode;
}
