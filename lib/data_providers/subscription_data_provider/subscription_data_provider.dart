import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subscription_model.dart';
import 'package:rewild_bot_front/domain/services/subscription_service.dart';

import 'package:intl/intl.dart';

class SubscriptionDataProvider
    implements SubscriptionServiceSubscriptionDataProvider {
  const SubscriptionDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, int>> save(SubscriptionModel subscription) async {
    try {
      final db = await _db;
      final txn = db.transaction('subs', idbModeReadWrite);
      final store = txn.objectStore('subs');

      // Check if subscription with this card_id already exists
      if (subscription.cardId != 0) {
        final index = store.index('card_id');
        final existingSub = await index.count(subscription.cardId);

        // If yes - return 0
        if (existingSub > 0) {
          await txn.completed;
          return right(0);
        }
      }

      // If not, insert a new record
      final id = await store.put(subscription.toMap());
      await txn.completed;
      return right(id as int);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SubscriptionDataProvider",
        name: "save",
        args: [subscription],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubscriptionModel>>>
      getAllNotExpired() async {
    try {
      final db = await _db;
      final txn = db.transaction('subs', idbModeReadOnly);
      final store = txn.objectStore('subs');
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final index = store.index('end_date');
      final cursorStream = index.openCursor(autoAdvance: true);

      final List<SubscriptionModel> subscriptions = [];

      await for (final cursor in cursorStream) {
        final value = cursor.value as Map<String, dynamic>;
        if (value['end_date'] >= today) {
          subscriptions.add(SubscriptionModel.fromMap(value));
        }
      }

      await txn.completed;
      return right(subscriptions);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SubscriptionDataProvider",
        name: "getAllNotExpired",
      ));
    }
  }

  @override
  Future<Either<RewildError, SubscriptionModel?>> getOne(int nmId) async {
    try {
      final db = await _db;
      final txn = db.transaction('subs', idbModeReadOnly);
      final store = txn.objectStore('subs');
      final result = await store.getObject(nmId);

      await txn.completed;
      return right(result != null
          ? SubscriptionModel.fromMap(result as Map<String, dynamic>)
          : null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SubscriptionDataProvider",
        name: "getOne",
        args: [nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> deleteAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('subs', idbModeReadWrite);
      final store = txn.objectStore('subs');
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

  Future<Either<RewildError, List<SubscriptionModel>>>
      getActiveSubscriptions() async {
    try {
      final db = await _db;
      final txn = db.transaction('subs', idbModeReadOnly);
      final store = txn.objectStore('subs');
      final tomorrow = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));

      final index = store.index('end_date');
      final cursorStream = index.openCursor(autoAdvance: true);

      final List<SubscriptionModel> subscriptions = [];

      await for (final cursor in cursorStream) {
        final value = cursor.value as Map<String, dynamic>;
        if (value['end_date'] > tomorrow) {
          subscriptions.add(SubscriptionModel.fromMap(value));
        }
      }

      await txn.completed;
      return right(subscriptions);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SubscriptionDataProvider",
        name: "getActiveSubscriptions",
      ));
    }
  }

  static Future<Either<RewildError, List<SubscriptionModel>>>
      getActiveSubscriptionsInBg() async {
    try {
      final db = await DatabaseHelper().database;
      final txn = db.transaction('subs', idbModeReadOnly);
      final store = txn.objectStore('subs');
      final tomorrow = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));

      final index = store.index('end_date');
      final cursorStream = index.openCursor(autoAdvance: true);

      final List<SubscriptionModel> subscriptions = [];

      await for (final cursor in cursorStream) {
        final value = cursor.value as Map<String, dynamic>;
        if (value['end_date'] > tomorrow) {
          subscriptions.add(SubscriptionModel.fromMap(value));
        }
      }

      await txn.completed;
      return right(subscriptions);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: 'SubscriptionDataProvider',
        name: "getActiveSubscriptionsInBg",
      ));
    }
  }
}
