import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/domain/entities/user_seller.dart';
import 'package:rewild_bot_front/domain/services/advert_service.dart';
import 'package:rewild_bot_front/domain/services/api_keys_service.dart';
import 'package:rewild_bot_front/domain/services/question_service.dart';

class UserSellersDataProvider
    implements
        ApiKeysServiceActiveSellerDataProvider,
        QuestionServiceActiveSellerDataProvider,
        AdvertServiceActiveSellerDataProvider {
  const UserSellersDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> addOne(UserSeller seller) async {
    try {
      final db = await _db;
      final txn = db.transaction('user_sellers', idbModeReadWrite);
      final store = txn.objectStore('user_sellers');
      await store.put(seller.toMap());
      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to add user seller: $e",
        source: runtimeType.toString(),
        name: "addOne",
        args: [seller],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<UserSeller>>> getAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('user_sellers', idbModeReadOnly);
      final store = txn.objectStore('user_sellers');
      final result = await store.getAll();
      await txn.completed;

      // Safely map the result to a List<UserSeller>
      final sellers = result
          .whereType<Map<String, dynamic>>()
          .map((item) => UserSeller.fromMap(item))
          .toList();

      return right(sellers);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve all user sellers: $e",
        source: runtimeType.toString(),
        name: "getAll",
        args: [],
        sendToTg: true,
      ));
    }
  }

  Future<Either<RewildError, void>> rename(
      String sellerId, String sellerName) async {
    try {
      final db = await _db;
      final txn = db.transaction('user_sellers', idbModeReadWrite);
      final store = txn.objectStore('user_sellers');
      final seller = await store.getObject(sellerId);

      if (seller is Map<String, dynamic>) {
        final updatedSeller =
            UserSeller.fromMap(seller).copyWith(sellerName: sellerName);
        await store.put(updatedSeller.toMap());
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to rename user seller: $e",
        source: runtimeType.toString(),
        name: "rename",
        args: [sellerId, sellerName],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<UserSeller>>> getActive() async {
    try {
      final db = await _db;
      final txn = db.transaction('user_sellers', idbModeReadOnly);
      final store = txn.objectStore('user_sellers');
      final result = await store.getAll();
      await txn.completed;

      // Safely map the result to a List<UserSeller> and filter active sellers
      final activeSellers = result
          .whereType<Map<String, dynamic>>()
          .map((item) => UserSeller.fromMap(item))
          .where((seller) => seller.isActive)
          .toList();

      if (activeSellers.isEmpty) {
        return right(
            [UserSeller(sellerId: '', sellerName: '', isActive: true)]);
      }
      return right(activeSellers);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve active user sellers: $e",
        source: runtimeType.toString(),
        name: "getActive",
        args: [],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> setActive(String sellerId) async {
    try {
      await resetAll();
      final db = await _db;
      final txn = db.transaction('user_sellers', idbModeReadWrite);
      final store = txn.objectStore('user_sellers');
      final seller = await store.getObject(sellerId);

      if (seller is Map<String, dynamic>) {
        final updatedSeller =
            UserSeller.fromMap(seller).copyWith(isActive: true);
        await store.put(updatedSeller.toMap());
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to set active status for user seller: $e",
        source: runtimeType.toString(),
        name: "setActive",
        args: [sellerId],
        sendToTg: true,
      ));
    }
  }

  Future<Either<RewildError, void>> resetAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('user_sellers', idbModeReadWrite);
      final store = txn.objectStore('user_sellers');
      final allSellers = await store.getAll();

      for (var item in allSellers.whereType<Map<String, dynamic>>()) {
        final seller = UserSeller.fromMap(item);
        final updatedSeller = seller.copyWith(isActive: false);
        await store.put(updatedSeller.toMap());
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to reset all user sellers: $e",
        source: runtimeType.toString(),
        name: "resetAll",
        args: [],
        sendToTg: true,
      ));
    }
  }
}
