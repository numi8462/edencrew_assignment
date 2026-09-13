import 'package:flutter/material.dart';

import '../../../core/format/number_format.dart';
import '../../../core/format/price_format.dart';
import '../../../core/widgets/skeleton_bar.dart';
import '../../../data/models/quote.dart';
import '../../../theme/theme.dart';

/// 시가 / 고가 / 저가 / 거래량 / 시가총액 요약 카드.
///
/// 3칸(시가·고가·저가) + 2칸(거래량·시가총액) 그리드로, 각 항목을 개별 박스로
/// 구분해 표시합니다.
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> entries = <(String, String)>[
      ('시가', formatPrice(quote.open)),
      ('고가', formatPrice(quote.high)),
      ('저가', formatPrice(quote.low)),
      ('거래량', formatVolumeShort(quote.accumulatedVolume)),
      ('시가총액', formatMarketCapShort(quote.marketCap)),
    ];

    return _SummaryGrid(
      cells: <_SummaryCellData>[
        for (final (String label, String value) in entries)
          _SummaryCellData(label: label, child: _SummaryValue(value)),
      ],
    );
  }
}

/// [SummaryCard]와 같은 그리드 모양의 로딩 상태.
class SummaryCardSkeleton extends StatelessWidget {
  const SummaryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>['시가', '고가', '저가', '거래량', '시가총액'];

    return _SummaryGrid(
      cells: <_SummaryCellData>[
        for (final String label in labels)
          _SummaryCellData(label: label, child: const SkeletonBar(width: 48, height: 16)),
      ],
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 14,
        fontWeight: AppTypography.medium,
      ),
    );
  }
}

class _SummaryCellData {
  const _SummaryCellData({required this.label, required this.child});

  final String label;
  final Widget child;
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.cells});

  final List<_SummaryCellData> cells;

  @override
  Widget build(BuildContext context) {
    final AppDimens dimens = context.dimens;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _SummaryCell(data: cells[0])),
            SizedBox(width: dimens.space2),
            Expanded(child: _SummaryCell(data: cells[1])),
            SizedBox(width: dimens.space2),
            Expanded(child: _SummaryCell(data: cells[2])),
          ],
        ),
        SizedBox(height: dimens.space2),
        Row(
          children: <Widget>[
            Expanded(child: _SummaryCell(data: cells[3])),
            SizedBox(width: dimens.space2),
            Expanded(child: _SummaryCell(data: cells[4])),
          ],
        ),
      ],
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({required this.data});

  final _SummaryCellData data;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: dimens.space3, vertical: dimens.space3),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: BorderRadius.circular(dimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            data.label,
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 12,
              fontWeight: AppTypography.regular,
            ),
          ),
          SizedBox(height: dimens.space1),
          data.child,
        ],
      ),
    );
  }
}
