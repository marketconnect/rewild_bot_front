import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/rewild_notification_model.dart';
import 'package:rewild_bot_front/domain/services/notification_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class NotificationDataProvider
    implements
        UpdateServiceNotificationDataProvider,
        NotificationServiceNotificationDataProvider {
  const NotificationDataProvider();

  Box<ReWildNotificationModel> get _box =>
      Hive.box<ReWildNotificationModel>(HiveBoxes.rewildNotifications);

  @override
  Future<Either<RewildError, bool>> save({
    required ReWildNotificationModel notification,
  }) async {
    try {
      await _box.add(notification);
      return right(true);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "save",
        args: [notification],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<ReWildNotificationModel>>> getForParent({
    required int parentId,
  }) async {
    try {
      final notifications = _box.values
          .where((notification) => notification.parentId == parentId)
          .toList();
      return right(notifications);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getForParent",
        args: [parentId],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<ReWildNotificationModel>?>> getByCondition(
    List<int> conditions,
  ) async {
    try {
      final notifications = _box.values
          .where((notification) => conditions.contains(notification.condition))
          .toList();
      return right(notifications.isEmpty ? null : notifications);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getByCondition",
        args: [conditions],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<ReWildNotificationModel>?>> getAll() async {
    try {
      final notifications = _box.values.toList();
      return right(notifications.isEmpty ? null : notifications);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getAll",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> deleteAll({required int parentId}) async {
    try {
      final keysToDelete = _box.keys
          .where((key) => _box.get(key)?.parentId == parentId)
          .toList();
      await _box.deleteAll(keysToDelete);
      return right(keysToDelete.length);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "deleteAll",
        args: [parentId],
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> delete({
    required int parentId,
    required int condition,
    bool? reusableAlso,
  }) async {
    try {
      final keysToDelete = _box.keys.where((key) {
        final notification = _box.get(key);
        if (notification == null) return false;
        if (reusableAlso == true) {
          return notification.parentId == parentId &&
              notification.condition == condition;
        }
        return notification.parentId == parentId &&
            notification.condition == condition &&
            notification.reusable != true;
      }).toList();

      await _box.deleteAll(keysToDelete);
      return right(true);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "delete",
        args: [parentId, condition],
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> checkForParent({
    required int id,
  }) async {
    try {
      final exists =
          _box.values.any((notification) => notification.parentId == id);
      return right(exists);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "checkForParent",
        args: [id],
      ));
    }
  }
}
