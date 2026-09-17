// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';

import '../../../model/transaction.dart';
import '../migration_base.dart';

class ConvertReconciliationsToAdjustments extends Migration {
  ConvertReconciliationsToAdjustments()
    : super(
        version: 8,
        description:
            'Convert Reconciliation income/expense rows to balance adjustments',
      );

  @override
  Future<void> up(Database db) async {
    await db.execute('''
      UPDATE `$transactionTable`
      SET ${TransactionFields.type} = '${TransactionType.adjustment.code}',
          ${TransactionFields.amount} = -${TransactionFields.amount}
      WHERE ${TransactionFields.note} = 'Reconciliation'
        AND ${TransactionFields.type} = '${TransactionType.expense.code}'
    ''');
    await db.execute('''
      UPDATE `$transactionTable`
      SET ${TransactionFields.type} = '${TransactionType.adjustment.code}'
      WHERE ${TransactionFields.note} = 'Reconciliation'
        AND ${TransactionFields.type} = '${TransactionType.income.code}'
    ''');
  }
}
