import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/transactions_provider.dart';
import '../../../ui/assets.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/accent_button.dart';
import '../../../ui/widgets/default_container.dart';

class AddTransactionCard extends ConsumerWidget {
  const AddTransactionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.topCenter,
      child: DefaultContainer(
        margin: EdgeInsets.symmetric(
          horizontal: Sizes.responsiveInsets(context),
          vertical: Sizes.lg,
        ),
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "There are no transactions added yet",
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Image.asset(SossoldiAssets.calculator, width: 240, height: 240),
            Text(
              "Add a transaction to make this section more appealing",
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            AccentButton(
              label: "Add transaction",
              onPressed: () {
                ref.read(transactionsProvider.notifier).reset();
                Navigator.of(context).pushNamed("/add-page");
              },
            ),
          ],
        ),
      ),
    );
  }
}
