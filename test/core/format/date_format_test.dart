import 'package:edencrew_assignment_starter/core/format/date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MM.DD 형태로 포맷한다', () {
    expect(formatMonthDay(DateTime(2026, 9, 11)), '09.11');
    expect(formatMonthDay(DateTime(2026, 1, 2)), '01.02');
  });
}
