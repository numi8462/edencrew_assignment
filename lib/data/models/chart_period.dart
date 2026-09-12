/// 종목상세 화면의 기간 탭.
enum ChartPeriod { oneMonth, threeMonths, sixMonths, oneYear }

extension ChartPeriodX on ChartPeriod {
  String get label => switch (this) {
        ChartPeriod.oneMonth => '1개월',
        ChartPeriod.threeMonths => '3개월',
        ChartPeriod.sixMonths => '6개월',
        ChartPeriod.oneYear => '1년',
      };

  /// `docs/NAVER_API.md`의 대략적인 거래일 수 표를 그대로 옮긴 값입니다.
  int get approxTradingDays => switch (this) {
        ChartPeriod.oneMonth => 20,
        ChartPeriod.threeMonths => 60,
        ChartPeriod.sixMonths => 120,
        ChartPeriod.oneYear => 245,
      };
}
