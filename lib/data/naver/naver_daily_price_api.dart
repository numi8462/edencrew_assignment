import 'package:cp949_codec/cp949_codec.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../../core/network/naver_api_client.dart';
import '../models/daily_price.dart';

class _DailyPage {
  const _DailyPage(this.prices, this.lastPage);

  final List<DailyPrice> prices;
  final int lastPage;
}

/// endpoint 4. 일별 시세 HTML.
///
/// 한 페이지에 10거래일이 들어 있어서, 기간 탭이 필요로 하는 거래일 수만큼 페이지를 이어서
/// 받습니다. 이미 받은 페이지는 심볼별로 캐싱해 재사용하고, `lastPage`보다 큰 페이지는
/// 요청하지 않습니다.
class NaverDailyPriceApi {
  NaverDailyPriceApi(this._client);

  final NaverApiClient _client;

  final Map<String, Map<int, List<DailyPrice>>> _pageCache = <String, Map<int, List<DailyPrice>>>{};
  final Map<String, int> _lastPageCache = <String, int>{};

  static const Map<String, String> _pageHeaders = <String, String>{
    'Referer': 'https://finance.naver.com',
  };

  /// 최근 거래일 기준으로 최소 [minTradingDays]개를 채울 때까지 페이지를 이어받습니다.
  /// 최신 날짜가 먼저 오도록 정렬해서 반환합니다.
  Future<List<DailyPrice>> fetchRecent(String symbol, int minTradingDays) async {
    final Map<int, List<DailyPrice>> pages =
        _pageCache.putIfAbsent(symbol, () => <int, List<DailyPrice>>{});

    final List<DailyPrice> collected = <DailyPrice>[];
    int page = 1;
    while (collected.length < minTradingDays) {
      final int? knownLastPage = _lastPageCache[symbol];
      if (knownLastPage != null && page > knownLastPage) break;

      List<DailyPrice>? cached = pages[page];
      if (cached == null) {
        final _DailyPage fetched = await _fetchPage(symbol, page);
        cached = fetched.prices;
        pages[page] = cached;
        _lastPageCache[symbol] = fetched.lastPage;
        if (page > fetched.lastPage) break;
      }
      collected.addAll(cached);
      page++;
    }

    collected.sort((DailyPrice a, DailyPrice b) => b.date.compareTo(a.date));
    return collected.length > minTradingDays
        ? collected.sublist(0, minTradingDays)
        : collected;
  }

  Future<_DailyPage> _fetchPage(String symbol, int page) async {
    final Uri uri = Uri.https('finance.naver.com', '/item/sise_day.naver', <String, String>{
      'code': symbol,
      'page': '$page',
    });
    final bytes = await _client.getBytes(uri, headers: _pageHeaders);
    final String decoded = cp949.decode(bytes);
    return _parse(decoded);
  }

  _DailyPage _parse(String htmlText) {
    final Document document = html_parser.parse(htmlText);
    final List<Element> rows = document.querySelectorAll('table.type2 tr');

    final List<DailyPrice> prices = <DailyPrice>[];
    for (final Element row in rows) {
      final List<Element> cells = row.querySelectorAll('td');
      if (cells.length < 7) continue;

      final RegExpMatch? dateMatch =
          RegExp(r'^(\d{4})\.(\d{2})\.(\d{2})$').firstMatch(cells[0].text.trim());
      if (dateMatch == null) continue;

      final DateTime date = DateTime(
        int.parse(dateMatch.group(1)!),
        int.parse(dateMatch.group(2)!),
        int.parse(dateMatch.group(3)!),
      );

      final int close = _parseInt(cells[1].text);
      final Element changeCell = cells[2];
      final int changeMagnitude = _parseInt(changeCell.text);
      final String directionClass = changeCell.querySelector('em')?.className ?? '';
      final int changeAmount = directionClass.contains('bu_pup')
          ? changeMagnitude
          : directionClass.contains('bu_pdn')
              ? -changeMagnitude
              : 0;

      prices.add(
        DailyPrice(
          date: date,
          close: close,
          open: _parseInt(cells[3].text),
          high: _parseInt(cells[4].text),
          low: _parseInt(cells[5].text),
          volume: _parseInt(cells[6].text),
          changeAmount: changeAmount,
        ),
      );
    }

    int lastPage = 1;
    final String? lastPageHref = document.querySelector('td.pgRR a')?.attributes['href'];
    if (lastPageHref != null) {
      final RegExpMatch? match = RegExp(r'page=(\d+)').firstMatch(lastPageHref);
      if (match != null) lastPage = int.parse(match.group(1)!);
    }

    return _DailyPage(prices, lastPage);
  }

  int _parseInt(String text) {
    final String digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? 0 : int.parse(digits);
  }
}
