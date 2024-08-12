import 'package:hive/hive.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/total_cost_calculator.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class TotalCostCalculatorDataProvider
    implements UpdateServiceTotalCostdataProvider {
  const TotalCostCalculatorDataProvider();

  Future<Box<TotalCostCalculator>> _openBox() async {
    return await Hive.openBox<TotalCostCalculator>(HiveBoxes.totalCosts);
  }

  @override
  Future<Either<RewildError, void>> addOrUpdateExpense(
      int nmId, String name, double value) async {
    try {
      final box = await _openBox();
      final calculator = box.get(nmId) ?? TotalCostCalculator(nmId: nmId);
      calculator.addOrUpdateExpense(name, value);
      await box.put(nmId, calculator);
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to insert expense: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "addOrUpdateExpense",
        args: [nmId, name, value],
        sendToTg: false,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll(int nmId) async {
    try {
      final box = await _openBox();
      final calculator = box.get(nmId);
      if (calculator != null) {
        calculator.expenses.removeWhere((key, value) =>
            key != TotalCostCalculator.logisticsKey &&
            key != TotalCostCalculator.priceKey &&
            key != TotalCostCalculator.returnsKey &&
            key != TotalCostCalculator.taxKey &&
            key != TotalCostCalculator.wbCommission);
        await calculator.save();
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete specific expenses: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "deleteAll",
        args: [nmId],
        sendToTg: false,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> addAll(
      int nmId, Map<String, double> expenses) async {
    try {
      final box = await _openBox();
      final calculator = box.get(nmId) ?? TotalCostCalculator(nmId: nmId);
      for (final expense in expenses.entries) {
        calculator.addOrUpdateExpense(expense.key, expense.value);
      }
      await box.put(nmId, calculator);
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to add expenses: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "addAll",
        args: [nmId, expenses],
        sendToTg: false,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> removeExpense(int nmId, String name) async {
    try {
      final box = await _openBox();
      final calculator = box.get(nmId);
      if (calculator != null) {
        calculator.removeExpense(name);
        await calculator.save();
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to remove expense: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "removeExpense",
        args: [nmId, name],
        sendToTg: false,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<int>>> getAllNmIds() async {
    try {
      final box = await _openBox();
      return right(box.keys.cast<int>().toList());
    } catch (e) {
      return left(RewildError(
        "Failed to get nmIds: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "getAllNmIds",
        sendToTg: false,
      ));
    }
  }

  @override
  Future<Either<RewildError, TotalCostCalculator>> getTotalCost(
      int nmId) async {
    try {
      final box = await _openBox();
      final calculator = box.get(nmId) ?? TotalCostCalculator(nmId: nmId);
      return right(calculator);
    } catch (e) {
      return left(RewildError(
        "Failed to get total cost: $e",
        source: "TotalCostCalculatorDataProvider",
        name: "getTotalCost",
        args: [nmId],
        sendToTg: false,
      ));
    }
  }
}
