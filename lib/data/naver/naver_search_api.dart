import '../../core/network/naver_api_client.dart';
import '../models/stock_summary.dart';

/// endpoint 1. 검색 자동완성.
class NaverSearchApi {
  NaverSearchApi(this._client);

  final NaverApiClient _client;

  static final RegExp _sixDigitCode = RegExp(r'^\d{6}$');

  Future<List<StockSummary>> search(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return const <StockSummary>[];

    final Uri uri = Uri.https('ac.stock.naver.com', '/ac', <String, String>{
      'q': trimmed,
      'target': 'stock,ipo,index,marketindicator',
    });
    final Map<String, dynamic> json = await _client.getJson(uri);
    final List<dynamic> items = (json['items'] as List<dynamic>?) ?? const <dynamic>[];

    final List<StockSummary> results = <StockSummary>[];
    for (final dynamic raw in items) {
      final Map<String, dynamic> item = raw as Map<String, dynamic>;
      if (item['nationCode'] != 'KOR' || item['category'] != 'stock') continue;
      final String code = item['code'] as String? ?? '';
      if (!_sixDigitCode.hasMatch(code)) continue;
      results.add(
        StockSummary(
          symbol: code,
          name: item['name'] as String? ?? code,
          marketLabel: item['typeName'] as String? ?? '',
        ),
      );
    }
    return results;
  }
}
