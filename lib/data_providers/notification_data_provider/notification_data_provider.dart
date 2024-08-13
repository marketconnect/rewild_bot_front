// import 'package:hive/hive.dart';
// import 'package:fpdart/fpdart.dart';

// import 'package:rewild_bot_front/core/utils/rewild_error.dart';
// import 'package:rewild_bot_front/domain/entities/hive/rewild_notification_model.dart';
// import 'package:rewild_bot_front/domain/services/notification_service.dart';
// import 'package:rewild_bot_front/domain/services/update_service.dart';

// class NotificationDataProvider
//     implements
//         NotificationServiceNotificationDataProvider,
//         UpdateServiceNotificationDataProvider {
//   const NotificationDataProvider();

//   @override
//   Future<Either<RewildError, bool>> save(
//       {required ReWildNotificationModel notification}) async {
//     try {
//       final box = await Hive.openBox<ReWildNotificationModel>(
//           'HiveBoxes.notifications');
//       await box.add(notification);
//       return right(true);
//     } catch (e) {
//       return left(RewildError(
//           sendToTg: true,
//           e.toString(),
//           source: runtimeType.toString(),
//           name: "save",
//           args: [notification]));
//     }
//   }

//   @override
//   Future<Either<RewildError, List<ReWildNotificationModel>>> getForParent(
//       {required int parentId}) async {
//     try {
//       final box = await Hive.openBox<ReWildNotificationModel>(
//           'HiveBoxes.notifications');
//       final notifications = box.values
//           .where((notification) => notification.parentId == parentId)
//           .toList();

//       return right(notifications);
//     } catch (e) {
//       return left(RewildError(
//           sendToTg: true,
//           e.toString(),
//           source: runtimeType.toString(),
//           name: "getForParent",
//           args: [parentId]));
//     }
//   }

//   @override
//   Future<Either<RewildError, List<ReWildNotificationModel>?>> getByCondition(
//       List<int> conditions) async {
//     try {
//       final box = await Hive.openBox<ReWildNotificationModel>(
//           'HiveBoxes.notifications');
//       final notifications = box.values
//           .where((notification) => conditions.contains(notification.condition))
//           .toList();

//       return right(notifications.isEmpty ? null : notifications);
//     } catch (e) {
//       return left(RewildError(
//           sendToTg: true,
//           e.toString(),
//           source: runtimeType.toString(),
//           name: "getByCondition",
//           args: [conditions]));
//     }
//   }

//   @override
//   Future<Either<RewildError, List<ReWildNotificationModel>?>> getAll() async {
//     try {
//       final box = await Hive.openBox<ReWildNotificationModel>(
//           'HiveBoxes.notifications');
//       final notifications = box.values.toList();

//       return right(notifications.isEmpty ? null : notifications);
//     } catch (e) {
//       return left(RewildError(
//           sendToTg: true,
//           e.toString(),
//           source: runtimeType.toString(),
//           name: "getAll",
//           args: []));
//     }
//   }

//   @override
//   Future<Either<RewildError, int>> deleteAll({required int parentId}) async {
//     try {
//       final box = await Hive.openBox<ReWildNotificationModel>(
//           'HiveBoxes.notifications');
//       final keysToDelete =
//           box.keys.where((key) => box.get(key)?.parentId == parentId).toList();

//       for (var key in keysToDelete) {
//         await box.delete(key);
//       }

//       return right(keysToDelete.length);
//     } catch (e) {
//       return left(RewildError(
//           sendToTg: true,
//           e.toString(),
//           source: runtimeType.toString(),
//           name: "deleteAll",
//           args: [parentId]));
//     }
//   }

//   @override
//   Future<Either<RewildError, bool>> delete(
//       {required int parentId,
//       required int condition,
//       bool? reusableAlso}) async {
//     try {
//       final box = await Hive.openBox<ReWildNotificationModel>(
//           'HiveBoxes.notifications');
//       final keysToDelete = box.keys.where((key) {
//         final notification = box.get(key);
//         return notification?.parentId == parentId &&
//             notification?.condition == condition &&
//             (reusableAlso == true || notification?.reusable != true);
//       }).toList();

//       for (var key in keysToDelete) {
//         await box.delete(key);
//       }

//       return right(keysToDelete.isNotEmpty);
//     } catch (e) {
//       return left(RewildError(
//           sendToTg: true,
//           e.toString(),
//           source: runtimeType.toString(),
//           name: "delete",
//           args: [parentId, condition]));
//     }
//   }

//   static Future<Either<RewildError, List<ReWildNotificationModel>>>
//       getAllInBackground() async {
//     try {
//       final box = await Hive.openBox<ReWildNotificationModel>(
//           'HiveBoxes.notifications');
//       final notifications = box.values.toList();

//       return right(notifications);
//     } catch (e) {
//       return left(RewildError(
//           sendToTg: true,
//           e.toString(),
//           source: "NotificationDataProvider",
//           name: "getAllInBackground",
//           args: []));
//     }
//   }

//   static Future<Either<RewildError, bool>> saveInBackground(
//       ReWildNotificationModel notificate) async {
//     try {
//       final box = await Hive.openBox<ReWildNotificationModel>(
//           'HiveBoxes.notifications');
//       await box.add(notificate);

//       return right(true);
//     } catch (e) {
//       return left(RewildError(
//           sendToTg: true,
//           e.toString(),
//           source: "NotificationDataProvider",
//           name: "saveInBackground",
//           args: [notificate]));
//     }
//   }

//   @override
//   Future<Either<RewildError, bool>> checkForParent({required int id}) async {
//     try {
//       final box = await Hive.openBox<ReWildNotificationModel>(
//           'HiveBoxes.notifications');
//       final exists =
//           box.values.any((notification) => notification.parentId == id);

//       return right(exists);
//     } catch (e) {
//       return left(RewildError(
//           sendToTg: true,
//           e.toString(),
//           source: runtimeType.toString(),
//           name: "checkForParent",
//           args: [id]));
//     }
//   }
// }
