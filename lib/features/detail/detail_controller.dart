import 'package:flutter/foundation.dart';

import '../../data/models/chart_period.dart';
import '../../data/models/daily_price.dart';
import '../../data/models/quote.dart';
import '../../data/models/stock_summary.dart';
import '../../data/stock_repository.dart';

/// 종목상세 화면 상태. 기간 탭을 바꿔도 `StockRepository` 쪽 페이지 캐시 덕분에
/// 이미 받은 구간은 다시 요청하지 않습니다.
class DetailController extends ChangeNotifier {
  DetailController({
    required StockRepository repository,
    required StockSummary summary,
  })  : _repository = repository,
        _summary = summary {
    _loadMeta();
    _loadQuote();
    _loadDaily();
  }

  final StockRepository _repository;
  StockSummary _summary;
  Quote? _quote;
  ChartPeriod _period = ChartPeriod.oneMonth;
  List<DailyPrice> _dailyPrices = <DailyPrice>[];
  bool _loadingDaily = false;
  String? _errorMessage;

  StockSummary get summary => _summary;
  Quote? get quote => _quote;
  ChartPeriod get period => _period;
  List<DailyPrice> get dailyPrices => _dailyPrices;
  bool get isLoadingDaily => _loadingDaily;
  String? get errorMessage => _errorMessage;

  Future<void> changePeriod(ChartPeriod period) async {
    if (_period == period) return;
    _period = period;
    notifyListeners();
    await _loadDaily();
  }

  Future<void> refresh() => Future.wait(<Future<void>>[_loadQuote(), _loadDaily()]);

  Future<void> _loadMeta() async {
    try {
      _summary = await _repository.meta(_summary.symbol);
      notifyListeners();
    } catch (_) {
      // 메타데이터는 검색 / 관심에서 넘어온 값으로도 화면 구성이 가능하므로 조용히 무시합니다.
    }
  }

  Future<void> _loadQuote() async {
    try {
      final Map<String, Quote> quotes = await _repository.quotes(<String>[_summary.symbol]);
      _quote = quotes[_summary.symbol];
      notifyListeners();
    } catch (_) {
      _errorMessage = '시세를 불러오지 못했습니다.';
      notifyListeners();
    }
  }

  Future<void> _loadDaily() async {
    _loadingDaily = true;
    notifyListeners();
    try {
      _dailyPrices = await _repository.dailyPrices(_summary.symbol, _period.approxTradingDays);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = '일별 시세를 불러오지 못했습니다.';
    } finally {
      _loadingDaily = false;
      notifyListeners();
    }
  }
}
