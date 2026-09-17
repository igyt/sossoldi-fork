// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';

import '../migration_base.dart';
import '0008_reconciliation_adjustments.dart';

class ReapplyReconciliationAdjustments extends Migration {
  ReapplyReconciliationAdjustments()
    : super(
        version: 9,
        description:
            'Re-convert Reconciliation income/expense rows after CSV restore',
      );

  @override
  Future<void> up(Database db) => ConvertReconciliationsToAdjustments.apply(db);
}
