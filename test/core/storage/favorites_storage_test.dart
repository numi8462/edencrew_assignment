import 'package:edencrew_assignment_starter/core/storage/favorites_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('저장된 적 없으면 null을 돌려준다', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final FavoritesStorage storage = FavoritesStorage(await SharedPreferences.getInstance());

    expect(storage.loadSymbols(), isNull);
  });

  test('저장한 심볼 목록을 그대로 복원한다', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final FavoritesStorage storage = FavoritesStorage(await SharedPreferences.getInstance());

    await storage.saveSymbols(<String>{'005930', '000660'});

    expect(storage.loadSymbols(), <String>{'005930', '000660'});
  });
}
