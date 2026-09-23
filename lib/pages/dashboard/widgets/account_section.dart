import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'accounts_sum.dart';
import '../../../model/bank_account.dart';
import '../../../providers/accounts_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/theme/dashboard_visual_theme.dart';
import '../../../ui/widgets/tonal_glass_surface.dart';

class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountList = ref.watch(activeAccountsProvider);
    final visual = context.dashboardTheme;
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
                        'Accounts',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: visual.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Your balances at a glance',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: visual.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              accountList.when(
                data: (accounts) => _CountBadge(count: accounts.length),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: Sizes.lg),
          accountList.when(
            data: (accounts) => _AccountCollection(
              accounts: accounts,
              onAdd: () {
                ref.read(accountsProvider.notifier).reset();
                Navigator.of(context).pushNamed('/add-account');
              },
            ),
            loading: () => const _AccountsLoading(),
            error: (_, _) => _AccountsError(
              onRetry: () => ref.invalidate(activeAccountsProvider),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCollection extends StatelessWidget {
  const _AccountCollection({required this.accounts, required this.onAdd});

  final List<BankAccount> accounts;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (accounts.isEmpty) {
          final visual = context.dashboardTheme;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'No accounts yet. Add one to start tracking a balance.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: visual.textSecondary),
              ),
              const SizedBox(height: Sizes.sm),
              _AddAccountTile(onTap: onAdd, width: constraints.maxWidth),
            ],
          );
        }
        if (constraints.maxWidth < 520) {
          return SizedBox(
            height: 148,
            child: ListView.separated(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: accounts.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: Sizes.sm),
              itemBuilder: (context, index) => index == accounts.length
                  ? _AddAccountTile(onTap: onAdd, width: 180)
                  : AccountsSum(account: accounts[index], width: 224),
            ),
          );
        }

        const gap = Sizes.sm;
        final tileWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final account in accounts)
              AccountsSum(account: account, width: tileWidth),
            _AddAccountTile(onTap: onAdd, width: tileWidth),
          ],
        );
      },
    );
  }
}

class _AddAccountTile extends StatelessWidget {
  const _AddAccountTile({required this.onTap, required this.width});

  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return SizedBox(
      width: width,
      height: 148,
      child: TonalGlassSurface(
        onTap: onTap,
        semanticLabel: 'Add account',
        radius: 22,
        color: visual.raisedSurface,
        borderColor: visual.glassBorder,
        padding: const EdgeInsets.all(Sizes.md),
        boxShadow: const [],
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: visual.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.add_rounded, color: visual.accent, size: 25),
              ),
              const SizedBox(height: Sizes.sm),
              Text(
                'New account',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: visual.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: visual.raisedSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.sm,
          vertical: Sizes.xs,
        ),
        child: Text(
          '$count',
          style: TextStyle(
            color: visual.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AccountsLoading extends StatelessWidget {
  const _AccountsLoading();

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return Container(
      height: 148,
      decoration: BoxDecoration(
        color: visual.raisedSurface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(child: CircularProgressIndicator(color: visual.accent)),
    );
  }
}

class _AccountsError extends StatelessWidget {
  const _AccountsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final visual = context.dashboardTheme;
    return SizedBox(
      height: 148,
      child: Center(
        child: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(
            'Reload accounts',
            style: TextStyle(color: visual.textSecondary),
          ),
        ),
      ),
    );
  }
}
