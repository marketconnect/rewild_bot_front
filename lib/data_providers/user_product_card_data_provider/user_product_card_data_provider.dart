import 'package:fpdart/fpdart.dart';
import 'package:idb_shim/idb.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/user_product_card.dart';
import 'package:rewild_bot_front/domain/services/user_product_card_service.dart';

class UserProductCardDataProvider
    implements UserProductCardServiceDataProvider {
  const UserProductCardDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> addProductCard({
    required UserProductCard productCard,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('product_cards', idbModeReadWrite);
      final store = txn.objectStore('product_cards');

      await store.put(productCard.toMap());

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to add product card: $e",
        source: "UserProductCardDataProvider",
        name: "addProductCard",
        args: [productCard],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<UserProductCard>>>
      getAllProductCards() async {
    try {
      final db = await _db;
      final txn = db.transaction('product_cards', idbModeReadOnly);
      final store = txn.objectStore('product_cards');

      List<UserProductCard> productCards = [];

      await for (var cursor in store.openCursor(autoAdvance: true)) {
        final data = cursor.value as Map<String, dynamic>;
        productCards.add(UserProductCard.fromMap(data));
      }

      await txn.completed;

      return right(productCards);
    } catch (e) {
      return left(RewildError(
        "Failed to get all product cards: $e",
        source: "UserProductCardDataProvider",
        name: "getAllProductCards",
        args: [],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteProductCard({
    required int sku,
    required String mp,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('product_cards', idbModeReadWrite);
      final store = txn.objectStore('product_cards');

      // Используем составной ключ 'sku_mp'
      final key = '${sku}_$mp';
      await store.delete(key);

      await txn.completed;

      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete product card: $e",
        source: "UserProductCardDataProvider",
        name: "deleteProductCard",
        args: [sku, mp],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, String>> getImageForNmId({
    required int nmId,
    required String mp,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('product_cards', idbModeReadOnly);
      final store = txn.objectStore('product_cards');

      final key = '${nmId}_$mp';
      final existingCard = await store.getObject(key);
      if (existingCard == null) {
        return right("");
      }
      final cursor = await store.openCursor(range: KeyRange.only(key)).first;
      final data = cursor.value as Map<String, dynamic>;
      final img = data['img'] as String;
      return right(img);
    } catch (e) {
      return left(RewildError(
        "Failed to get image for nmId: $e",
        source: "UserProductCardDataProvider",
        name: "getImageForNmId",
        args: [nmId, mp],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, UserProductCard>> getOne({
    required int sku,
    required String mp,
  }) async {
    try {
      final db = await _db;
      final txn = db.transaction('product_cards', idbModeReadOnly);
      final store = txn.objectStore('product_cards');

      // Используем составной ключ 'sku_mp'
      final key = '${sku}_$mp';
      final cursor = await store.openCursor(range: KeyRange.only(key)).first;

      final data = cursor.value as Map<String, dynamic>;
      return right(UserProductCard.fromMap(data));
    } catch (e) {
      return left(RewildError(
        "Failed to get product card for sku: $e",
        source: "UserProductCardDataProvider",
        name: "getOne",
        args: [sku, mp],
        sendToTg: true,
      ));
    }
  }
}
