import 'package:fpdart/fpdart.dart';
import 'package:idb_shim/idb.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/domain/entities/supply_model.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/supply_service.dart';

import 'package:rewild_bot_front/domain/services/update_service.dart';

class SupplyDataProvider
    implements
        SupplyServiceSupplyDataProvider,
        UpdateServiceSupplyDataProvider,
        CardOfProductServiceSupplyDataProvider {
  const SupplyDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, int>> insert({required SupplyModel supply}) async {
    try {
      final db = await _db;
      final txn = db.transaction('supplies', idbModeReadWrite);
      final store = txn.objectStore('supplies');

      final existingKey = await store.index('nmId_wh_sizeOptionId').getKey(
        [supply.nmId, supply.wh, supply.sizeOptionId],
      );

      if (existingKey != null) {
        await store.delete(existingKey);
      }

      await store.put(supply.toMap());

      await txn.completed;
      return right(0);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Не удалось сохранить поставки $e',
          source: "SupplyDataProvider",
          name: "insert",
          args: [supply]));
    }
  }

  @override
  Future<Either<RewildError, void>> delete({
    required int nmId,
    int? wh,
    int? sizeOptionId,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('supplies', idbModeReadWrite);
      final store = txn.objectStore('supplies');

      final key = _generateSupplyKey(nmId, wh, sizeOptionId);

      await store.delete(key);
      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Не удалось удалить поставки $e',
          source: "SupplyDataProvider",
          name: "delete",
          args: [nmId]));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('supplies', idbModeReadWrite);
      final store = txn.objectStore('supplies');

      await store.clear();
      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Не удалось удалить поставки $e',
          source: "SupplyDataProvider",
          name: "deleteAll",
          args: []));
    }
  }

  @override
  Future<Either<RewildError, SupplyModel?>> getOne({
    required int nmId,
    required int wh,
    required int sizeOptionId,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('supplies', idbModeReadOnly);
      final store = txn.objectStore('supplies');

      final key = _generateSupplyKey(nmId, wh, sizeOptionId);

      final result = await store.getObject(key) as Map<String, dynamic>?;
      await txn.completed;

      if (result == null) {
        return right(null);
      }
      return right(SupplyModel.fromMap(result));
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Не удалось получить поставки: $e',
          source: "SupplyDataProvider",
          name: "getOne",
          args: [nmId, wh, sizeOptionId]));
    }
  }

  @override
  Future<Either<RewildError, List<SupplyModel>?>> getForOne({
    required int nmId,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('supplies', idbModeReadOnly);
      final store = txn.objectStore('supplies');

      final result = await store.getAll();
      await txn.completed;

      final supplies = result
          .map((item) => SupplyModel.fromMap(item as Map<String, dynamic>))
          .where((supply) => supply.nmId == nmId)
          .toList();

      if (supplies.isEmpty) {
        return right(null);
      }

      return right(supplies);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Не удалось получить поставки: $e',
          source: "SupplyDataProvider",
          name: "getForOne",
          args: [nmId]));
    }
  }

  @override
  Future<Either<RewildError, List<SupplyModel>>> get({
    required int nmId,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('supplies', idbModeReadOnly);
      final store = txn.objectStore('supplies');

      final result = await store.getAll();
      await txn.completed;

      final supplies = result
          .map((item) => SupplyModel.fromMap(item as Map<String, dynamic>))
          .where((supply) => supply.nmId == nmId)
          .toList();

      return right(supplies);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          'Не удалось получить поставки $e',
          source: "SupplyDataProvider",
          name: "get",
          args: [nmId]));
    }
  }

  String _generateSupplyKey(int nmId, int? wh, int? sizeOptionId) {
    return '$nmId-${wh ?? ''}-${sizeOptionId ?? ''}';
  }
}
