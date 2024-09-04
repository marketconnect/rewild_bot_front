import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subscription_api_models.dart';

import 'package:rewild_bot_front/domain/services/subscription_service.dart';

import 'package:rewild_bot_front/domain/services/tracking_service.dart';

class SubscriptionDataProvider
    implements
        SubscriptionServiceSubscriptionDataProvider,
        TrackingServiceSubscriptionDataProvider {
  const SubscriptionDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, int>> save(
      SubscriptionV2Response subscription) async {
    try {
      final db = await _db;
      final txn = db.transaction('subs', idbModeReadWrite);
      final store = txn.objectStore('subs');

      // Убедимся, что 'id' больше нуля
      if (subscription.id <= 0) {
        return left(RewildError(
          sendToTg: true,
          "Некорректный ключ 'id' для объекта Subscription",
          source: "SubscriptionDataProvider",
          name: "save",
          args: [subscription.toMap()],
        ));
      }

      // Передаем только объект данных без отдельного параметра ключа
      final id = await store.put(subscription.toMap());
      await txn.completed;
      return right(id as int);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SubscriptionDataProvider",
        name: "save",
        args: [subscription.toMap()],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubscriptionV2Response>>> get() async {
    try {
      final db = await _db;
      final txn = db.transaction('subs', idbModeReadOnly);
      final store = txn.objectStore('subs');
      // get all subscriptions
      final cursorStream = store.openCursor(autoAdvance: true);
      final List<SubscriptionV2Response> subscriptions = [];

      await for (final cursor in cursorStream) {
        final value = cursor.value as Map<String, dynamic>;

        subscriptions.add(SubscriptionV2Response.fromMap(value));
      }

      await txn.completed;
      return right(subscriptions);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SubscriptionDataProvider",
        name: "getSubscriptions",
        args: [],
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
  // @override
  // Future<Either<RewildError, List<SubscriptionModel>>>
  //     getAllNotExpired() async {
  //   try {
  //     final db = await _db;
  //     final txn = db.transaction('subs', idbModeReadOnly);
  //     final store = txn.objectStore('subs');
  //     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  //     final index = store.index('end_date');
  //     final cursorStream = index.openCursor(autoAdvance: true);

  //     final List<SubscriptionModel> subscriptions = [];

  //     await for (final cursor in cursorStream) {
  //       final value = cursor.value as Map<String, dynamic>;
  //       if (value['end_date'] >= today) {
  //         subscriptions.add(SubscriptionModel.fromMap(value));
  //       }
  //     }

  //     await txn.completed;
  //     return right(subscriptions);
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: true,
  //       e.toString(),
  //       source: "SubscriptionDataProvider",
  //       name: "getAllNotExpired",
  //     ));
  //   }
  // }

  // @override
  // Future<Either<RewildError, SubscriptionModel?>> getOne(int nmId) async {
  //   try {
  //     final db = await _db;
  //     final txn = db.transaction('subs', idbModeReadOnly);
  //     final store = txn.objectStore('subs');
  //     final result = await store.getObject(nmId);

  //     await txn.completed;
  //     return right(result != null
  //         ? SubscriptionModel.fromMap(result as Map<String, dynamic>)
  //         : null);
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: true,
  //       e.toString(),
  //       source: "SubscriptionDataProvider",
  //       name: "getOne",
  //       args: [nmId],
  //     ));
  //   }
  // }

  // @override
  // Future<Either<RewildError, List<SubscriptionModel>>>
  //     getActiveSubscriptions() async {
  //   try {
  //     final db = await _db;
  //     final txn = db.transaction('subs', idbModeReadOnly);
  //     final store = txn.objectStore('subs');
  //     final tomorrow = DateFormat('yyyy-MM-dd')
  //         .format(DateTime.now().add(const Duration(days: 1)));

  //     final index = store.index('end_date');
  //     final cursorStream = index.openCursor(autoAdvance: true);

  //     final List<SubscriptionModel> subscriptions = [];

  //     await for (final cursor in cursorStream) {
  //       final value = cursor.value as Map<String, dynamic>;
  //       if (value['end_date'] > tomorrow) {
  //         subscriptions.add(SubscriptionModel.fromMap(value));
  //       }
  //     }

  //     await txn.completed;
  //     return right(subscriptions);
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: true,
  //       e.toString(),
  //       source: "SubscriptionDataProvider",
  //       name: "getActiveSubscriptions",
  //     ));
  //   }
  // }
}
