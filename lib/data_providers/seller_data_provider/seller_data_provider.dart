import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/seller_model.dart';

import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/domain/services/all_cards_filter_service.dart';

class SellerDataProvider implements AllCardsFilterServiceSellerDataProvider {
  const SellerDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  Future<Either<RewildError, int>> insert({required SellerModel seller}) async {
    try {
      final db = await _db;
      final txn = db.transaction('sellers', idbModeReadWrite);
      final store = txn.objectStore('sellers');
      await store.put(seller.toMap(), seller.supplierId);
      await txn.completed;
      return right(seller.supplierId);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось сохранить данные продавца $e",
        source: "SellerDataProvider",
        name: 'insert',
        args: [seller],
      ));
    }
  }

  Future<Either<RewildError, void>> delete(int id) async {
    try {
      final db = await _db;
      final txn = db.transaction('sellers', idbModeReadWrite);
      final store = txn.objectStore('sellers');
      await store.delete(id);
      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось удалить данные продавца $e",
        source: "SellerDataPovider",
        name: 'delete',
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, SellerModel?>> get(
      {required int supplierId}) async {
    try {
      final db = await _db;
      final txn = db.transaction('sellers', idbModeReadOnly);
      final store = txn.objectStore('sellers');
      final sellerMap = await store.getObject(supplierId);

      await txn.completed;

      if (sellerMap == null) {
        return right(null);
      }

      // Cast the object to Map<String, dynamic> before passing it to fromMap
      return right(SellerModel.fromMap(sellerMap as Map<String, dynamic>));
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось получить данные продавца $e",
        source: "SellerDataPovider",
        name: "get",
        args: [supplierId],
      ));
    }
  }

  Future<Either<RewildError, int>> update(SellerModel seller) async {
    try {
      final db = await _db;
      final txn = db.transaction('sellers', idbModeReadWrite);
      final store = txn.objectStore('sellers');
      await store.put(seller.toMap(), seller.supplierId);
      await txn.completed;
      return right(seller.supplierId);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось обновить данные продавца $e",
        source: "SellerDataPovider",
        name: 'update',
        args: [seller],
      ));
    }
  }

  Future<Either<RewildError, List<SellerModel>>> getAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('sellers', idbModeReadOnly);
      final store = txn.objectStore('sellers');
      final sellers = await store.getAll();

      await txn.completed;
      return right(sellers
          .map((e) => SellerModel.fromMap(e as Map<String, dynamic>))
          .toList());
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Не удалось получить данные продавцов $e",
        source: "SellerDataPovider",
        name: 'getAll',
        args: [],
      ));
    }
  }
}
