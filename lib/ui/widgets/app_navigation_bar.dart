import 'package:flutter/material.dart';

import '../device.dart';
import '../theme/dashboard_visual_theme.dart';
import 'tonal_glass_surface.dart';

enum AppDestination {
  dashboard('Home', Icons.home_rounded, Icons.home_outlined),
  transactions(
    'Activity',
    Icons.swap_horizontal_circle_rounded,
    Icons.swap_horizontal_circle_outlined,
  ),
  planning(
    'Planning',
    Icons.calendar_month_rounded,
    Icons.calendar_month_outlined,
  ),
  graphs('Insights', Icons.auto_graph_rounded, Icons.auto_graph_outlined);

  const AppDestination(this.label, this.selectedIcon, this.icon);

  final String label;
  final IconData selectedIcon;
  final IconData icon;
}

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    required this.selected,
    required this.onSelect,
    required this.onAdd,
    super.key,
  });

  final AppDestination selected;
  final ValueChanged<AppDestination> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(Sizes.md, 0, Sizes.md, Sizes.sm),
      child: SizedBox(
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SizedBox(
                  height: 64,
                  child: TonalGlassSurface(
                    tone: GlassTone.chrome,
                    radius: 32,
                    borderColor: visual.glassBorder,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    boxShadow: [
                      BoxShadow(
                        color: visual.shadow,
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    child: Row(
                      children: [
                        _DestinationButton(
                          destination: AppDestination.dashboard,
                          selected: selected == AppDestination.dashboard,
                          onTap: onSelect,
                        ),
                        _DestinationButton(
                          destination: AppDestination.transactions,
                          selected: selected == AppDestination.transactions,
                          onTap: onSelect,
                        ),
                        const SizedBox(width: 70),
                        _DestinationButton(
                          destination: AppDestination.planning,
                          selected: selected == AppDestination.planning,
                          onTap: onSelect,
                        ),
                        _DestinationButton(
                          destination: AppDestination.graphs,
                          selected: selected == AppDestination.graphs,
                          onTap: onSelect,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AddButton(onTap: onAdd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      label: 'Add transaction',
      child: Tooltip(
        message: 'Add transaction',
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            scale: _pressed ? 0.9 : 1,
            child: AnimatedContainer(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 160),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(visual.accent, Colors.white, 0.22)!,
                    visual.accent,
                    visual.glowPrimary,
                  ],
                  stops: const [0, 0.46, 1],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.32),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: visual.accent.withValues(
                      alpha: _pressed ? 0.22 : 0.46,
                    ),
                    blurRadius: _pressed ? 12 : 24,
                    offset: Offset(0, _pressed ? 4 : 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DestinationButton extends StatelessWidget {
  const _DestinationButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final ValueChanged<AppDestination> onTap;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final selectedForeground =
        ThemeData.estimateBrightnessForColor(visual.navigationSelected) ==
            Brightness.dark
        ? Colors.white
        : const Color(0xFF171329);

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: destination.label,
        child: Tooltip(
          message: destination.label,
          child: InkWell(
            onTap: () => onTap(destination),
            customBorder: const CircleBorder(),
            child: Center(
              child: AnimatedContainer(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected
                      ? visual.navigationSelected
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  color: selected ? selectedForeground : visual.textSecondary,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
