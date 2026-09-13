import 'package:flutter/material.dart';

import '../../../core/format/price_format.dart';
import '../../../core/widgets/skeleton_bar.dart';
import '../../../data/models/quote.dart';
import '../../../data/models/stock_summary.dart';
import '../../../theme/theme.dart';
import '../watchlist_controller.dart';

class WatchlistRow extends StatelessWidget {
  const WatchlistRow({super.key, required this.item, required this.onTap});

  final WatchlistItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppDimens dimens = context.dimens;
    final Quote? quote = item.quote;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: dimens.rowMinHeight),
        padding: EdgeInsets.symmetric(horizontal: dimens.space4, vertical: dimens.space3),
        child: Row(
          children: <Widget>[
            Expanded(child: _NameColumn(summary: item.summary)),
            SizedBox(width: dimens.space3),
            quote == null
                ? const _PriceSkeleton()
                : _PriceColumn(quote: quote),
          ],
        ),
      ),
    );
  }
}

class _NameColumn extends StatelessWidget {
  const _NameColumn({required this.summary});

  final StockSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          summary.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 15,
            fontWeight: AppTypography.medium,
          ),
        ),
        SizedBox(height: dimens.space1),
        Text(
          '${summary.symbol} · ${summary.marketLabel}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.textTertiary,
            fontSize: 12,
            fontWeight: AppTypography.regular,
          ),
        ),
      ],
    );
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final Color changeColor = switch (quote.direction) {
      PriceDirection.up => colors.priceUpText,
      PriceDirection.down => colors.priceDownText,
      PriceDirection.flat => colors.priceFlatText,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          formatPrice(quote.currentPrice),
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 15,
            fontWeight: AppTypography.medium,
          ),
        ),
        SizedBox(height: dimens.space1),
        Text(
          formatChange(quote.changeAmount, quote.changeRate),
          style: TextStyle(
            color: changeColor,
            fontSize: 12,
            fontWeight: AppTypography.regular,
          ),
        ),
      ],
    );
  }
}

class _PriceSkeleton extends StatelessWidget {
  const _PriceSkeleton();

  @override
  Widget build(BuildContext context) {
    final AppDimens dimens = context.dimens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SkeletonBar(width: 64, height: 16),
        SizedBox(height: dimens.space1),
        const SkeletonBar(width: 88, height: 12),
      ],
    );
  }
}
