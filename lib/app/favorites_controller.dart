import 'package:flutter/foundation.dart';

import '../core/storage/favorites_storage.dart';
import '../data/models/stock_summary.dart';

/// 관심 등록 상태의 단일 진실 공급원(single source of truth).
///
/// 관심 / 검색 / 상세 세 화면 모두 이 컨트롤러 하나를 구독해서 별 아이콘 상태를
/// 동기화합니다. 심볼 집합만 들고 있고, 이름 · 시장 같은 부가 정보는
/// `StockRepository`의 메타데이터 캐시에서 가져옵니다.
///
/// [storage]를 주면 변경할 때마다 로컬에 저장해서 앱을 재실행해도 유지됩니다.
class FavoritesController extends ChangeNotifier {
  FavoritesController({Set<String> seedSymbols = const <String>{}, FavoritesStorage? storage})
      : _symbols = <String>{...seedSymbols},
        _storage = storage;

  final Set<String> _symbols;
  final FavoritesStorage? _storage;

  Set<String> get symbols => Set<String>.unmodifiable(_symbols);

  bool isFavorite(String symbol) => _symbols.contains(symbol);

  void add(String symbol) {
    if (_symbols.add(symbol)) {
      notifyListeners();
      _persist();
    }
  }

  void remove(String symbol) {
    if (_symbols.remove(symbol)) {
      notifyListeners();
      _persist();
    }
  }

  void _persist() => _storage?.saveSymbols(_symbols);

  /// 반환값은 등록 후 상태(true = 등록됨)입니다. 토스트 문구 분기에 사용합니다.
  bool toggle(StockSummary summary) {
    if (isFavorite(summary.symbol)) {
      remove(summary.symbol);
      return false;
    } else {
      add(summary.symbol);
      return true;
    }
  }
}
