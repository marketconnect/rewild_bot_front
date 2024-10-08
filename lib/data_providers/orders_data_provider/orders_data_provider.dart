import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';

import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/order_model.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';
import 'package:rewild_bot_front/domain/services/week_orders_service.dart';

class OrderDataProvider
    implements
        UpdateServiceWeekOrdersDataProvider,
        WeekOrdersServiceOrdersDataProvider {
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
          'skuWarehousePeriod': order.skuWarehousePeriod,
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

      // Создаем запрос по индексу `sku`
      final index = store.index('sku');
      final keyRange = KeyRange.only(skus);
      final query = index.openCursor(range: keyRange);

      bool isUpdated = false;
      await for (var cursor in query) {
        final value = cursor.value as Map<String, dynamic>;
        final updatedAt = value['updatedAt'];
        if (updatedAt == todayStr) {
          isUpdated = true;
          break;
        }
        cursor.next();
      }

      await txn.completed;
      return right(isUpdated);
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
  Future<Either<RewildError, void>> deleteAllOrders() async {
    try {
      final db = await _db;

      final txn = db.transaction('orders', idbModeReadWrite);
      final store = txn.objectStore('orders');

      final allOrdersRequest = store.clear();

      await allOrdersRequest;

      await txn.completed;

      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete all orders: ${e.toString()}",
        source: "OrderDataProvider",
        name: "deleteAllOrders",
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

  @override
  Future<Either<RewildError, List<OrderModel>>> getAllBySkus(
      List<int> skus) async {
    try {
      final db = await _db;
      final txn = db.transaction('orders', idbModeReadOnly);
      final store = txn.objectStore('orders');
      final List<OrderModel> orders = [];

      for (var sku in skus) {
        final index = store.index('sku');
        final cursorStream = index.openCursor(range: KeyRange.only(sku));

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
