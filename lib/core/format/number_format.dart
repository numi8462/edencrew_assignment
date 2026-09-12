import 'package:intl/intl.dart';

final NumberFormat _integerFormat = NumberFormat('#,###');

/// 거래량 축약 표기. 천 단위로 나눠 보여줍니다. (예: `29,113천`)
String formatVolumeShort(int volume) {
  return '${_integerFormat.format(volume ~/ 1000)}천';
}

/// 시가총액 축약 표기. 조 단위로 나눠 보여줍니다. (예: `1,063조`)
String formatMarketCapShort(int marketCap) {
  return '${_integerFormat.format(marketCap ~/ 1000000000000)}조';
}
