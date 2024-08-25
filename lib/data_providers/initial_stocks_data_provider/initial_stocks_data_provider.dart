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
  @override
  Future<Either<RewildError, int>> insert({
    required InitialStockModel initialStockModel,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('initial_stocks', idbModeReadWrite);
      final store = txn.objectStore('initial_stocks');

      // Перед сохранением убедитесь, что ключ существует
      if (initialStockModel.nmIdWhSizeOptionId.isEmpty) {
        return left(RewildError(
          sendToTg: true,
          'Failed to save initial stock: nmIdWhSizeOptionId is empty',
          source: "InitialStockDataProvider",
          name: "insert",
          args: [initialStockModel],
        ));
      }

      await store.put(initialStockModel.toMap());
      await txn.completed;

      return right(1);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Failed to save initial stock: $e',
        source: "InitialStockDataProvider",
        name: "insert",
        args: [initialStockModel],
      ));
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

  @override
  Future<Either<RewildError, List<InitialStockModel>>> getAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('initial_stocks', idbModeReadOnly);
      final store = txn.objectStore('initial_stocks');

      final result = await store.getAll();

      await txn.completed;

      if (result.isEmpty) {
        return right([]);
      }

      final initStocks = result.map((e) {
        return InitialStockModel.fromMap(e as Map<String, dynamic>);
      }).toList();

      return right(initStocks);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to retrieve all initial stocks: $e',
          source: "InitialStockDataProvider",
          name: "getAll",
          args: []));
    }
  }
}
