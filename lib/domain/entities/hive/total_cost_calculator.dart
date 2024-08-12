import 'package:hive/hive.dart';

part 'total_cost_calculator.g.dart';

@HiveType(typeId: 14)
class TotalCostCalculator extends HiveObject {
  @HiveField(0)
  final int nmId;

  @HiveField(1)
  Map<String, double> expenses = {};

  TotalCostCalculator({required this.nmId});

  static const logisticsKey = "l";
  static const priceKey = "p";
  static const returnsKey = "r";
  static const taxKey = "t";
  static const wbCommission = "c";

  void addOrUpdateExpense(String name, double value) {
    expenses[name] = value;
    save(); // Сохраняем изменения в Hive
  }

  void removeExpense(String name) {
    expenses.remove(name);
    save(); // Сохраняем изменения в Hive
  }

  double getTax() {
    return expenses[taxKey] ?? 0.0;
  }

  Map<String, double> getExpenses() {
    Map<String, double> total = {};
    expenses.forEach((key, value) {
      if (key != logisticsKey &&
          key != priceKey &&
          key != returnsKey &&
          key != wbCommission) {
        total[key] = value;
      }
    });
    return total;
  }

  double get totalCost {
    double total = 0.0;
    expenses.forEach((key, value) {
      if (key != logisticsKey &&
          key != priceKey &&
          key != wbCommission &&
          key != returnsKey &&
          key != taxKey) {
        total += value;
      }
    });
    return total;
  }

  double get price {
    return expenses[priceKey] ?? 0.0;
  }

  double grossProfit(int averageLogisticsFromServer) {
    double total = 0.0;
    expenses.forEach((key, value) {
      if (key == priceKey) {
        total += value;
      } else if (key == wbCommission) {
        final price = expenses[priceKey] ?? 0;
        total -= value * price;
      } else if (key == taxKey) {
        final price = expenses[priceKey] ?? 0;
        total -= value * price / 100;
      } else if (key == returnsKey) {
        final returnsInPercent = (expenses[returnsKey] ?? 0) / 100;
        final logisticCost = expenses[logisticsKey] ?? 0;
        final returnsInRub = (returnsInPercent * averageLogisticsFromServer) +
            returnsInPercent * logisticCost;
        total -= returnsInRub;
      } else {
        total -= value;
      }
    });
    return total;
  }

  double get grossProfitWithoutLogistics {
    double total = 0.0;
    expenses.forEach((key, value) {
      if (key == logisticsKey) {
        return;
      }
      if (key != priceKey) {
        total += value;
      }
    });
    return total;
  }

  factory TotalCostCalculator.fromMap(Map<String, dynamic> map) {
    return TotalCostCalculator(
      nmId: map['nmId'],
    )..expenses = Map<String, double>.from(map['expenses']);
  }
}
