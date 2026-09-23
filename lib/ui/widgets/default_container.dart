import 'package:flutter/material.dart';

import '../device.dart';
import '../theme/dashboard_visual_theme.dart';

class DefaultContainer extends StatelessWidget {
  const DefaultContainer({
    required this.child,
    this.padding = const EdgeInsets.all(Sizes.lg),
    this.margin = const EdgeInsets.symmetric(horizontal: Sizes.lg),
    super.key,
  });

  static const double radius = 24;

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: visual.raisedSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: visual.hairline),
        boxShadow: [
          BoxShadow(
            color: visual.shadow.withValues(alpha: visual.shadow.a * 0.5),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
