import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../theme/theme.dart';

enum SearchEmptyMode { initial, noResults }

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key, required this.mode, this.query});

  final SearchEmptyMode mode;
  final String? query;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    final bool isInitial = mode == SearchEmptyMode.initial;
    final String title = isInitial ? '종목을 검색해 보세요' : '검색 결과가 없습니다';
    final String subtitle = isInitial
        ? '종목명 또는 종목코드 6자리로\n검색하실 수 있습니다.'
        : "'${query ?? ''}'와 일치하는 검색 결과를 찾지 못했습니다.";

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dimens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcon(
              isInitial ? AppIcons.search : AppIcons.searchEmpty,
              size: 64,
              color: colors.textDisabled,
            ),
            SizedBox(height: dimens.space4),
            Text(
              title,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: AppTypography.medium,
              ),
            ),
            SizedBox(height: dimens.space2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 13,
                fontWeight: AppTypography.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
