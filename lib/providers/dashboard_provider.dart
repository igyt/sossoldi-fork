import 'package:fl_chart/fl_chart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/database/repositories/transactions_repository.dart';

part 'dashboard_provider.g.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.income,
    required this.expense,
    required this.currentMonth,
    required this.previousMonth,
  });

  final num income;
  final num expense;
  final List<FlSpot> currentMonth;
  final List<FlSpot> previousMonth;

  num get balance => income - expense;
  bool get hasCashFlow => income != 0 || expense != 0;
}

@Riverpod(keepAlive: true)
Future<DashboardSnapshot> dashboard(Ref ref) async {
  final repository = ref.read(transactionsRepositoryProvider);
  final results = await Future.wait([
    repository.currentMonthDailyTransactions(),
    repository.lastMonthDailyTransactions(),
  ]);
  final currentMonth = results[0];
  final previousMonth = results[1];

  final income = currentMonth.fold<num>(
    0,
    (total, row) => total + _number(row['income']),
  );
  final expense = currentMonth.fold<num>(
    0,
    (total, row) => total + _number(row['expense']),
  );

  return DashboardSnapshot(
    income: income,
    expense: expense,
    currentMonth: _toCumulativeSpots(currentMonth),
    previousMonth: _toCumulativeSpots(previousMonth),
  );
}

num _number(Object? value) =>
    value is num ? value : num.tryParse('$value') ?? 0;

List<FlSpot> _toCumulativeSpots(List<dynamic> source) {
  final rows = source.map((row) => Map<String, Object?>.from(row)).toList()
    ..sort((a, b) => '${a['day']}'.compareTo('${b['day']}'));
  double runningTotal = 0;

  return rows
      .map((row) {
        runningTotal += _number(row['income']) - _number(row['expense']);
        final day = DateTime.tryParse('${row['day']}')?.day ?? 1;
        return FlSpot(day - 1.0, double.parse(runningTotal.toStringAsFixed(2)));
      })
      .toList(growable: false);
}
