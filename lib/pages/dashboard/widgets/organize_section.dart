import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../model/category_transaction.dart';
import '../../../model/transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../../ui/theme/dashboard_visual_theme.dart';
import '../../../ui/widgets/blur_widget.dart';
import '../../../ui/widgets/rounded_icon.dart';
import '../../../ui/widgets/tonal_glass_surface.dart';

class OrganizeSection extends ConsumerWidget {
  const OrganizeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(organizeQueueProvider);
    final visual = context.dashboardTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return TonalGlassSurface(
      radius: 28,
      padding: const EdgeInsets.all(Sizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: Sizes.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organize',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: visual.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Give every payment a home',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: visual.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              queue.when(
                data: (data) => data.total == 0
                    ? const SizedBox.shrink()
                    : _QueueBadge(count: data.total),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: Sizes.lg),
          AnimatedSwitcher(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: queue.when(
              data: (data) {
                if (data.items.isEmpty) {
                  return const _OrganizeEmpty(key: ValueKey('organize-empty'));
                }
                return _OrganizeTile(
                  key: ValueKey(data.items.first.id),
                  transaction: data.items.first,
                );
              },
              loading: () =>
                  const _OrganizeLoading(key: ValueKey('organize-loading')),
              error: (_, _) => _OrganizeError(
                key: const ValueKey('organize-error'),
                onRetry: () => ref.invalidate(organizeQueueProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueBadge extends StatelessWidget {
  const _QueueBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.sm,
        vertical: Sizes.xs,
      ),
      decoration: BoxDecoration(
        color: visual.accent.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$count left',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: visual.accent,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OrganizeEmpty extends StatelessWidget {
  const _OrganizeEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: visual.positive.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.check_rounded,
                color: visual.positive,
                size: 28,
              ),
            ),
            const SizedBox(height: Sizes.sm),
            Text(
              'Everything is organized',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: visual.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: Sizes.xs),
            Text(
              'New uncategorized payments will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: visual.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizeLoading extends StatelessWidget {
  const _OrganizeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator(color: visual.accent)),
    );
  }
}

class _OrganizeError extends StatelessWidget {
  const _OrganizeError({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return SizedBox(
      height: 220,
      child: Center(
        child: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(
            'Reload organizer',
            style: TextStyle(color: visual.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _OrganizeTile extends ConsumerStatefulWidget {
  const _OrganizeTile({required this.transaction, super.key});

  final Transaction transaction;

  @override
  ConsumerState<_OrganizeTile> createState() => _OrganizeTileState();
}

class _OrganizeTileState extends ConsumerState<_OrganizeTile> {
  bool _busy = false;
  CategoryTransaction? _category;

  Transaction get transaction => widget.transaction;

  Future<void> _confirm() async {
    final category = _category;
    if (_busy || category == null || category.id == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(transactionsProvider.notifier)
          .assignCategory(transaction, category);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openSheet() async {
    final type = transaction.type;
    if (type.categoryType == null) return;
    await showModalBottomSheet<void>(
      context: context,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Sizes.borderRadius),
          topRight: Radius.circular(Sizes.borderRadius),
        ),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.5,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, controller) => OrganizeCategorySheet(
          type: type,
          scrollController: controller,
          onSelected: (category) {
            Navigator.of(context).pop();
            setState(() => _category = category);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyStateProvider);
    final visual = context.dashboardTheme;
    final signedAmount = transaction.type == TransactionType.expense
        ? "-${transaction.amount.toCurrency()}"
        : transaction.amount.toCurrency();
    final label = (transaction.note?.isEmpty ?? true)
        ? DateFormat("dd MMM").format(transaction.date)
        : transaction.note!;
    final canConfirm = !_busy && _category?.id != null;
    final amountColor = transaction.type == TransactionType.expense
        ? visual.negative
        : visual.positive;

    return TonalGlassSurface(
      radius: 22,
      padding: const EdgeInsets.all(Sizes.md),
      boxShadow: const [],
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _busy ? 0.56 : 1,
        child: IgnorePointer(
          ignoring: _busy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      transaction.type == TransactionType.expense
                          ? Icons.north_east_rounded
                          : Icons.south_west_rounded,
                      color: amountColor,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: Sizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: visual.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${DateFormat("dd MMM yyyy").format(transaction.date)}"
                          "${transaction.bankAccountName != null ? " · ${transaction.bankAccountName}" : ""}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: visual.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Sizes.sm),
                  BlurWidget(
                    sigma: 16,
                    child: Text(
                      "$signedAmount ${currency.symbol}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sizes.xl),
              Text(
                'CATEGORY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: visual.textSecondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: Sizes.sm),
              SizedBox(
                height: 58,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: FilledButton(
                        onPressed: _openSheet,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.sm,
                          ),
                          backgroundColor: visual.solidSurface,
                          foregroundColor: visual.textPrimary,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(18),
                            ),
                          ),
                          side: BorderSide(color: visual.glassBorder),
                          elevation: 0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: white,
                                shape: BoxShape.circle,
                              ),
                              child: _category == null
                                  ? const Icon(
                                      Icons.category_outlined,
                                      color: grey1,
                                      size: 19,
                                    )
                                  : Icon(
                                      iconList[_category!.symbol],
                                      color:
                                          categoryColorListTheme[_category!
                                              .color],
                                      size: 20,
                                    ),
                            ),
                            const SizedBox(width: Sizes.sm),
                            Expanded(
                              child: Text(
                                _category?.name ?? "--",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: visual.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    SizedBox(
                      width: 66,
                      child: FilledButton(
                        onPressed: canConfirm ? _confirm : null,
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: visual.positive,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: visual.positive,
                          disabledForegroundColor: Colors.white70,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(18),
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: _busy
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_rounded, size: 29),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrganizeCategorySheet extends ConsumerStatefulWidget {
  const OrganizeCategorySheet({
    required this.type,
    required this.scrollController,
    required this.onSelected,
    super.key,
  });

  final TransactionType type;
  final ScrollController scrollController;
  final ValueChanged<CategoryTransaction> onSelected;

  @override
  ConsumerState<OrganizeCategorySheet> createState() =>
      _OrganizeCategorySheetState();
}

class _OrganizeCategorySheetState extends ConsumerState<OrganizeCategorySheet> {
  int? _pendingParentId;

  Future<void> _selectParent(CategoryTransaction category) async {
    final subcategories = await ref.read(
      subcategoriesProvider(category.id!).future,
    );
    if (!mounted) return;
    if (subcategories.isNotEmpty && _pendingParentId != category.id) {
      setState(() => _pendingParentId = category.id);
      return;
    }
    widget.onSelected(category);
  }

  @override
  Widget build(BuildContext context) {
    final categoryType = widget.type.categoryType;
    final categoriesList = ref.watch(categoriesByTypeProvider(categoryType));
    final frequentCategories = ref.watch(
      frequentCategoriesProvider(categoryType),
    );

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(title: const Text("Category")),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(
                      left: Sizes.lg,
                      top: Sizes.xxl,
                      bottom: Sizes.md,
                    ),
                    child: Text(
                      "MORE FREQUENT",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    height: 74,
                    width: double.infinity,
                    child: frequentCategories.when(
                      data: (categories) => ListView.builder(
                        itemCount: categories.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          final category = categories[i];
                          return GestureDetector(
                            onTap: () => _selectParent(category),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.lg,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RoundedIcon(
                                    icon: iconList[category.symbol],
                                    backgroundColor:
                                        categoryColorListTheme[category.color],
                                  ),
                                  Text(
                                    category.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error: $err'),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(
                      left: Sizes.lg,
                      top: Sizes.xxl,
                      bottom: Sizes.sm,
                    ),
                    child: Text(
                      "ALL CATEGORIES",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  categoriesList.when(
                    data: (categories) => Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: ListView.separated(
                        itemCount: categories.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: grey1),
                        itemBuilder: (context, i) {
                          final category = categories[i];
                          final subcategories = ref.watch(
                            subcategoriesProvider(category.id!),
                          );
                          return Column(
                            children: [
                              ListTile(
                                onTap: () => _selectParent(category),
                                leading: RoundedIcon(
                                  icon: iconList[category.symbol],
                                  backgroundColor:
                                      categoryColorListTheme[category.color],
                                ),
                                title: Text(category.name),
                                trailing: _pendingParentId == category.id
                                    ? const Icon(Icons.check)
                                    : null,
                              ),
                              AnimatedCrossFade(
                                crossFadeState: _pendingParentId == category.id
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 150),
                                firstChild: const SizedBox.shrink(),
                                secondChild: subcategories.when(
                                  data: (data) => ListView(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: data
                                        .map(
                                          (subcategory) => ListTile(
                                            contentPadding:
                                                const EdgeInsets.only(
                                                  left: Sizes.xxl,
                                                  right: Sizes.lg,
                                                ),
                                            onTap: () =>
                                                widget.onSelected(subcategory),
                                            leading: RoundedIcon(
                                              icon:
                                                  iconList[subcategory.symbol],
                                              backgroundColor:
                                                  categoryColorListTheme[subcategory
                                                      .color],
                                            ),
                                            title: Text(subcategory.name),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (_, _) => const SizedBox.shrink(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error: $err'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
