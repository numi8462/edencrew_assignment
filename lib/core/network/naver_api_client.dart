import 'dart:convert';
import 'dart:typed_data';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:http/http.dart' as http;

class NaverApiException implements Exception {
  NaverApiException(this.message);

  final String message;

  @override
  String toString() => 'NaverApiException: $message';
}

/// Naver 4개 endpoint 공통 호출부. 타임아웃과 상태코드 검사를 한 곳에 모아둡니다.
///
/// 응답 charset이 항상 UTF-8인 건 아닙니다. (실시간 시세 endpoint는 JSON처럼 보이지만
/// `Content-Type: text/plain;charset=EUC-KR`로 내려옵니다.) 그래서 `getJson`은 항상
/// UTF-8로 디코딩하지 않고, 응답 헤더의 charset을 보고 필요하면 EUC-KR(CP949)로
/// 디코딩합니다.
class NaverApiClient {
  NaverApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  static const Map<String, String> _defaultHeaders = <String, String>{
    'User-Agent': 'Mozilla/5.0 (compatible; EdencrewAssignment/1.0)',
  };

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    final http.Response response = await _get(uri);
    return jsonDecode(_decodeText(response)) as Map<String, dynamic>;
  }

  Future<Uint8List> getBytes(Uri uri, {Map<String, String>? headers}) async {
    final http.Response response = await _get(uri, headers: headers);
    return response.bodyBytes;
  }

  Future<http.Response> _get(Uri uri, {Map<String, String>? headers}) async {
    final http.Response response = await _client
        .get(uri, headers: <String, String>{..._defaultHeaders, ...?headers})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw NaverApiException('GET $uri failed with ${response.statusCode}');
    }
    return response;
  }

  String _decodeText(http.Response response) {
    final String contentType = response.headers['content-type']?.toLowerCase() ?? '';
    if (contentType.contains('euc-kr')) {
      return cp949.decode(response.bodyBytes);
    }
    return utf8.decode(response.bodyBytes);
  }

  void close() => _client.close();
}
