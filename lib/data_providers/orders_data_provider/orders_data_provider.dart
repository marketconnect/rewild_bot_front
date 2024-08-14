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

  @override
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

  @override
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
        if (cursor != null) {
          await cursor.delete();
        }
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

  @override
  Future<Either<RewildError, List<OrderModel>>> getAllBySkus(
      List<int> skus) async {
    try {
      final db = await _db;
      final txn = db.transaction('orders', idbModeReadOnly);
      final store = txn.objectStore('orders');
      final List<OrderModel> orders = [];

      for (var sku in skus) {
        final range = KeyRange.only(sku); // Corrected from IDBKeyRange.only
        final cursorStream = store.openCursor(range: range);

        await for (final cursor in cursorStream) {
          if (cursor != null) {
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
        }
      }

      await txn.completed;
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
