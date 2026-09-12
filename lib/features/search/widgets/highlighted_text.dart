import 'package:flutter/material.dart';

/// [query]와 일치하는 부분만 [highlightStyle]로 바꿔 그립니다. (대소문자 무시)
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightStyle,
  });

  final String text;
  final String query;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    final String trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: baseStyle);
    }

    final int index = text.toLowerCase().indexOf(trimmedQuery.toLowerCase());
    if (index < 0) {
      return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: baseStyle);
    }

    final int end = index + trimmedQuery.length;
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: text.substring(0, index), style: baseStyle),
          TextSpan(text: text.substring(index, end), style: highlightStyle),
          TextSpan(text: text.substring(end), style: baseStyle),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
