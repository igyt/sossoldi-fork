import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/category_transaction.dart';
import '../../providers/categories_provider.dart';
import '../../providers/transactions_provider.dart';
import 'segmented_pill.dart';

class CategoryTypeButton extends ConsumerWidget {
  const CategoryTypeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryType = ref.watch(categoryTypeProvider);

    void onTap(CategoryTransactionType type) {
      ref.invalidate(totalAmountProvider);
      ref.read(categoryTypeProvider.notifier).setType(type);
      ref.read(selectedCategoryProvider.notifier).setCategory(null);
    }

    return SegmentedPill<CategoryTransactionType>(
      options: const {
        CategoryTransactionType.income: 'Income',
        CategoryTransactionType.expense: 'Expenses',
      },
      selected: categoryType == CategoryTransactionType.income
          ? CategoryTransactionType.income
          : CategoryTransactionType.expense,
      onChanged: onTap,
    );
  }
}
