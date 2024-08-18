import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/stocks_model.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/stock_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class StockDataProvider
    implements
        UpdateServiceStockDataProvider,
        StockServiceStocksDataProvider,
        CardOfProductServiceStockDataProvider {
  const StockDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  @override
  Future<Either<RewildError, int>> insert({required StocksModel stock}) async {
    try {
      final db = await _db;
      final txn = db.transaction('stocks', idbModeReadWrite);
      final store = txn.objectStore('stocks');

      await store.put(stock.toMap());

      await txn.completed;
      return right(stock.nmId);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Failed to save stock: $e',
        source: "StockDataProvider",
        name: "insert",
        args: [stock],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> delete(int nmId) async {
    try {
      final db = await _db;
      final txn = db.transaction('stocks', idbModeReadWrite);
      final store = txn.objectStore('stocks');

      await store.delete(nmId);

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to delete stock: $e',
          source: "StockDataProvider",
          name: "delete",
          args: [nmId]));
    }
  }

  @override
  Future<Either<RewildError, List<StocksModel>>> get(
      {required int nmId}) async {
    try {
      final db = await _db;
      final txn = db.transaction('stocks', idbModeReadOnly);
      final store = txn.objectStore('stocks');

      final result = await store.getObject(nmId);

      await txn.completed;

      if (result == null) {
        return right([]);
      }

      return right([StocksModel.fromMap(result as Map<String, dynamic>)]);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to retrieve stock: $e',
          source: "StockDataProvider",
          name: "get",
          args: [nmId]));
    }
  }

  @override
  Future<Either<RewildError, StocksModel>> getOne({
    required int nmId,
    required int wh,
    required int sizeOptionId,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('stocks', idbModeReadOnly);
      final store = txn.objectStore('stocks');

      final index = store.index('nmId_wh_sizeOptionId');
      final result = await index.get(KeyRange.only([nmId, wh, sizeOptionId]));

      await txn.completed;

      if (result == null) {
        return left(RewildError(
            sendToTg: true,
            'Stock not found',
            source: "StockDataProvider",
            name: "getOne",
            args: [nmId, wh, sizeOptionId]));
      }

      return right(StocksModel.fromMap(result as Map<String, dynamic>));
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to retrieve stock: $e',
          source: "StockDataProvider",
          name: "getOne",
          args: [nmId, wh, sizeOptionId]));
    }
  }

  Future<Either<RewildError, int>> update({
    required StocksModel stock,
    required int nmId,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('stocks', idbModeReadWrite);
      final store = txn.objectStore('stocks');

      await store.put(stock.toMap(), nmId);

      await txn.completed;
      return right(nmId);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to update stock: $e',
          source: "StockDataProvider",
          name: "update",
          args: [stock, nmId]));
    }
  }

  @override
  Future<Either<RewildError, List<StocksModel>>> getAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('stocks', idbModeReadOnly);
      final store = txn.objectStore('stocks');

      final result = await store.getAll();

      await txn.completed;

      if (result.isEmpty) {
        return right([]);
      }

      final stocks = result
          .map((e) => StocksModel.fromMap(e as Map<String, dynamic>))
          .toList();

      return right(stocks);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to retrieve all stocks: $e',
          source: "StockDataProvider",
          name: "getAll",
          args: []));
    }
  }

  Future<Either<RewildError, List<StocksModel>>> getAllByWh(String wh) async {
    try {
      final db = await _db;
      final txn = db.transaction('stocks', idbModeReadOnly);
      final store = txn.objectStore('stocks');

      final index = store.index('wh');
      final result = await index.getAll(KeyRange.only(wh));

      await txn.completed;

      final stocks = result
          .map((e) => StocksModel.fromMap(e as Map<String, dynamic>))
          .toList();

      return right(stocks);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Failed to retrieve stocks by warehouse: $e',
          source: "StockDataProvider",
          name: "getAllByWh",
          args: [wh]));
    }
  }
}
