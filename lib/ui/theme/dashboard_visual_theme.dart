import 'package:flutter/material.dart';

@immutable
class DashboardVisualTheme extends ThemeExtension<DashboardVisualTheme> {
  const DashboardVisualTheme({
    required this.backgroundTop,
    required this.backgroundMiddle,
    required this.backgroundBottom,
    required this.glowPrimary,
    required this.glowSecondary,
    required this.heroStart,
    required this.heroEnd,
    required this.glassFill,
    required this.glassBorder,
    required this.solidSurface,
    required this.raisedSurface,
    required this.navigationFill,
    required this.navigationSelected,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.positive,
    required this.negative,
    required this.chartPrimary,
    required this.chartSecondary,
    required this.chartFill,
    required this.shadow,
  });

  static const light = DashboardVisualTheme(
    backgroundTop: Color(0xFFF1EAFF),
    backgroundMiddle: Color(0xFFF6F7FC),
    backgroundBottom: Color(0xFFE9F1FA),
    glowPrimary: Color(0x997D4FFF),
    glowSecondary: Color(0x7557C8FF),
    heroStart: Color(0xEFFFFFFF),
    heroEnd: Color(0xBDE8E1FB),
    glassFill: Color(0xA8FFFFFF),
    glassBorder: Color(0xBFFFFFFF),
    solidSurface: Color(0xFFF8F8FC),
    raisedSurface: Color(0xFFFFFFFF),
    navigationFill: Color(0xE6FFFFFF),
    navigationSelected: Color(0xFF171329),
    textPrimary: Color(0xFF171329),
    textSecondary: Color(0xFF696578),
    accent: Color(0xFF7352E8),
    positive: Color(0xFF0E9F78),
    negative: Color(0xFFE24D67),
    chartPrimary: Color(0xFF6F4CDE),
    chartSecondary: Color(0xFFB8ACD8),
    chartFill: Color(0x526F4CDE),
    shadow: Color(0x241C1730),
  );

  static const dark = DashboardVisualTheme(
    backgroundTop: Color(0xFF6231B5),
    backgroundMiddle: Color(0xFF241044),
    backgroundBottom: Color(0xFF080910),
    glowPrimary: Color(0xCC8D58FF),
    glowSecondary: Color(0x995238C8),
    heroStart: Color(0x3DFFFFFF),
    heroEnd: Color(0x161A122D),
    glassFill: Color(0x22FFFFFF),
    glassBorder: Color(0x38FFFFFF),
    solidSurface: Color(0xFF17171D),
    raisedSurface: Color(0xFF202027),
    navigationFill: Color(0xE614141B),
    navigationSelected: Color(0xFFF5F2FF),
    textPrimary: Color(0xFFF8F6FF),
    textSecondary: Color(0xFFAAA6B6),
    accent: Color(0xFFA88AF7),
    positive: Color(0xFF35D6A6),
    negative: Color(0xFFFF6F88),
    chartPrimary: Color(0xFFC2AAFF),
    chartSecondary: Color(0xFF786E8D),
    chartFill: Color(0x52A482FF),
    shadow: Color(0x99000000),
  );

  final Color backgroundTop;
  final Color backgroundMiddle;
  final Color backgroundBottom;
  final Color glowPrimary;
  final Color glowSecondary;
  final Color heroStart;
  final Color heroEnd;
  final Color glassFill;
  final Color glassBorder;
  final Color solidSurface;
  final Color raisedSurface;
  final Color navigationFill;
  final Color navigationSelected;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color positive;
  final Color negative;
  final Color chartPrimary;
  final Color chartSecondary;
  final Color chartFill;
  final Color shadow;

  Color get hairline => textPrimary.withValues(alpha: 0.08);

  @override
  DashboardVisualTheme copyWith({
    Color? backgroundTop,
    Color? backgroundMiddle,
    Color? backgroundBottom,
    Color? glowPrimary,
    Color? glowSecondary,
    Color? heroStart,
    Color? heroEnd,
    Color? glassFill,
    Color? glassBorder,
    Color? solidSurface,
    Color? raisedSurface,
    Color? navigationFill,
    Color? navigationSelected,
    Color? textPrimary,
    Color? textSecondary,
    Color? accent,
    Color? positive,
    Color? negative,
    Color? chartPrimary,
    Color? chartSecondary,
    Color? chartFill,
    Color? shadow,
  }) {
    return DashboardVisualTheme(
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundMiddle: backgroundMiddle ?? this.backgroundMiddle,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      glowPrimary: glowPrimary ?? this.glowPrimary,
      glowSecondary: glowSecondary ?? this.glowSecondary,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      solidSurface: solidSurface ?? this.solidSurface,
      raisedSurface: raisedSurface ?? this.raisedSurface,
      navigationFill: navigationFill ?? this.navigationFill,
      navigationSelected: navigationSelected ?? this.navigationSelected,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      chartPrimary: chartPrimary ?? this.chartPrimary,
      chartSecondary: chartSecondary ?? this.chartSecondary,
      chartFill: chartFill ?? this.chartFill,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  DashboardVisualTheme lerp(covariant DashboardVisualTheme? other, double t) {
    if (other == null) return this;
    return DashboardVisualTheme(
      backgroundTop: Color.lerp(backgroundTop, other.backgroundTop, t)!,
      backgroundMiddle: Color.lerp(
        backgroundMiddle,
        other.backgroundMiddle,
        t,
      )!,
      backgroundBottom: Color.lerp(
        backgroundBottom,
        other.backgroundBottom,
        t,
      )!,
      glowPrimary: Color.lerp(glowPrimary, other.glowPrimary, t)!,
      glowSecondary: Color.lerp(glowSecondary, other.glowSecondary, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      solidSurface: Color.lerp(solidSurface, other.solidSurface, t)!,
      raisedSurface: Color.lerp(raisedSurface, other.raisedSurface, t)!,
      navigationFill: Color.lerp(navigationFill, other.navigationFill, t)!,
      navigationSelected: Color.lerp(
        navigationSelected,
        other.navigationSelected,
        t,
      )!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      chartPrimary: Color.lerp(chartPrimary, other.chartPrimary, t)!,
      chartSecondary: Color.lerp(chartSecondary, other.chartSecondary, t)!,
      chartFill: Color.lerp(chartFill, other.chartFill, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension DashboardVisualThemeContext on BuildContext {
  DashboardVisualTheme get dashboardTheme =>
      Theme.of(this).extension<DashboardVisualTheme>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? DashboardVisualTheme.dark
          : DashboardVisualTheme.light);
}
