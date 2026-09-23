import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../model/bank_account.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../../ui/theme/dashboard_visual_theme.dart';
import '../../../ui/widgets/blur_widget.dart';
import '../../../ui/widgets/tonal_glass_surface.dart';

class AccountsSum extends ConsumerWidget {
  const AccountsSum({required this.account, this.width, super.key});

  final BankAccount account;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyStateProvider);
    final visual = context.dashboardTheme;
    final accent =
        accountColorListTheme[account.color.clamp(
          0,
          accountColorListTheme.length - 1,
        )];

    return SizedBox(
      width: width,
      height: 148,
      child: TonalGlassSurface(
        onTap: () async {
          await ref
              .read(accountsProvider.notifier)
              .refreshAccount(account)
              .whenComplete(() {
                if (context.mounted) {
                  Navigator.of(context).pushNamed('/account');
                }
              });
        },
        semanticLabel: '${account.name} account',
        radius: 22,
        color: Color.alphaBlend(
          accent.withValues(alpha: 0.12),
          visual.raisedSurface,
        ),
        borderColor: accent.withValues(alpha: 0.24),
        padding: const EdgeInsets.all(Sizes.md),
        boxShadow: const [],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    accountIconList[account.symbol] ??
                        Icons.account_balance_wallet_outlined,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: Sizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: visual.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (account.mainAccount)
                        Text(
                          'Primary account',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: visual.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 18,
                  color: visual.textSecondary,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available balance',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: visual.textSecondary),
                ),
                const SizedBox(height: 2),
                BlurWidget(
                  sigma: 16,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${(account.total ?? 0).toCurrency()} ${currency.symbol}',
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: visual.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
