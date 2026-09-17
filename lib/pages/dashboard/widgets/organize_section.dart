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
import '../../../ui/widgets/default_container.dart';
import '../../../ui/widgets/rounded_icon.dart';

class OrganizeSection extends ConsumerWidget {
  const OrganizeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(organizeQueueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Sizes.lg,
            Sizes.xxl,
            Sizes.lg,
            Sizes.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "Organize",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              queue.when(
                data: (data) => data.total == 0
                    ? const SizedBox.shrink()
                    : Text(
                        data.total > 10
                            ? "10 of ${data.total}"
                            : "${data.total} left",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        queue.when(
          data: (data) {
            if (data.items.isEmpty) {
              return DefaultContainer(
                child: Text(
                  "Nothing left to classify",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final transaction in data.items)
                  _OrganizeTile(
                    key: ValueKey(transaction.id),
                    transaction: transaction,
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(Sizes.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(Sizes.lg),
            child: Text('Error: $err'),
          ),
        ),
        const SizedBox(height: Sizes.xxl),
      ],
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

  Transaction get transaction => widget.transaction;

  CategoryTransactionType? get _categoryType => transaction.type.categoryType;

  Future<void> _assign(CategoryTransaction category) async {
    if (_busy || category.id == null) return;
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
            _assign(category);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyStateProvider);
    final frequent = ref.watch(frequentCategoriesProvider(_categoryType));
    final signedAmount = transaction.type == TransactionType.expense
        ? "-${transaction.amount.toCurrency()}"
        : transaction.amount.toCurrency();
    final label = (transaction.note?.isEmpty ?? true)
        ? DateFormat("dd MMM").format(transaction.date)
        : transaction.note!;

    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.md),
      child: DefaultContainer(
        padding: const EdgeInsets.all(Sizes.md),
        child: Opacity(
          opacity: _busy ? 0.5 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          "${DateFormat("dd MMM yyyy").format(transaction.date)}"
                          "${transaction.bankAccountName != null ? " · ${transaction.bankAccountName}" : ""}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "$signedAmount${currency.symbol}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: transaction.type.toColor(
                        brightness: Theme.of(context).brightness,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sizes.md),
              frequent.when(
                data: (categories) => SizedBox(
                  height: 72,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final category in categories)
                        _CategoryChip(
                          category: category,
                          onTap: _busy ? null : () => _assign(category),
                        ),
                      _AllCategoriesChip(onTap: _busy ? null : _openSheet),
                    ],
                  ),
                ),
                loading: () => const SizedBox(height: 72),
                error: (_, _) => TextButton(
                  onPressed: _busy ? null : _openSheet,
                  child: const Text("Choose category"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onTap});

  final CategoryTransaction category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Sizes.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoundedIcon(
                icon: iconList[category.symbol],
                backgroundColor: categoryColorListTheme[category.color],
                size: 18,
                padding: const EdgeInsets.all(Sizes.sm),
              ),
              const SizedBox(height: Sizes.xxs),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllCategoriesChip extends StatelessWidget {
  const _AllCategoriesChip({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Sizes.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoundedIcon(
                icon: Icons.more_horiz,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                size: 18,
                padding: const EdgeInsets.all(Sizes.sm),
              ),
              const SizedBox(height: Sizes.xxs),
              Text(
                "All",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrganizeCategorySheet extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryType = type.categoryType;
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
              controller: scrollController,
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
                            onTap: () => onSelected(category),
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
                                onTap: () => onSelected(category),
                                leading: RoundedIcon(
                                  icon: iconList[category.symbol],
                                  backgroundColor:
                                      categoryColorListTheme[category.color],
                                ),
                                title: Text(category.name),
                              ),
                              subcategories.when(
                                data: (data) => Column(
                                  children: data
                                      .map(
                                        (subcategory) => ListTile(
                                          contentPadding:
                                              const EdgeInsets.only(
                                            left: Sizes.xxl,
                                            right: Sizes.lg,
                                          ),
                                          onTap: () => onSelected(subcategory),
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
                                loading: () => const SizedBox.shrink(),
                                error: (_, _) => const SizedBox.shrink(),
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
