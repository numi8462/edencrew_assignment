import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/favorites_controller.dart';
import '../../core/widgets/app_toast.dart';
import '../../data/models/stock_summary.dart';
import '../../data/stock_repository.dart';
import '../../theme/theme.dart';
import '../detail/detail_screen.dart';
import 'search_controller.dart';
import 'widgets/search_empty_state.dart';
import 'widgets/search_field.dart';
import 'widgets/search_result_row.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchQueryController>(
      create: (BuildContext context) => SearchQueryController(
        repository: context.read<StockRepository>(),
      ),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final SearchQueryController controller = context.watch<SearchQueryController>();

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(dimens.space4, dimens.space3, dimens.space4, dimens.space3),
              child: SearchField(
                controller: _textController,
                onChanged: controller.setQuery,
                onClear: () {
                  _textController.clear();
                  controller.clear();
                },
              ),
            ),
            Expanded(child: _Results(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.controller});

  final SearchQueryController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.query.trim().isEmpty) {
      return const SearchEmptyState(mode: SearchEmptyMode.initial);
    }
    if (controller.results.isEmpty && !controller.isLoading) {
      return SearchEmptyState(mode: SearchEmptyMode.noResults, query: controller.query.trim());
    }

    final AppDimens dimens = context.dimens;
    final AppColors colors = context.colors;
    final FavoritesController favorites = context.watch<FavoritesController>();
    final StockRepository repository = context.read<StockRepository>();

    return ListView.separated(
      padding: EdgeInsets.only(bottom: dimens.space4),
      itemCount: controller.results.length,
      separatorBuilder: (_, _) => Divider(
        height: dimens.borderHairline,
        thickness: dimens.borderHairline,
        color: colors.borderSubtle,
        indent: dimens.space4,
        endIndent: dimens.space4,
      ),
      itemBuilder: (BuildContext context, int index) {
        final StockSummary summary = controller.results[index];
        return SearchResultRow(
          summary: summary,
          query: controller.query,
          isFavorite: favorites.isFavorite(summary.symbol),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => DetailScreen(summary: summary)),
          ),
          onToggleFavorite: () {
            repository.cacheMeta(summary);
            final bool nowFavorite = favorites.toggle(summary);
            AppToast.show(context, isFavorite: nowFavorite);
          },
        );
      },
    );
  }
}
