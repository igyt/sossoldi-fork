import 'package:flutter/material.dart';

import '../../../ui/widgets/section_header.dart';

class CardLabel extends StatelessWidget {
  const CardLabel({super.key, required this.label, this.subtitle});

  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SectionHeader(title: label, subtitle: subtitle);
  }
}
