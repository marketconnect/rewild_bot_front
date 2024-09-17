import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/notification.dart';
import 'package:rewild_bot_front/domain/services/notification_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class NotificationDataProvider
    implements
        UpdateServiceNotificationDataProvider,
        NotificationServiceNotificationDataProvider {
  const NotificationDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, bool>> save(
      {required ReWildNotificationModel notification}) async {
    try {
      final db = await _db;
      final txn = db.transaction('notifications', idbModeReadWrite);
      final store = txn.objectStore('notifications');

      await store.put({
        'parentId': notification.parentId,
        'condition': notification.condition,
        'value': notification.value,
        'sizeId': notification.sizeId,
        'wh': notification.wh,
        'reusable': notification.reusable,
      });

      await txn.completed;
      return right(true);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "NotificationDataProvider",
        name: "save",
        args: [notification],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<ReWildNotificationModel>>> getForParent(
      {required int parentId}) async {
    try {
      final db = await _db;
      final txn = db.transaction('notifications', idbModeReadOnly);
      final store = txn.objectStore('notifications');
      final index = store.index('parentId');

      final List<ReWildNotificationModel> notifications = [];
      final cursorStream = index.openCursor(key: parentId);

      await for (final cursor in cursorStream) {
        final value = cursor.value as Map<String, dynamic>;
        notifications.add(ReWildNotificationModel.fromMap(value));
        cursor.next();
      }

      await txn.completed;
      return right(notifications);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "NotificationDataProvider",
        name: "getForParent",
        args: [parentId],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<ReWildNotificationModel>?>> getByCondition(
      List<String> conditions) async {
    try {
      final db = await _db;
      final txn = db.transaction('notifications', idbModeReadOnly);
      final store = txn.objectStore('notifications');
      final index = store.index('condition');

      final List<ReWildNotificationModel> notifications = [];

      for (var condition in conditions) {
        final cursorStream = index.openCursor(key: condition);

        await for (final cursor in cursorStream) {
          final value = cursor.value as Map<String, dynamic>;
          notifications.add(ReWildNotificationModel.fromMap(value));
          cursor.next();
        }
      }

      await txn.completed;
      return right(notifications.isNotEmpty ? notifications : null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "NotificationDataProvider",
        name: "getByCondition",
        args: [conditions],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<ReWildNotificationModel>?>> getAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('notifications', idbModeReadOnly);
      final store = txn.objectStore('notifications');
      final result = await store.getAll();

      if (result.isEmpty) {
        return right(null);
      }

      final notifications = result
          .map(
              (e) => ReWildNotificationModel.fromMap(e as Map<String, dynamic>))
          .toList();

      await txn.completed;
      return right(notifications);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "NotificationDataProvider",
        name: "getAll",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> deleteAll({required int parentId}) async {
    try {
      final db = await _db;
      final txn = db.transaction('notifications', idbModeReadWrite);
      final store = txn.objectStore('notifications');
      final index = store.index('parentId');
      final keys = await index.getAllKeys(parentId);
      for (final key in keys) {
        await store.delete(key);
      }

      await txn.completed;
      return right(keys.length);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "NotificationDataProvider",
        name: "deleteAll",
        args: [parentId],
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> delete(
      {required int parentId,
      required int condition,
      bool? reusableAlso}) async {
    try {
      final db = await _db;
      final txn = db.transaction('notifications', idbModeReadWrite);
      final store = txn.objectStore('notifications');
      final index = store.index('parentId_condition');
      final keys = await index.getAllKeys([parentId, condition]);

      for (final key in keys) {
        if (reusableAlso == true) {
          await store.delete(key);
        } else {
          final notification =
              await store.getObject(key) as Map<String, dynamic>?;
          if (notification != null && notification['reusable'] != 1) {
            await store.delete(key);
          }
        }
      }

      await txn.completed;
      return right(true);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "NotificationDataProvider",
        name: "delete",
        args: [parentId, condition],
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> checkForParent({required int id}) async {
    try {
      final db = await _db;
      final txn = db.transaction('notifications', idbModeReadOnly);
      final store = txn.objectStore('notifications');
      final index = store.index('parentId');
      final cursorStream = index.openCursor(key: id);
      bool exists = false;

      // ignore: unused_local_variable
      await for (final cursor in cursorStream) {
        exists = true;
        break;
      }

      await txn.completed;
      return right(exists);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "NotificationDataProvider",
        name: "checkForParent",
        args: [id],
      ));
    }
  }
}
