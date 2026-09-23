import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/transaction.dart';
import '../../providers/transactions_provider.dart';
import 'segmented_pill.dart';

class TransactionTypeButton extends ConsumerWidget {
  const TransactionTypeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionType = ref.watch(selectedTransactionTypeProvider);
    // Reset index for categories and accounts when transactions type changes
    ref.listen(selectedTransactionTypeProvider, (previous, next) {
      ref.invalidate(selectedListIndexProvider);
    });
    return SegmentedPill<TransactionType>(
      options: const {
        TransactionType.income: 'Income',
        TransactionType.expense: 'Expenses',
      },
      selected: transactionType == TransactionType.income
          ? TransactionType.income
          : TransactionType.expense,
      onChanged: (type) =>
          ref.read(selectedTransactionTypeProvider.notifier).setType(type),
    );
  }
}
