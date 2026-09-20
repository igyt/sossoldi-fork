import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/style.dart';
import '../../../../providers/transactions_provider.dart';
import '../../../../ui/device.dart';

class PeopleConcernedSelector extends ConsumerStatefulWidget {
  const PeopleConcernedSelector({super.key});

  @override
  ConsumerState<PeopleConcernedSelector> createState() =>
      _PeopleConcernedSelectorState();
}

class _PeopleConcernedSelectorState
    extends ConsumerState<PeopleConcernedSelector> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = ref.read(selectedPeopleConcernedProvider);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Sizes.xl,
          Sizes.lg,
          Sizes.xl,
          Sizes.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'People concerned',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Sizes.sm),
            Text(
              'Your cost will be the payment total divided equally.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: Sizes.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CounterButton(
                  icon: Icons.remove,
                  onPressed: _value > 1 ? () => setState(() => _value--) : null,
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    '$_value',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                _CounterButton(
                  icon: Icons.add,
                  onPressed: () => setState(() => _value++),
                ),
              ],
            ),
            const SizedBox(height: Sizes.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref
                      .read(selectedPeopleConcernedProvider.notifier)
                      .setValue(_value);
                  Navigator.pop(context);
                },
                child: const Text('DONE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: white,
        disabledBackgroundColor: Theme.of(
          context,
        ).colorScheme.secondary.withValues(alpha: 0.35),
      ),
    );
  }
}
