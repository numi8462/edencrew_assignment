import 'package:shared_preferences/shared_preferences.dart';

/// 관심 종목 심볼 목록을 로컬에 저장/복원합니다. 앱을 재실행해도 관심 목록이
/// 유지되도록 하기 위한 것으로, 과제 문서의 "관심 목록을 앱 재실행 후에도
/// 유지하는 것" 선택 항목입니다.
class FavoritesStorage {
  FavoritesStorage(this._prefs);

  static const String _key = 'favorites_symbols_v1';

  final SharedPreferences _prefs;

  /// 저장된 적이 없으면(첫 실행) `null`을 돌려줍니다. 이 경우 호출부가 기본
  /// 시드 종목을 쓸지 결정합니다.
  Set<String>? loadSymbols() {
    return _prefs.getStringList(_key)?.toSet();
  }

  Future<void> saveSymbols(Set<String> symbols) {
    return _prefs.setStringList(_key, symbols.toList());
  }
}
