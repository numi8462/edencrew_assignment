import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../app/favorites_controller.dart';
import '../../data/models/quote.dart';
import '../../data/models/stock_summary.dart';
import '../../data/models/watchlist_sort.dart';
import '../../data/stock_repository.dart';

class WatchlistItem {
  const WatchlistItem({required this.summary, required this.quote});

  final StockSummary summary;

  /// 아직 시세를 못 받았으면 null. 행을 스켈레톤으로 그리는 신호로 씁니다.
  final Quote? quote;
}

/// 관심 화면의 상태. 관심 심볼 목록이 바뀌면(검색/상세에서 등록·해제) 자동으로 다시 로드합니다.
class WatchlistController extends ChangeNotifier {
  WatchlistController({
    required StockRepository repository,
    required FavoritesController favorites,
  })  : _repository = repository,
        _favorites = favorites {
    _favorites.addListener(_onFavoritesChanged);
    _loadAll();
  }

  final StockRepository _repository;
  final FavoritesController _favorites;

  final Map<String, StockSummary> _summaries = <String, StockSummary>{};
  final Map<String, Quote> _quotes = <String, Quote>{};

  bool _loading = false;
  String? _errorMessage;
  WatchlistSort _sort = WatchlistSort.priceDesc;

  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  WatchlistSort get sort => _sort;

  List<WatchlistItem> get items {
    final List<WatchlistItem> list = _favorites.symbols.map((String symbol) {
      final StockSummary summary = _summaries[symbol] ??
          StockSummary(symbol: symbol, name: symbol, marketLabel: '');
      return WatchlistItem(summary: summary, quote: _quotes[symbol]);
    }).toList();
    list.sort(_compare);
    return list;
  }

  int _compare(WatchlistItem a, WatchlistItem b) {
    switch (_sort) {
      case WatchlistSort.priceDesc:
        return _compareWithSkeletonLast(a, b, (WatchlistItem i) => i.quote!.currentPrice.toDouble());
      case WatchlistSort.changeRateDesc:
        return _compareWithSkeletonLast(a, b, (WatchlistItem i) => i.quote!.changeRate);
      case WatchlistSort.nameAsc:
        return a.summary.name.compareTo(b.summary.name);
    }
  }

  /// 시세를 아직 못 받은 행(스켈레톤)은 현재가순 / 등락률순 정렬에서 항상 맨 아래에 둡니다.
  /// Figma에 정의되지 않은 부분이라 직접 판단했습니다. (README 메모 참고)
  int _compareWithSkeletonLast(
    WatchlistItem a,
    WatchlistItem b,
    double Function(WatchlistItem) valueOf,
  ) {
    if (a.quote == null && b.quote == null) return 0;
    if (a.quote == null) return 1;
    if (b.quote == null) return -1;
    return valueOf(b).compareTo(valueOf(a));
  }

  void changeSort(WatchlistSort sort) {
    if (_sort == sort) return;
    _sort = sort;
    notifyListeners();
  }

  Future<void> refresh() => _loadAll();

  void _onFavoritesChanged() {
    unawaited(_loadAll());
  }

  Future<void> _loadAll() async {
    final List<String> symbols = _favorites.symbols.toList();
    if (symbols.isEmpty) {
      _quotes.clear();
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();
    try {
      // 두 Future를 함께 await해야 한쪽이 먼저 실패해도 다른 쪽이 처리되지 않은 채
      // 남는 예외(unhandled Future rejection)가 생기지 않습니다.
      await Future.wait(<Future<void>>[
        _loadMissingMeta(symbols),
        _loadQuotes(symbols),
      ]);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = '시세를 불러오지 못했습니다. 새로고침해 주세요.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMissingMeta(List<String> symbols) async {
    final Iterable<String> missing = symbols.where((String s) => !_summaries.containsKey(s));
    await Future.wait(missing.map((String symbol) async {
      final StockSummary summary = _repository.cachedMeta(symbol) ?? await _repository.meta(symbol);
      _summaries[symbol] = summary;
    }));
  }

  Future<void> _loadQuotes(List<String> symbols) async {
    final Map<String, Quote> fetched = await _repository.quotes(symbols);
    _quotes
      ..clear()
      ..addAll(fetched);
  }

  @override
  void dispose() {
    _favorites.removeListener(_onFavoritesChanged);
    super.dispose();
  }
}
