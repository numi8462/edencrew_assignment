import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../theme/theme.dart';

/// 검색 입력창.
///
/// `TextField`를 `Row` 안에 그냥 두면(`Expanded`로 감싸더라도) 내부 데코레이터의
/// 높이 계산 때문에 옆 아이콘보다 몇 px 아래로 처져 보입니다. 실행 중인 화면을
/// 픽셀 단위로 캡처해서 확인한 결과이며, 아래처럼 고정 높이 박스로 직접 감싸는 것이
/// 가장 확실했습니다.
/// - `SizedBox(height: iconMd)` — TextField의 세로 크기를 아이콘과 같은 높이로 고정.
/// - `isDense` + `isCollapsed` + `contentPadding: zero` — 데코레이터가 자체적으로
///   더하는 여백을 제거.
/// - `strutStyle`(forceStrutHeight) — 줄 높이를 글자 크기와 정확히 같게 강제.
/// - `textAlignVertical.center` — 그 박스 안에서 텍스트를 세로 중앙에 배치.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  static const double _height = 40;
  static const double _fontSize = 15;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    final TextStyle textStyle = TextStyle(
      color: colors.textPrimary,
      fontSize: _fontSize,
      height: 1.0,
      fontWeight: AppTypography.regular,
    );

    return Container(
      height: _height,
      padding: EdgeInsets.symmetric(horizontal: dimens.space3),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: BorderRadius.circular(dimens.radiusMd),
        border: Border.all(color: colors.borderStrong, width: dimens.borderHairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AppIcon(AppIcons.search, color: colors.textTertiary, size: dimens.iconMd),
          SizedBox(width: dimens.space2),
          Expanded(
            // TextField는 `textAlignVertical.center`를 줘도 내부 베이스라인 계산
            // 때문에 여전히 3px 정도 아래로 처집니다. 실행 화면을 픽셀 단위로 캡처해
            // 실측한 값(3px)만큼 `Transform.translate`로 최종 보정합니다.
            child: SizedBox(
              height: dimens.iconMd,
              child: Transform.translate(
                offset: const Offset(0, -3),
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  cursorHeight: _fontSize,
                  style: textStyle,
                  textAlignVertical: TextAlignVertical.center,
                  strutStyle: const StrutStyle(
                    fontSize: _fontSize,
                    height: 1.0,
                    forceStrutHeight: true,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: '종목명 또는 종목코드',
                    hintStyle: textStyle.copyWith(color: colors.textTertiary),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: dimens.space2),
          GestureDetector(
            onTap: onClear,
            behavior: HitTestBehavior.opaque,
            child: Icon(Icons.close, color: colors.textTertiary, size: dimens.iconSm),
          ),
        ],
      ),
    );
  }
}
