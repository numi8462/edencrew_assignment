import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_shell.dart';
import 'app/favorites_controller.dart';
import 'core/network/naver_api_client.dart';
import 'core/storage/favorites_storage.dart';
import 'data/naver/naver_daily_price_api.dart';
import 'data/naver/naver_meta_api.dart';
import 'data/naver/naver_quote_api.dart';
import 'data/naver/naver_search_api.dart';
import 'data/stock_repository.dart';
import 'theme/theme.dart';

/// 앱을 처음 열었을 때(로컬에 저장된 관심 목록이 없을 때) 빈 화면 대신 확인할
/// 데이터가 보이도록 심어둔 기본 관심종목. 삼성전자 / SK하이닉스 / NAVER. (README 메모 참고)
const Set<String> _seedFavorites = <String>{'005930', '000660', '035420'};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FavoritesStorage storage = FavoritesStorage(await SharedPreferences.getInstance());
  final Set<String> initialFavorites = storage.loadSymbols() ?? _seedFavorites;

  runApp(EdencrewAssignmentApp(storage: storage, initialFavorites: initialFavorites));
}

class EdencrewAssignmentApp extends StatelessWidget {
  const EdencrewAssignmentApp({
    super.key,
    required this.storage,
    this.initialFavorites = _seedFavorites,
  });

  final FavoritesStorage storage;
  final Set<String> initialFavorites;

  @override
  Widget build(BuildContext context) {
    final NaverApiClient apiClient = NaverApiClient();

    return MultiProvider(
      providers: [
        Provider<StockRepository>(
          create: (_) => StockRepository(
            searchApi: NaverSearchApi(apiClient),
            quoteApi: NaverQuoteApi(apiClient),
            metaApi: NaverMetaApi(apiClient),
            dailyPriceApi: NaverDailyPriceApi(apiClient),
          ),
        ),
        ChangeNotifierProvider<FavoritesController>(
          create: (_) => FavoritesController(seedSymbols: initialFavorites, storage: storage),
        ),
      ],
      child: MaterialApp(
        title: '이든크루 평가 과제',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const AppShell(),
      ),
    );
  }
}
