import 'package:flutter/material.dart';

import '../../../core/format/number_format.dart';
import '../../../core/format/price_format.dart';
import '../../../data/models/quote.dart';
import '../../../theme/theme.dart';

/// 시가 / 고가 / 저가 / 거래량 / 시가총액 요약 카드.
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    final List<(String, String)> entries = <(String, String)>[
      ('시가', formatPrice(quote.open)),
      ('고가', formatPrice(quote.high)),
      ('저가', formatPrice(quote.low)),
      ('거래량', formatVolumeShort(quote.accumulatedVolume)),
      ('시가총액', formatMarketCapShort(quote.marketCap)),
    ];

    return Container(
      padding: EdgeInsets.all(dimens.space4),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(dimens.radiusLg),
      ),
      child: Wrap(
        spacing: dimens.space4,
        runSpacing: dimens.space3,
        children: <Widget>[
          for (final (String label, String value) in entries)
            SizedBox(
              width: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 12,
                      fontWeight: AppTypography.regular,
                    ),
                  ),
                  SizedBox(height: dimens.space1),
                  Text(
                    value,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
