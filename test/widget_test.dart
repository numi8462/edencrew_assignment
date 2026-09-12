import 'package:edencrew_assignment_starter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('앱이 다크 테마로 구동되고 하단 탭이 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(const EdencrewAssignmentApp());
    await tester.pump();

    expect(find.text('관심'), findsWidgets);
    expect(find.text('검색'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
  });
}
