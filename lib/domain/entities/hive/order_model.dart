import 'package:hive/hive.dart';

part 'order_model.g.dart';

@HiveType(typeId: 12)
class OrderModel extends HiveObject {
  @HiveField(0)
  final int sku;

  @HiveField(1)
  final int warehouse;

  @HiveField(2)
  final int qty;

  @HiveField(3)
  final int price;

  @HiveField(4)
  final String period;

  OrderModel({
    required this.sku,
    required this.warehouse,
    required this.qty,
    required this.price,
    required this.period,
  });

  OrderModel copyWith({
    String? newPeriod,
    int? newSku,
    int? newWarehouse,
    int? newQty,
    int? newPrice,
    String? newPeriods,
    int? newQtySum,
  }) {
    return OrderModel(
      sku: newSku ?? sku,
      warehouse: newWarehouse ?? warehouse,
      qty: newQty ?? qty,
      price: newPrice ?? price,
      period: newPeriod ?? period,
    );
  }
}
