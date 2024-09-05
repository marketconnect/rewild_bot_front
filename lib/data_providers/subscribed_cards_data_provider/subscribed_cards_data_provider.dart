import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/services/subscription_service.dart';

class SubscribedCardsDataProvider implements SubsServiceCardsDataProvider {
  const SubscribedCardsDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, List<int>>> getAllIds() async {
    try {
      final db = await _db;
      final txn = db.transaction('subscribed_cards', idbModeReadOnly);
      final store = txn.objectStore('subscribed_cards');
      // Get all subscriptions
      final cursorStream = store.openCursor(autoAdvance: true);
      final subscriptions = <int>[];
      await for (var cursor in cursorStream) {
        // Use cursor.value to get the stored object
        final data = cursor.value as Map<String, dynamic>;
        subscriptions
            .add(data['sku'] as int); // Extract 'sku' from the stored object
      }
      await txn.completed;
      return right(subscriptions);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SubscribedCardsDataProvider",
        name: "getAllIds",
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> addAllIds(List<int> ids) async {
    try {
      final db = await _db;
      final txn = db.transaction('subscribed_cards', idbModeReadWrite);
      final store = txn.objectStore('subscribed_cards');
      for (var id in ids) {
        // Correctly create the object with 'sku' key
        await store.put({'sku': id}); // Use map with 'sku' field
      }
      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SubscribedCardsDataProvider",
        name: "addAllIds",
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> deleteAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('subscribed_cards', idbModeReadWrite);
      final store = txn.objectStore('subscribed_cards');
      await store.clear();
      await txn.completed;
      return right(true);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SubscribedCardsDataProvider",
        name: "deleteAll",
      ));
    }
  }
}
