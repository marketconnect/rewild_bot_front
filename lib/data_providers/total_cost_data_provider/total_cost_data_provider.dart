import 'package:fpdart/fpdart.dart';
import 'package:idb_shim/idb.dart';

import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/total_cost_calculator.dart';
import 'package:rewild_bot_front/domain/services/total_cost_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class TotalCostCalculatorDataProvider
    implements
        UpdateServiceTotalCostdataProvider,
        TotalCostServiceTotalCostDataProvider {
  const TotalCostCalculatorDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> addOrUpdateExpense(
      int nmId, String name, double value) async {
    try {
      final db = await _db;
      final txn = db.transaction('total_cost_calculator', idbModeReadWrite);
      final store = txn.objectStore('total_cost_calculator');

      await store.put({
        'nmId': nmId,
        'expenseName': name,
        'expenseValue': value,
        'nmId_expenseName': '${nmId.toString()}_$name',
      });

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to insert expense: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "addOrUpdateExpense",
        args: [nmId, name, value],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll(int nmId) async {
    try {
      final db = await _db;
      final txn = db.transaction('total_cost_calculator', idbModeReadWrite);
      final store = txn.objectStore('total_cost_calculator');
      final index = store.index('nmId');

      final keys = await index.getAllKeys(nmId);

      for (final key in keys) {
        final record = await store.getObject(key);
        final recordMap = record as Map<String, dynamic>;
        final expenseName = recordMap['expenseName'] as String;

        if (![
          TotalCostCalculator.logisticsKey,
          TotalCostCalculator.priceKey,
          TotalCostCalculator.returnsKey,
          TotalCostCalculator.taxKey,
          TotalCostCalculator.wbCommission,
        ].contains(expenseName)) {
          await store.delete(key);
        }
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete specific expenses: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "deleteAll",
        args: [nmId],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> addAll(
      int nmId, Map<String, double> expenses) async {
    try {
      final db = await _db;
      final txn = db.transaction('total_cost_calculator', idbModeReadWrite);
      final store = txn.objectStore('total_cost_calculator');

      for (final expense in expenses.entries) {
        await store.put({
          'nmId': nmId,
          'expenseName': expense.key,
          'expenseValue': expense.value,
          'nmId_expenseName': '${nmId.toString()}_$expense.key',
        });
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to add expenses: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "addAll",
        args: [nmId, expenses],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> removeExpense(int nmId, String name) async {
    try {
      final db = await _db;
      final txn = db.transaction('total_cost_calculator', idbModeReadWrite);
      final store = txn.objectStore('total_cost_calculator');
      final index = store.index('nmId_expenseName');
      final key = await index.getKey("${nmId}_$name");

      if (key != null) {
        await store.delete(key);
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to remove expense: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "removeExpense",
        args: [nmId, name],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<int>>> getAllNmIds() async {
    try {
      final db = await _db;
      final txn = db.transaction('total_cost_calculator', idbModeReadOnly);
      final store = txn.objectStore('total_cost_calculator');

      final costs = await store.getAll();
      await txn.completed;
      final c = costs.map((cost) => cost as Map<String, dynamic>);
      return right(c.map((e) => e['nmId'] as int).toList());
    } catch (e) {
      return left(RewildError(
        "Failed to get nmIds: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "getAllNmIds",
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, TotalCostCalculator>> getTotalCost(
      int nmId) async {
    try {
      final db = await _db;
      final txn = db.transaction('total_cost_calculator', idbModeReadOnly);
      final store = txn.objectStore('total_cost_calculator');
      final index = store.index('nmId');
      final expensesRows = await index.getAll(nmId);

      TotalCostCalculator calculator = TotalCostCalculator(nmId: nmId);
      if (expensesRows.isEmpty) {
        return right(calculator);
      }

      for (final row in expensesRows) {
        final rowMap = row as Map<String, dynamic>;
        calculator.addOrUpdateExpense(
          rowMap['expenseName'] as String,
          rowMap['expenseValue'] as double,
        );
      }

      await txn.completed;
      return right(calculator);
    } catch (e) {
      return left(RewildError(
        "Failed to get total cost: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "getTotalCost",
        args: [nmId],
        sendToTg: true,
      ));
    }
  }
}
