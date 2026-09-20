// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';

import '../../../model/recurring_transaction.dart';
import '../../../model/transaction.dart';
import '../migration_base.dart';

class AddPeopleConcerned extends Migration {
  AddPeopleConcerned()
    : super(version: 10, description: 'Add people concerned to transactions');

  @override
  Future<void> up(Database db) async {
    await db.execute('''
      ALTER TABLE `$transactionTable`
      ADD COLUMN `${TransactionFields.peopleConcerned}`
      INTEGER NOT NULL DEFAULT 1
      CHECK (`${TransactionFields.peopleConcerned}` >= 1)
    ''');
    await db.execute('''
      ALTER TABLE `$recurringTransactionTable`
      ADD COLUMN `${RecurringTransactionFields.peopleConcerned}`
      INTEGER NOT NULL DEFAULT 1
      CHECK (`${RecurringTransactionFields.peopleConcerned}` >= 1)
    ''');
  }
}
