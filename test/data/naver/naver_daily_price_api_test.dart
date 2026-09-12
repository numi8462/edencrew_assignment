import 'dart:io';

import 'package:edencrew_assignment_starter/core/network/naver_api_client.dart';
import 'package:edencrew_assignment_starter/data/models/daily_price.dart';
import 'package:edencrew_assignment_starter/data/naver/naver_daily_price_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final List<int> pageBytes =
      File('assets/mock/naver/sise_day_005930_page1.html').readAsBytesSync();

  test('EUC-KR HTML을 깨지지 않게 디코딩하고 표를 파싱한다', () async {
    final NaverApiClient client = NaverApiClient(
      httpClient: MockClient((http.Request request) async => http.Response.bytes(pageBytes, 200)),
    );
    final NaverDailyPriceApi api = NaverDailyPriceApi(client);

    final List<DailyPrice> prices = await api.fetchRecent('005930', 10);

    expect(prices.length, 10);
    expect(prices.first.date.isAfter(prices.last.date), isTrue);
    for (final DailyPrice p in prices) {
      expect(p.close, greaterThan(0));
    }
  });

  test('이미 받은 페이지는 다시 요청하지 않고 캐시를 재사용한다', () async {
    int requestCount = 0;
    final NaverApiClient client = NaverApiClient(
      httpClient: MockClient((http.Request request) async {
        requestCount++;
        return http.Response.bytes(pageBytes, 200);
      }),
    );
    final NaverDailyPriceApi api = NaverDailyPriceApi(client);

    await api.fetchRecent('005930', 10);
    await api.fetchRecent('005930', 10);

    expect(requestCount, 1);
  });
}
