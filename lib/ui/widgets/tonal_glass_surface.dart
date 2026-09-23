import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/dashboard_visual_theme.dart';

class TonalGlassSurface extends StatelessWidget {
  const TonalGlassSurface({
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.radius = 24,
    this.blurSigma = 0,
    this.color,
    this.gradient,
    this.borderColor,
    this.boxShadow,
    this.semanticLabel,
    this.pressScale = 0.985,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blurSigma;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final String? semanticLabel;

  /// Scale applied while the surface is pressed. Use 1 to disable.
  final double pressScale;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    final borderRadius = BorderRadius.circular(radius);
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? color ?? visual.glassFill : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor ?? visual.glassBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: onTap == null
            ? Padding(padding: padding ?? EdgeInsets.zero, child: child)
            : InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: child,
                ),
              ),
      ),
    );

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: visual.shadow.withValues(alpha: visual.shadow.a * 0.6),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: blurSigma <= 0
            ? content
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: content,
              ),
      ),
    );

    if (onTap != null && pressScale != 1) {
      surface = _PressScale(scale: pressScale, child: surface);
    }

    if (semanticLabel != null) {
      surface = Semantics(
        container: true,
        label: semanticLabel,
        button: onTap != null,
        child: surface,
      );
    }

    return RepaintBoundary(
      child: Padding(padding: margin ?? EdgeInsets.zero, child: surface),
    );
  }
}

class _PressScale extends StatefulWidget {
  const _PressScale({required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed && !reduceMotion ? widget.scale : 1,
        duration: Duration(milliseconds: _pressed ? 90 : 220),
        curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
