import 'package:flutter/foundation.dart';

import '../../data/models/stock_summary.dart';
import '../../data/stock_repository.dart';

/// 검색 화면 상태. 응답이 늦게 도착해 이전 검색 결과가 최신 검색어를 덮어쓰지 않도록
/// 요청 순번으로 오래된 응답은 무시합니다.
class SearchQueryController extends ChangeNotifier {
  SearchQueryController({required StockRepository repository}) : _repository = repository;

  final StockRepository _repository;

  String _query = '';
  List<StockSummary> _results = <StockSummary>[];
  bool _loading = false;
  String? _errorMessage;
  int _requestId = 0;

  String get query => _query;
  List<StockSummary> get results => _results;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> setQuery(String value) async {
    _query = value;
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      _results = <StockSummary>[];
      _errorMessage = null;
      _loading = false;
      notifyListeners();
      return;
    }

    final int requestId = ++_requestId;
    _loading = true;
    notifyListeners();
    try {
      final List<StockSummary> results = await _repository.search(trimmed);
      if (requestId != _requestId) return;
      _results = results;
      _errorMessage = null;
    } catch (_) {
      if (requestId != _requestId) return;
      _errorMessage = '검색 결과를 불러오지 못했습니다.';
    } finally {
      if (requestId == _requestId) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  void clear() => setQuery('');
}
