import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CardOfProductDataProvider
    implements
        UpdateServiceCardOfProductDataProvider,
        CardOfProductServiceCardOfProductDataProvider {
  const CardOfProductDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, List<int>>> getAllNmIds() async {
    try {
      final db = await _db;
      final txn = db.transaction('cards', idbModeReadOnly);
      final store = txn.objectStore('cards');
      final result = await store.getAllKeys();

      await txn.completed;

      return right(result.map((e) => e as int).toList());
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getAllNmIds",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> insertOrUpdate(
      {required CardOfProductModel card}) async {
    try {
      final db = await _db;
      final txn = db.transaction('cards', idbModeReadWrite);
      final store = txn.objectStore('cards');

      final existingCard = await store.getObject(card.nmId);

      if (existingCard != null) {
        await store.put(card.toMap());
      } else {
        await store.add(card.toMap(), card.nmId);
      }

      await txn.completed;

      return right(card.nmId);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Failed to insert or update card: ${e.toString()}',
        source: runtimeType.toString(),
        name: "insertOrUpdate",
        args: [card],
      ));
    }
  }

  @override
  Future<Either<RewildError, String>> getImage({required int id}) async {
    try {
      final db = await _db;
      final txn = db.transaction('cards', idbModeReadOnly);
      final store = txn.objectStore('cards');
      final card = await store.getObject(id);

      await txn.completed;

      if (card == null) {
        return right("");
      }

      return right((card as Map<String, dynamic>)['img'] as String);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getImage",
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> delete({required int id}) async {
    try {
      final db = await _db;
      final txn = db.transaction('cards', idbModeReadWrite);
      final store = txn.objectStore('cards');
      await store.delete(id);

      await txn.completed;

      return right(id);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "delete",
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, CardOfProductModel?>> get(
      {required int nmId}) async {
    try {
      final db = await _db;
      final txn = db.transaction('cards', idbModeReadOnly);
      final store = txn.objectStore('cards');
      final card = await store.getObject(nmId);

      await txn.completed;

      if (card == null) {
        return right(null);
      }

      return right(CardOfProductModel.fromMap(card as Map<String, dynamic>));
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "get",
        args: [nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]) async {
    try {
      final db = await _db;
      final txn = db.transaction('cards', idbModeReadOnly);
      final store = txn.objectStore('cards');
      List<Map<String, dynamic>> cards = [];

      if (nmIds != null) {
        for (var nmId in nmIds) {
          final card = await store.getObject(nmId);
          if (card != null) {
            cards.add(card as Map<String, dynamic>);
          }
        }
      } else {
        final result = await store.getAll();
        cards = result.map((e) => e as Map<String, dynamic>).toList();
      }

      await txn.completed;

      return right(cards.map((e) => CardOfProductModel.fromMap(e)).toList());
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Failed to retrieve cards: ${e.toString()}',
        source: runtimeType.toString(),
        name: "getAll",
        args: [nmIds],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<CardOfProductModel>>> getAllBySupplierId(
      {required int supplierId}) async {
    try {
      final db = await _db;
      final txn = db.transaction('cards', idbModeReadOnly);
      final store = txn.objectStore('cards');
      final result = await store.getAll();

      await txn.completed;

      final cards = result
          .map((e) => e as Map<String, dynamic>)
          .where((card) => card['supplierId'] == supplierId)
          .map((e) => CardOfProductModel.fromMap(e))
          .toList();

      return right(cards);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Failed to retrieve cards by supplierId: ${e.toString()}',
        source: runtimeType.toString(),
        name: "getAllBySupplierId",
        args: [supplierId],
      ));
    }
  }
}
