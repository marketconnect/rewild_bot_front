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
      // get all subscriptions
      final cursorStream = store.openCursor(autoAdvance: true);
      final subscriptions = <int>[];
      await for (var cursor in cursorStream) {
        subscriptions.add(cursor.key as int);
      }
      await txn.completed;
      return right(subscriptions);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SubscriptionDataProvider",
        name: "getAllIds",
      ));
    }
  }

  Future<Either<RewildError, void>> addAllIds(List<int> ids) async {
    try {
      final db = await _db;
      final txn = db.transaction('subscribed_cards', idbModeReadWrite);
      final store = txn.objectStore('subscribed_cards');
      for (var id in ids) {
        await store.put(id);
      }
      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SubscriptionDataProvider",
        name: "addAll",
      ));
    }
  }

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
        source: "SubscriptionDataProvider",
        name: "deleteAll",
      ));
    }
  }
}
