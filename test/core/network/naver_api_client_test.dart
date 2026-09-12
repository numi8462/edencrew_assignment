import 'dart:io';

import 'package:edencrew_assignment_starter/core/network/naver_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'EUC-KR charset으로 내려오는 JSON도 UTF-8로 강제 디코딩하지 않고 한글을 살린다',
    () async {
      // 실시간 시세 endpoint는 JSON처럼 보이지만 실제로는
      // `Content-Type: text/plain;charset=EUC-KR`로 응답합니다. 이 원본 바이트를 그대로
      // utf8.decode 하면 한글이 깨지면서 FormatException이 났던 회귀 버그를 검증합니다.
      final List<int> bytes =
          File('assets/mock/naver/realtime_quotes.txt').readAsBytesSync();
      final NaverApiClient client = NaverApiClient(
        httpClient: MockClient((http.Request request) async {
          return http.Response.bytes(
            bytes,
            200,
            headers: <String, String>{'content-type': 'text/plain;charset=EUC-KR'},
          );
        }),
      );

      final Map<String, dynamic> json = await client.getJson(Uri.parse('https://example.com'));
      final List<dynamic> datas =
          json['result']['areas'][0]['datas'] as List<dynamic>;
      final String firstName = (datas.first as Map<String, dynamic>)['nm'] as String;

      expect(firstName, isNot(contains('�')));
      expect(RegExp(r'^[가-힣]+$').hasMatch(firstName), isTrue);
    },
  );
}
