import 'dart:io';

import 'package:edencrew_assignment_starter/core/network/naver_api_client.dart';
import 'package:edencrew_assignment_starter/data/naver/naver_search_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('국내 6자리 종목코드만 통과시키고 canonical id를 만든다', () async {
    final List<int> bytes = File('assets/mock/naver/search_samsung.json').readAsBytesSync();
    final NaverApiClient client = NaverApiClient(
      httpClient: MockClient((http.Request request) async => http.Response.bytes(bytes, 200)),
    );
    final NaverSearchApi api = NaverSearchApi(client);

    final results = await api.search('삼성전자');

    expect(results, isNotEmpty);
    expect(results.every((s) => RegExp(r'^\d{6}$').hasMatch(s.symbol)), isTrue);
    expect(results.first.symbol, '005930');
    expect(results.first.canonicalId, 'domestic:005930');
  });

  test('빈 검색어는 요청 없이 빈 목록을 돌려준다', () async {
    final NaverApiClient client = NaverApiClient(
      httpClient: MockClient((http.Request request) async => http.Response('fail', 500)),
    );
    final NaverSearchApi api = NaverSearchApi(client);

    expect(await api.search('   '), isEmpty);
  });
}
