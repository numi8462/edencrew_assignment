import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../data/models/stock_summary.dart';
import '../../../theme/theme.dart';
import 'highlighted_text.dart';

class SearchResultRow extends StatelessWidget {
  const SearchResultRow({
    super.key,
    required this.summary,
    required this.query,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final StockSummary summary;
  final String query;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: dimens.rowMinHeight),
        padding: EdgeInsets.symmetric(horizontal: dimens.space4, vertical: dimens.space3),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  HighlightedText(
                    text: summary.name,
                    query: query,
                    baseStyle: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                      fontWeight: AppTypography.medium,
                    ),
                    highlightStyle: TextStyle(
                      color: colors.searchHighlight,
                      fontSize: 15,
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                  SizedBox(height: dimens.space1),
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
              onPressed: onToggleFavorite,
              icon: AppIcon(
                isFavorite ? AppIcons.starFill : AppIcons.star,
                color: isFavorite ? colors.favoriteActive : colors.favoriteInactive,
                size: dimens.iconMd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
