import 'package:flutter/material.dart';

import '../../../data/models/chart_period.dart';
import '../../../theme/theme.dart';

class PeriodTabs extends StatelessWidget {
  const PeriodTabs({super.key, required this.selected, required this.onSelected});

  final ChartPeriod selected;
  final ValueChanged<ChartPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppDimens dimens = context.dimens;

    return Row(
      children: <Widget>[
        for (final ChartPeriod period in ChartPeriod.values) ...<Widget>[
          Expanded(
            child: _PeriodTab(
              period: period,
              selected: period == selected,
              onTap: () => onSelected(period),
            ),
          ),
          if (period != ChartPeriod.values.last) SizedBox(width: dimens.space2),
        ],
      ],
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({required this.period, required this.selected, required this.onTap});

  final ChartPeriod period;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(dimens.radiusMd),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: dimens.space2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.accentBg : Colors.transparent,
          borderRadius: BorderRadius.circular(dimens.radiusMd),
        ),
        child: Text(
          period.label,
          style: TextStyle(
            color: selected ? colors.accentDefault : colors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? AppTypography.medium : AppTypography.regular,
          ),
        ),
      ),
    );
  }
}
