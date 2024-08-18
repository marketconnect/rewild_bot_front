import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/database_helper.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/initial_stock_model.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/init_stock_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class InitialStockDataProvider
    implements
        UpdateServiceInitStockDataProvider,
        InitStockServiceInitStockDataProvider,
        CardOfProductServiceInitStockDataProvider {
  const InitialStockDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, int>> insert(
      {required InitialStockModel initialStockModel}) async {
    try {
      final db = await _db;
      final txn = db.transaction('initial_stocks', idbModeReadWrite);
      final store = txn.objectStore('initial_stocks');

      await store.put(
        initialStockModel.toMap(),
      );

      await txn.completed;
      return right(initialStockModel.id);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to save initial stock: $e',
          source: "InitialStockDataProvider",
          name: "insert",
          args: [initialStockModel]));
    }
  }

  static Future<Either<RewildError, int>> insertInBackground(
      {required InitialStockModel initialStock}) async {
    try {
      final db = await DatabaseHelper().database;
      final txn = db.transaction('initial_stocks', idbModeReadWrite);
      final store = txn.objectStore('initial_stocks');

      await store.add(initialStock.toMap(), initialStock.id);

      await txn.completed;
      return right(initialStock.id);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to save initial stock in background: $e',
          source: "InitialStockDataProvider",
          name: "insertInBackground",
          args: [initialStock]));
    }
  }

  Future<Either<RewildError, void>> delete({required int id}) async {
    try {
      final db = await _db;
      final txn = db.transaction('initial_stocks', idbModeReadWrite);
      final store = txn.objectStore('initial_stocks');

      await store.delete(id);

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to delete initial stock: $e',
          source: "InitialStockDataProvider",
          name: "delete",
          args: [id]));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('initial_stocks', idbModeReadWrite);
      final store = txn.objectStore('initial_stocks');

      await store.clear();

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to delete all initial stocks: $e',
          source: "InitialStockDataProvider",
          name: "deleteAll",
          args: []));
    }
  }

  @override
  Future<Either<RewildError, List<InitialStockModel>>> get({
    required int nmId,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('initial_stocks', idbModeReadOnly);
      final store = txn.objectStore('initial_stocks');

      final result = await store.index('nmId_date').getAll(KeyRange.bound(
            [nmId, dateFrom.millisecondsSinceEpoch],
            [nmId, dateTo.millisecondsSinceEpoch],
          ));

      await txn.completed;

      final initStocks = result
          .map((e) => InitialStockModel.fromMap(e as Map<String, dynamic>))
          .toList();
      return right(initStocks);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to retrieve initial stocks: $e',
          source: "InitialStockDataProvider",
          name: "get",
          args: [nmId, dateFrom, dateTo]));
    }
  }

  @override
  Future<Either<RewildError, InitialStockModel?>> getOne({
    required int nmId,
    required DateTime dateFrom,
    required DateTime dateTo,
    required int wh,
    required int sizeOptionId,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('initial_stocks', idbModeReadOnly);
      final store = txn.objectStore('initial_stocks');

      final result =
          await store.index('nmId_wh_size_date').getAll(KeyRange.bound(
                [nmId, wh, sizeOptionId, dateFrom.millisecondsSinceEpoch],
                [nmId, wh, sizeOptionId, dateTo.millisecondsSinceEpoch],
              ));

      await txn.completed;

      if (result.isEmpty) {
        return right(null);
      }

      return right(
          InitialStockModel.fromMap(result.first as Map<String, dynamic>));
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to retrieve initial stock: $e',
          source: "InitialStockDataProvider",
          name: "getOne",
          args: [nmId, dateFrom, dateTo, wh, sizeOptionId]));
    }
  }

  Future<Either<RewildError, int>> update(
      {required InitialStockModel initialStock}) async {
    try {
      final db = await _db;
      final txn = db.transaction('initial_stocks', idbModeReadWrite);
      final store = txn.objectStore('initial_stocks');

      await store.put(initialStock.toMap(), initialStock.id);

      await txn.completed;
      return right(initialStock.id);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to update initial stock: $e',
          source: "InitialStockDataProvider",
          name: "update",
          args: [initialStock]));
    }
  }

  @override
  Future<Either<RewildError, List<InitialStockModel>>> getAll({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('initial_stocks', idbModeReadOnly);
      final store = txn.objectStore('initial_stocks');

      final result = await store.getAll(KeyRange.bound(
        dateFrom.millisecondsSinceEpoch,
        dateTo.millisecondsSinceEpoch,
      ));

      await txn.completed;

      final initStocks = result
          .map((e) => InitialStockModel.fromMap(e as Map<String, dynamic>))
          .toList();
      return right(initStocks);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to retrieve all initial stocks: $e',
          source: "InitialStockDataProvider",
          name: "getAll",
          args: [dateFrom, dateTo]));
    }
  }
}
