import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// 데이터 로딩 중임을 나타내는 pulse 애니메이션 박스.
class SkeletonBar extends StatefulWidget {
  const SkeletonBar({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<SkeletonBar> createState() => _SkeletonBarState();
}

class _SkeletonBarState extends State<SkeletonBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return FadeTransition(
      opacity: _controller.drive(Tween<double>(begin: 0.4, end: 1)),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: colors.feedbackSkeleton,
          borderRadius: BorderRadius.circular(dimens.radiusSm),
        ),
      ),
    );
  }
}
