import 'package:flutter/material.dart';

import '../../../data/models/watchlist_sort.dart';
import '../../../theme/theme.dart';

/// 정렬 기준 선택 바텀시트.
class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({super.key, required this.current});

  final WatchlistSort current;

  static Future<WatchlistSort?> show(BuildContext context, WatchlistSort current) {
    return showModalBottomSheet<WatchlistSort>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SortBottomSheet(current: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(dimens.space4),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(dimens.radiusLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(dimens.space4, dimens.space4, dimens.space4, dimens.space2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '정렬 기준',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ),
            ),
            for (final WatchlistSort sort in WatchlistSort.values)
              _SortOptionTile(
                sort: sort,
                selected: sort == current,
                onTap: () => Navigator.of(context).pop(sort),
              ),
            SizedBox(height: dimens.space2),
          ],
        ),
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  const _SortOptionTile({required this.sort, required this.selected, required this.onTap});

  final WatchlistSort sort;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dimens.space4, vertical: dimens.space3),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                sort.label,
                style: TextStyle(
                  color: selected ? colors.accentDefault : colors.textPrimary,
                  fontSize: 15,
                  fontWeight: selected ? AppTypography.medium : AppTypography.regular,
                ),
              ),
            ),
            if (selected) Icon(Icons.check, color: colors.accentDefault, size: dimens.iconMd),
          ],
        ),
      ),
    );
  }
}
