import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/widgets/transactions_list.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';

class ListTab extends ConsumerWidget {
  const ListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTransactions = ref.watch(transactionsProvider);

    return asyncTransactions.when(
      data: (transactions) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: Sizes.lg,
            bottom: MediaQuery.paddingOf(context).bottom + Sizes.xl,
          ),
          child: TransactionsList(
            margin: EdgeInsets.symmetric(
              horizontal: Sizes.responsiveInsets(context),
            ),
            transactions: transactions,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) {
        return Center(child: Text(stackTrace.toString()));
      },
    );
  }
}
