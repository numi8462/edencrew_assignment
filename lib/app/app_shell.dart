import 'package:flutter/material.dart';

import '../core/widgets/app_icon.dart';
import '../features/search/search_screen.dart';
import '../features/watchlist/watchlist_screen.dart';
import '../theme/theme.dart';

/// 하단 탭 바로 관심 / 검색 화면을 전환하는 앱 셸.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const List<Widget> _tabs = <Widget>[
    WatchlistScreen(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          border: Border(top: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: dimens.tabBarHeight,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _NavItem(
                    label: '관심',
                    icon: AppIcons.star,
                    selected: _index == 0,
                    onTap: () => setState(() => _index = 0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    label: '검색',
                    icon: AppIcons.search,
                    selected: _index == 1,
                    onTap: () => setState(() => _index = 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final Color color = selected ? colors.navActive : colors.navInactive;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AppIcon(icon, color: color, size: dimens.iconMd),
          SizedBox(height: dimens.space1),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: selected ? AppTypography.medium : AppTypography.regular,
            ),
          ),
        ],
      ),
    );
  }
}
