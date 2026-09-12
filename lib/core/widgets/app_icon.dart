import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma에서 내보낸 SVG 아이콘을 토큰 색으로 물들여 그립니다.
///
/// SVG 파일 자체의 색은 무시하고 [color]로 덮어써서, 화면 어디서든
/// `context.colors.*` 시맨틱 토큰만으로 아이콘 색을 제어할 수 있게 합니다.
class AppIcon extends StatelessWidget {
  const AppIcon(this.asset, {super.key, required this.color, required this.size});

  final String asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$asset',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// Figma에서 받은 아이콘 asset 파일명 모음.
abstract final class AppIcons {
  static const String search = 'ico_search.svg';
  static const String searchEmpty = 'ico_search_empty.svg';
  static const String star = 'ico_star.svg';
  static const String starFill = 'ico_starFill.svg';
  static const String refresh = 'ico_refresh.svg';
}
