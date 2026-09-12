import '../../core/network/naver_api_client.dart';
import '../models/stock_summary.dart';

/// endpoint 3. 종목 메타데이터 (이름, 거래소명).
class NaverMetaApi {
  NaverMetaApi(this._client);

  final NaverApiClient _client;

  Future<StockSummary> fetchMeta(String symbol) async {
    final Uri uri = Uri.https(
      'stock.naver.com',
      '/api/securityFe/api/fchart/domestic/stock/$symbol',
    );
    final Map<String, dynamic> json = await _client.getJson(uri);
    return StockSummary(
      symbol: json['symbolCode'] as String? ?? symbol,
      name: json['stockName'] as String? ?? symbol,
      marketLabel: json['stockExchangeNameKor'] as String? ?? '',
    );
  }
}
