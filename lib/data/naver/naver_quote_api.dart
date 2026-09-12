import '../../core/network/naver_api_client.dart';
import '../models/quote.dart';

/// endpoint 2. 실시간 시세. 여러 종목을 한 번의 요청으로 조회합니다.
class NaverQuoteApi {
  NaverQuoteApi(this._client);

  final NaverApiClient _client;

  Future<Map<String, Quote>> fetchQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return <String, Quote>{};

    final Uri uri = Uri.https('polling.finance.naver.com', '/api/realtime', <String, String>{
      'query': 'SERVICE_ITEM:${symbols.join(',')}',
    });
    final Map<String, dynamic> json = await _client.getJson(uri);

    final List<dynamic> areas =
        (json['result']?['areas'] as List<dynamic>?) ?? const <dynamic>[];
    final List<dynamic> datas =
        areas.isNotEmpty ? (areas.first['datas'] as List<dynamic>? ?? const <dynamic>[]) : const <dynamic>[];

    final Map<String, Quote> result = <String, Quote>{};
    for (final dynamic raw in datas) {
      final Map<String, dynamic> d = raw as Map<String, dynamic>;
      final String symbol = d['cd'] as String;
      result[symbol] = Quote(
        symbol: symbol,
        currentPrice: (d['nv'] as num).toInt(),
        previousClose: (d['pcv'] as num).toInt(),
        open: (d['ov'] as num).toInt(),
        high: (d['hv'] as num).toInt(),
        low: (d['lv'] as num).toInt(),
        accumulatedVolume: (d['aq'] as num).toInt(),
        listedShares: (d['countOfListedStock'] as num).toInt(),
      );
    }
    return result;
  }
}
