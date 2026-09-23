import 'package:flutter/material.dart';

import '../device.dart';
import 'default_container.dart';

class DefaultCard extends StatelessWidget {
  const DefaultCard({required this.child, required this.onTap, super.key});

  final Widget child;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(DefaultContainer.radius);
    return DefaultContainer(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(Sizes.md), child: child),
        ),
      ),
    );
  }
}
