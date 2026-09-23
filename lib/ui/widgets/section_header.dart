import 'package:flutter/material.dart';

import '../device.dart';
import '../theme/dashboard_visual_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.only(left: Sizes.sm),
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    color: visual.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: visual.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Small capsule action used next to section titles.
class SectionAction extends StatelessWidget {
  const SectionAction({
    required this.label,
    required this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return Material(
      color: visual.accent.withValues(alpha: 0.12),
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.md,
            vertical: Sizes.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: visual.accent),
                const SizedBox(width: Sizes.xs),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: visual.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
