import 'models/daily_price.dart';
import 'models/quote.dart';
import 'models/stock_summary.dart';
import 'naver/naver_daily_price_api.dart';
import 'naver/naver_meta_api.dart';
import 'naver/naver_quote_api.dart';
import 'naver/naver_search_api.dart';

/// 4개 Naver endpoint를 화면이 쓰기 좋은 형태로 감싸는 파사드.
///
/// 종목 메타데이터는 심볼별로 캐싱해 재사용합니다. 검색 결과는 이미 이름 · 시장 정보를
/// 담고 있으므로 [cacheMeta]로 함께 채워 넣어 중복 요청을 줄입니다.
class StockRepository {
  StockRepository({
    required NaverSearchApi searchApi,
    required NaverQuoteApi quoteApi,
    required NaverMetaApi metaApi,
    required NaverDailyPriceApi dailyPriceApi,
  })  : _searchApi = searchApi,
        _quoteApi = quoteApi,
        _metaApi = metaApi,
        _dailyPriceApi = dailyPriceApi;

  final NaverSearchApi _searchApi;
  final NaverQuoteApi _quoteApi;
  final NaverMetaApi _metaApi;
  final NaverDailyPriceApi _dailyPriceApi;

  final Map<String, StockSummary> _metaCache = <String, StockSummary>{};

  Future<List<StockSummary>> search(String query) async {
    final List<StockSummary> results = await _searchApi.search(query);
    for (final StockSummary summary in results) {
      cacheMeta(summary);
    }
    return results;
  }

  void cacheMeta(StockSummary summary) => _metaCache[summary.symbol] = summary;

  StockSummary? cachedMeta(String symbol) => _metaCache[symbol];

  Future<StockSummary> meta(String symbol) async {
    final StockSummary? cached = _metaCache[symbol];
    if (cached != null) return cached;
    final StockSummary fetched = await _metaApi.fetchMeta(symbol);
    _metaCache[symbol] = fetched;
    return fetched;
  }

  Future<Map<String, Quote>> quotes(List<String> symbols) => _quoteApi.fetchQuotes(symbols);

  Future<List<DailyPrice>> dailyPrices(String symbol, int minTradingDays) =>
      _dailyPriceApi.fetchRecent(symbol, minTradingDays);
}
