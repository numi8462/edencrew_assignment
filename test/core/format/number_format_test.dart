import 'package:edencrew_assignment_starter/core/format/number_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('거래량은 천 단위로 축약한다', () {
    expect(formatVolumeShort(29113000), '29,113천');
  });

  test('시가총액은 조 단위로 축약한다', () {
    expect(formatMarketCapShort(1063000000000000), '1,063조');
  });
}
