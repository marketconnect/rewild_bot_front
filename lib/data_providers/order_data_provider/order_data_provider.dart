import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/order_model.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class OrderDataProvider implements UpdateServiceWeekOrdersDataProvider {
  const OrderDataProvider();

  @override
  Future<Either<RewildError, void>> insertAll(List<OrderModel> orders) async {
    try {
      final box = await Hive.openBox<OrderModel>(HiveBoxes.orders);
      final dateStr = DateTime.now().toIso8601String();

      for (var order in orders) {
        final updatedOrder = order.copyWith(newPeriod: dateStr);
        await box.put(updatedOrder.sku, updatedOrder);
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to insert all orders: ${e.toString()}",
        source: "OrderDataProvider",
        name: "insertAll",
        args: [orders],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> isUpdated(int sku) async {
    try {
      final box = await Hive.openBox<OrderModel>(HiveBoxes.orders);
      final todayStr = DateTime.now().toIso8601String();

      final order = box.get(sku);
      return right(order != null && order.period == todayStr);
    } catch (e) {
      return left(RewildError(
        "Failed to check update status for orders: ${e.toString()}",
        source: "OrderDataProvider",
        name: "isUpdated",
        args: [sku],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteOldOrders() async {
    try {
      final box = await Hive.openBox<OrderModel>(HiveBoxes.orders);
      final oneDayAgo =
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String();

      final keysToDelete = box.keys.where((key) {
        final order = box.get(key);
        return order != null && order.period.compareTo(oneDayAgo) < 0;
      }).toList();

      for (final key in keysToDelete) {
        await box.delete(key);
      }

      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete old orders: ${e.toString()}",
        source: "OrderDataProvider",
        name: "deleteOldOrders",
        args: [],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<OrderModel>>> getAllBySkus(
      List<int> skus) async {
    try {
      final box = await Hive.openBox<OrderModel>(HiveBoxes.orders);
      final orders =
          skus.map((sku) => box.get(sku)).whereType<OrderModel>().toList();
      return right(orders);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve orders by SKUs: ${e.toString()}",
        source: "OrderDataProvider",
        name: "getAllBySkus",
        args: [skus],
        sendToTg: true,
      ));
    }
  }
}
