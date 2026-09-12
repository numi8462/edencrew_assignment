import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_icon.dart';
import '../../data/models/watchlist_sort.dart';
import '../../data/stock_repository.dart';
import '../../app/favorites_controller.dart';
import '../../theme/theme.dart';
import '../detail/detail_screen.dart';
import 'watchlist_controller.dart';
import 'widgets/sort_bottom_sheet.dart';
import 'widgets/watchlist_empty_state.dart';
import 'widgets/watchlist_row.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WatchlistController>(
      create: (BuildContext context) => WatchlistController(
        repository: context.read<StockRepository>(),
        favorites: context.read<FavoritesController>(),
      ),
      child: const _WatchlistView(),
    );
  }
}

class _WatchlistView extends StatelessWidget {
  const _WatchlistView();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final WatchlistController controller = context.watch<WatchlistController>();

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _Header(controller: controller),
            if (controller.errorMessage != null) _ErrorBanner(message: controller.errorMessage!),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                child: _Body(controller: controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final WatchlistController controller;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      padding: EdgeInsets.fromLTRB(dimens.space4, dimens.space3, dimens.space4, dimens.space3),
      decoration: BoxDecoration(
        color: colors.surfaceBase,
        border: Border(bottom: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline)),
      ),
      child: Row(
        children: <Widget>[
          Text(
            '관심',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 20,
              fontWeight: AppTypography.bold,
            ),
          ),
          const Spacer(),
          _SortChip(controller: controller),
          SizedBox(width: dimens.space2),
          IconButton(
            onPressed: controller.isLoading ? null : controller.refresh,
            icon: AppIcon(AppIcons.refresh, color: colors.textSecondary, size: dimens.iconMd),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.controller});

  final WatchlistController controller;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return InkWell(
      borderRadius: BorderRadius.circular(dimens.radiusMd),
      onTap: () async {
        final WatchlistSort? selected = await SortBottomSheet.show(context, controller.sort);
        if (selected != null) controller.changeSort(selected);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dimens.space2, vertical: dimens.space1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              controller.sort.label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: AppTypography.regular,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: colors.textSecondary, size: dimens.iconSm),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      width: double.infinity,
      color: colors.priceDownBg,
      padding: EdgeInsets.symmetric(horizontal: dimens.space4, vertical: dimens.space2),
      child: Text(
        message,
        style: TextStyle(color: colors.priceDownText, fontSize: 12, fontWeight: AppTypography.regular),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller});

  final WatchlistController controller;

  @override
  Widget build(BuildContext context) {
    final List<WatchlistItem> items = controller.items;
    if (items.isEmpty) {
      // 빈 상태에서도 아래로 당겨 새로고침할 수 있도록 스크롤 가능한 리스트로 감쌉니다.
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const WatchlistEmptyState(),
            ),
          ],
        ),
      );
    }

    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: dimens.space4),
      itemCount: items.length,
      separatorBuilder: (_, _) => Divider(
        height: dimens.borderHairline,
        thickness: dimens.borderHairline,
        color: colors.borderSubtle,
        indent: dimens.space4,
        endIndent: dimens.space4,
      ),
      itemBuilder: (BuildContext context, int index) {
        final WatchlistItem item = items[index];
        return WatchlistRow(
          item: item,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => DetailScreen(summary: item.summary)),
          ),
        );
      },
    );
  }
}
