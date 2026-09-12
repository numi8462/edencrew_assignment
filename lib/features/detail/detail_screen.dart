import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/favorites_controller.dart';
import '../../core/format/price_format.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/stock_summary.dart';
import '../../data/stock_repository.dart';
import '../../theme/theme.dart';
import 'detail_controller.dart';
import 'widgets/candle_chart.dart';
import 'widgets/daily_price_table.dart';
import 'widgets/period_tabs.dart';
import 'widgets/summary_card.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.summary});

  final StockSummary summary;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DetailController>(
      create: (BuildContext context) => DetailController(
        repository: context.read<StockRepository>(),
        summary: summary,
      ),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final DetailController controller = context.watch<DetailController>();
    final FavoritesController favorites = context.watch<FavoritesController>();

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _Header(summary: controller.summary, favorites: favorites),
            if (controller.errorMessage != null) _ErrorBanner(message: controller.errorMessage!),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: _Body(controller: controller),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.summary, required this.favorites});

  final StockSummary summary;
  final FavoritesController favorites;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final bool isFavorite = favorites.isFavorite(summary.symbol);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: dimens.space2, vertical: dimens.space1),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline)),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  summary.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: AppTypography.bold,
                  ),
                ),
                Text(
                  '${summary.symbol} · ${summary.marketLabel}',
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 12,
                    fontWeight: AppTypography.regular,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => favorites.toggle(summary),
            icon: AppIcon(
              isFavorite ? AppIcons.starFill : AppIcons.star,
              color: isFavorite ? colors.favoriteActive : colors.favoriteInactive,
              size: dimens.iconMd,
            ),
          ),
        ],
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

  final DetailController controller;

  @override
  Widget build(BuildContext context) {
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimens.space4, vertical: dimens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PriceBlock(controller: controller),
          SizedBox(height: dimens.space5),
          PeriodTabs(selected: controller.period, onSelected: controller.changePeriod),
          SizedBox(height: dimens.space4),
          controller.isLoadingDaily
              ? const _ChartLoading()
              : CandleChart(prices: controller.dailyPrices),
          SizedBox(height: dimens.space5),
          if (controller.quote != null) SummaryCard(quote: controller.quote!),
          SizedBox(height: dimens.space5),
          Text(
            '일별 시세',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 15,
              fontWeight: AppTypography.bold,
            ),
          ),
          SizedBox(height: dimens.space2),
          DailyPriceTable(prices: controller.dailyPrices),
        ],
      ),
    );
  }
}

class _ChartLoading extends StatelessWidget {
  const _ChartLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.controller});

  final DetailController controller;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final quote = controller.quote;

    if (quote == null) {
      return const SizedBox(height: 64, child: Center(child: CircularProgressIndicator()));
    }

    final Color color = switch (quote.direction) {
      PriceDirection.up => colors.priceUpText,
      PriceDirection.down => colors.priceDownText,
      PriceDirection.flat => colors.priceFlatText,
    };
    final IconData arrow = switch (quote.direction) {
      PriceDirection.up => Icons.arrow_drop_up,
      PriceDirection.down => Icons.arrow_drop_down,
      PriceDirection.flat => Icons.remove,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          formatPrice(quote.currentPrice),
          style: TextStyle(color: colors.textPrimary, fontSize: 28, fontWeight: AppTypography.bold),
        ),
        SizedBox(height: dimens.space1),
        Row(
          children: <Widget>[
            Icon(arrow, color: color, size: dimens.iconMd),
            Text(
              formatChange(quote.changeAmount, quote.changeRate),
              style: TextStyle(color: color, fontSize: 14, fontWeight: AppTypography.medium),
            ),
          ],
        ),
      ],
    );
  }
}
