class TotalCostCalculator {
  final int nmId;

  TotalCostCalculator({required this.nmId});
  Map<String, double> expenses = {};

  static const logisticsKey = "l";
  static const priceKey = "p";
  static const returnsKey = "r";
  static const taxKey = "t";
  static const wbCommission = "c";

  void addOrUpdateExpense(String name, double value) {
    expenses[name] = value;
  }

  void removeExpense(String name) {
    expenses.remove(name);
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
              key != wbCommission
          // && key != taxKey
          ) {
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
      // total = total.ceil().toDouble();
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
    );
  }
}
