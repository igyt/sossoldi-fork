import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/categories_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../ui/device.dart';
import '../../ui/snack_bars/transactions_snack_bars.dart';
import 'widgets/account_section.dart';
import 'widgets/dashboard_balance_hero.dart';
import 'widgets/organize_section.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<DashboardPage> {
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _entered = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(categoriesProvider);
    final snapshot = ref.watch(dashboardProvider);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    ref.listen(
      duplicatedTransactionProvider,
      (prev, curr) => showDuplicatedTransactionSnackBar(
        context,
        transaction: curr,
        ref: ref,
      ),
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            Sizes.responsiveInsets(context),
            MediaQuery.paddingOf(context).top + Sizes.lg,
            Sizes.responsiveInsets(context),
            MediaQuery.paddingOf(context).bottom + Sizes.xl,
          ),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: AnimatedSlide(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 440),
                  curve: Curves.easeOutCubic,
                  offset: _entered ? Offset.zero : const Offset(0, 0.025),
                  child: AnimatedOpacity(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 360),
                    opacity: _entered ? 1 : 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardBalanceHero(snapshot: snapshot),
                        const SizedBox(height: Sizes.lg),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth >= 900) {
                              return const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 6, child: AccountSection()),
                                  SizedBox(width: Sizes.lg),
                                  Expanded(flex: 5, child: OrganizeSection()),
                                ],
                              );
                            }
                            return const Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AccountSection(),
                                SizedBox(height: Sizes.lg),
                                OrganizeSection(),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
