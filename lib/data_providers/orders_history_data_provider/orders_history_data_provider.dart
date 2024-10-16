import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/domain/entities/orders_history_model.dart';
import 'package:rewild_bot_front/domain/services/orders_history_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class OrdersHistoryDataProvider
    implements
        OrdersHistoryServiceOrdersHistoryDataProvider,
        UpdateServiceOrdersHistoryDataProvider {
  const OrdersHistoryDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, OrdersHistoryModel?>> get({
    required int nmId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('orders_history', idbModeReadOnly);
      final store = txn.objectStore('orders_history');
      final index = store.index('nmId');

      // Получаем все записи с заданным nmId
      final results = await index.getAll(nmId);

      // Преобразуем результат в список Map<String, dynamic>
      final List<Map<String, dynamic>> records =
          results.cast<Map<String, dynamic>>();

      // Фильтруем записи по дате
      final filteredResults = records.where((record) {
        final recordDate = record['updatetAt'] as int;
        return recordDate >= dateFrom.millisecondsSinceEpoch &&
            recordDate <= dateTo.millisecondsSinceEpoch;
      }).toList();

      await txn.completed;

      if (filteredResults.isEmpty) {
        return right(null);
      }

      // Возвращаем первый найденный результат
      return right(OrdersHistoryModel.fromMap(filteredResults.first));
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось получить историю заказов для $nmId: $e',
        source: "OrdersHistoryDataProvider",
        name: "get",
        args: [nmId, dateFrom, dateTo],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> delete(int nmId) async {
    try {
      final db = await _db;
      final txn = db.transaction('orders_history', idbModeReadWrite);
      final store = txn.objectStore('orders_history');

      final index = store.index('nmId');
      final keyRange = KeyRange.only(nmId);

      final cursorStream = index.openCursor(range: keyRange);
      int count = 0;

      await for (final cursor in cursorStream) {
        await cursor.delete();
        count++;
      }

      await txn.completed;
      return right(count);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось удалить историю заказов для $nmId: $e',
        source: "OrdersHistoryDataProvider",
        name: "delete",
        args: [nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> insert(
      OrdersHistoryModel ordersHistory) async {
    try {
      final db = await _db;
      final txn = db.transaction('orders_history', idbModeReadWrite);
      final store = txn.objectStore('orders_history');

      await store.put({
        'nmId': ordersHistory.nmId,
        'qty': ordersHistory.qty,
        'highBuyout': ordersHistory.highBuyout,
        'updatetAt': ordersHistory.updatetAt.millisecondsSinceEpoch,
      });

      await txn.completed;
      return right(ordersHistory.nmId);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось сохранить историю заказов для ${ordersHistory.nmId}: $e',
        source: "OrdersHistoryDataProvider",
        name: "insert",
        args: [ordersHistory],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final db = await _db;

      final txn = db.transaction('orders_history', idbModeReadWrite);
      final store = txn.objectStore('orders_history');

      final allOrdersHistoryRequest = store.clear();

      await allOrdersHistoryRequest;

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
}
