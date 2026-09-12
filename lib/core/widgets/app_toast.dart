import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// 검색 화면의 관심 등록 / 해제 토스트.
///
/// Figma에 노출 시간과 사라지는 방식이 정의되어 있지 않아 2초 노출 후 자동으로
/// 사라지는 `SnackBar` 기반으로 구현했습니다. (README 메모 참고)
class AppToast {
  static void show(BuildContext context, {required bool isFavorite}) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.surfaceOverlay,
          elevation: 0,
          margin: EdgeInsets.symmetric(
            horizontal: dimens.space5,
            vertical: dimens.space5,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: dimens.space4,
            vertical: dimens.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dimens.radiusLg),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: colors.favoriteActive,
                size: dimens.iconMd,
              ),
              SizedBox(width: dimens.space2),
              Text(
                isFavorite ? '관심이 등록되었습니다' : '관심이 해제되었습니다',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: AppTypography.medium,
                ),
              ),
            ],
          ),
        ),
      );
  }
}
