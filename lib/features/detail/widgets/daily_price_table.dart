import 'package:flutter/material.dart';

import '../../../core/format/date_format.dart';
import '../../../core/format/number_format.dart';
import '../../../core/format/price_format.dart';
import '../../../data/models/daily_price.dart';
import '../../../theme/theme.dart';

/// 일별 시세 표. `날짜 / 종가 / 등락 / 거래량` 컬럼.
class DailyPriceTable extends StatelessWidget {
  const DailyPriceTable({super.key, required this.prices});

  final List<DailyPrice> prices;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TableRow(
          date: '날짜',
          close: '종가',
          change: '등락',
          volume: '거래량',
          isHeader: true,
        ),
        for (final DailyPrice price in prices) ...<Widget>[
          Divider(height: dimens.borderHairline, thickness: dimens.borderHairline, color: colors.borderSubtle),
          _TableRow(
            date: formatMonthDay(price.date),
            close: formatPrice(price.close),
            change: formatChange(price.changeAmount, price.changeRate),
            volume: formatVolumeShort(price.volume),
            changeColor: switch (price.direction) {
              PriceDirection.up => colors.priceUpText,
              PriceDirection.down => colors.priceDownText,
              PriceDirection.flat => colors.priceFlatText,
            },
          ),
        ],
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.date,
    required this.close,
    required this.change,
    required this.volume,
    this.isHeader = false,
    this.changeColor,
  });

  final String date;
  final String close;
  final String change;
  final String volume;
  final bool isHeader;
  final Color? changeColor;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    final TextStyle baseStyle = TextStyle(
      color: isHeader ? colors.textTertiary : colors.textPrimary,
      fontSize: isHeader ? 12 : 13,
      fontWeight: isHeader ? AppTypography.regular : AppTypography.medium,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: dimens.space2),
      child: Row(
        children: <Widget>[
          Expanded(flex: 3, child: Text(date, style: baseStyle)),
          Expanded(
            flex: 3,
            child: Text(close, textAlign: TextAlign.right, style: baseStyle),
          ),
          Expanded(
            flex: 4,
            child: Text(
              change,
              textAlign: TextAlign.right,
              style: baseStyle.copyWith(color: changeColor ?? baseStyle.color),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(volume, textAlign: TextAlign.right, style: baseStyle),
          ),
        ],
      ),
    );
  }
}
