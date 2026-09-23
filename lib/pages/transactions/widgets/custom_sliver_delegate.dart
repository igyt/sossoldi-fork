import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/currency_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../../ui/formatters/formatted_date_range.dart';
import '../../../ui/theme/dashboard_visual_theme.dart';
import '../../../ui/widgets/blur_widget.dart';
import '../../../ui/widgets/segmented_pill.dart';
import 'month_selector.dart';

class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  const CustomSliverDelegate({
    required this.ticker,
    required this.myTabs,
    required this.tabController,
    required this.expandedHeight,
    required this.minHeight,
  });

  final TabController tabController;
  final List<Tab> myTabs;
  final TickerProvider ticker;

  final double minHeight;
  final double expandedHeight;

  // TODO: expand on Tap

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    /// 0 when fully extended, 1 when fully collapsed
    double shrinkPercentage = min(1, shrinkOffset / (maxExtent - minExtent));

    // TODO: improve animations
    // prevent the expanded widget from shrinking in size when collapsing

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.responsiveInsets(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (shrinkPercentage < .5)
                  Opacity(
                    opacity: 1 - shrinkPercentage,
                    child: _buildExtendedWidget(context, shrinkPercentage),
                  ),
                if (shrinkPercentage > .5)
                  Opacity(
                    opacity: shrinkPercentage,
                    child: CollapsedWidget(myTabs, tabController),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Sizes.sm),
        ],
      ),
    );
  }

  Widget _buildExtendedWidget(BuildContext context, double shrinkPercentage) {
    return LayoutBuilder(
      builder: (context, constraints) => ClipRect(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: SizedBox(
            width: constraints.maxWidth,
            child: IgnorePointer(
              // disable all buttons during the transition
              ignoring: (shrinkPercentage != 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedBuilder(
                    animation: tabController,
                    builder: (context, _) => SegmentedPill<int>(
                      options: {
                        for (var i = 0; i < myTabs.length; i++)
                          i: myTabs[i].text!,
                      },
                      selected: tabController.index,
                      onChanged: tabController.animateTo,
                    ),
                  ),
                  const SizedBox(height: Sizes.md),
                  const MonthSelector(type: MonthSelectorType.advanced),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  TickerProvider? get vsync => ticker;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration {
    return FloatingHeaderSnapConfiguration(
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 200),
    );
  }
}

class CollapsedWidget extends StatelessWidget {
  const CollapsedWidget(this.myTabs, this.tabController, {super.key});

  final List<Tab> myTabs;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final totalAmount = ref.watch(totalAmountProvider);
        final startDate = ref.watch(filterDateStartProvider);
        final endDate = ref.watch(filterDateEndProvider);
        final currencyState = ref.watch(currencyStateProvider);
        final visual = context.dashboardTheme;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: Sizes.xs,
                horizontal: Sizes.md,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Sizes.borderRadius * 10),
                color: visual.navigationSelected,
              ),
              child: Text(
                myTabs[tabController.index].text!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: visual.navigationFill.withValues(alpha: 1),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              getFormattedDateRange(startDate, endDate),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: visual.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            BlurWidget(
              sigma: 12,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: totalAmount.toCurrency(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: totalAmount.toColor(),
                      ),
                    ),
                    TextSpan(
                      text: currencyState.symbol,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: totalAmount.toColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
