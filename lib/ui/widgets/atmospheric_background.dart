import 'package:flutter/material.dart';

import '../theme/dashboard_visual_theme.dart';

class AtmosphericBackground extends StatelessWidget {
  const AtmosphericBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            visual.backgroundTop,
            visual.backgroundMiddle,
            visual.backgroundBottom,
          ],
          stops: const [0, 0.43, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -150,
            right: -90,
            child: _AmbientGlow(color: visual.glowPrimary, size: 420),
          ),
          Positioned(
            top: 430,
            left: -180,
            child: _AmbientGlow(color: visual.glowSecondary, size: 480),
          ),
          child,
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.32), Colors.transparent],
          ),
        ),
      ),
    );
  }
}
