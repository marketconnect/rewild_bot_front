import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';

import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/order_model.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class OrderDataProvider implements UpdateServiceWeekOrdersDataProvider {
  const OrderDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  Future<Either<RewildError, void>> insertAll(List<OrderModel> orders) async {
    try {
      final db = await _db;
      final txn = db.transaction('orders', idbModeReadWrite);
      final store = txn.objectStore('orders');
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var order in orders) {
        await store.put({
          'sku': order.sku,
          'warehouse': order.warehouse,
          'qty': order.qty,
          'price': order.price,
          'period': order.period,
          'updatedAt': dateStr,
        });
      }

      await txn.completed;
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

  Future<Either<RewildError, bool>> isUpdated(int skus) async {
    try {
      final db = await _db;
      final txn = db.transaction('orders', idbModeReadOnly);
      final store = txn.objectStore('orders');
      final dateFormat = DateFormat('yyyy-MM-dd');
      final todayStr = dateFormat.format(DateTime.now());

      final result =
          await store.getObject({'sku': skus, 'updatedAt': todayStr});

      await txn.completed;
      return right(result != null);
    } catch (e) {
      return left(RewildError(
        "Failed to check update status for orders: ${e.toString()}",
        source: "OrderDataProvider",
        name: "isUpdated",
        args: [skus],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteOldOrders() async {
    try {
      final db = await _db;
      final txn = db.transaction('orders', idbModeReadWrite);
      final store = txn.objectStore('orders');
      final oneDayAgoStr = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));

      // Assuming 'updatedAt' is indexed
      final index = store.index('updatedAt');

      // Opening a cursor within the specified range
      final keyRange = KeyRange.upperBound(oneDayAgoStr, true);

      final cursorStream = index.openCursor(range: keyRange);

      await for (final cursor in cursorStream) {
        await cursor.delete();
      }

      await txn.completed;
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

  Future<Either<RewildError, List<OrderModel>>> getAllBySkuAndPeriod(
      int sku, String period) async {
    try {
      final db = await _db;
      final txn = db.transaction('orders', idbModeReadOnly);
      final store = txn.objectStore('orders');

      // Use a KeyRange.bound for warehouse ignored
      final index = store.index('sku_warehouse_period');
      final range = KeyRange.bound(
        [sku, 0, period], // lower bound
        [sku, double.infinity, period], // upper bound
      );

      final cursorStream = index.openCursor(range: range);
      final List<OrderModel> orders = [];

      await for (final cursor in cursorStream) {
        final result = cursor.value as Map<String, dynamic>;
        orders.add(OrderModel(
          sku: result['sku'] as int,
          warehouse: result['warehouse'] as int,
          qty: result['qty'] as int,
          price: result['price'] as int,
          period: result['period'] as String,
        ));
        cursor.next();
      }

      await txn.completed;
      return right(orders);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve orders by SKU and period: ${e.toString()}",
        source: "OrderDataProvider",
        name: "getAllBySkuAndPeriod",
        args: [sku, period],
        sendToTg: true,
      ));
    }
  }
}
