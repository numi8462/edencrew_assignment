/// 일별 시세 표에서 쓰는 `MM.DD` 형태 날짜 포맷입니다.
String formatMonthDay(DateTime date) {
  final String mm = date.month.toString().padLeft(2, '0');
  final String dd = date.day.toString().padLeft(2, '0');
  return '$mm.$dd';
}
