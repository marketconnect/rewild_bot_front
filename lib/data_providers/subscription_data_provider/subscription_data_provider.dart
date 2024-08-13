import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/subscription_model.dart';
import 'package:rewild_bot_front/domain/services/subscription_service.dart';

class SubscriptionDataProvider
    implements SubscriptionServiceSubscriptionDataProvider {
  const SubscriptionDataProvider();

  @override
  Future<Either<RewildError, int>> save(SubscriptionModel subscription) async {
    try {
      final box =
          await Hive.openBox<SubscriptionModel>(HiveBoxes.subscriptions);

      // Проверка, существует ли уже подписка с таким card_id
      final existingSub = box.values
          .where((sub) => sub.cardId == subscription.cardId)
          .isNotEmpty;

      if (existingSub) {
        return right(0);
      }

      final id = await box.add(subscription);
      return right(id);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "save",
        args: [subscription],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubscriptionModel>>>
      getAllNotExpired() async {
    try {
      final box =
          await Hive.openBox<SubscriptionModel>(HiveBoxes.subscriptions);
      final today = DateTime.now().toIso8601String().split('T')[0];

      final result =
          box.values.where((sub) => sub.endDate.compareTo(today) >= 0).toList();

      return right(result);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getAllNotExpired",
      ));
    }
  }

  @override
  Future<Either<RewildError, SubscriptionModel?>> getOne(int nmId) async {
    try {
      final box =
          await Hive.openBox<SubscriptionModel>(HiveBoxes.subscriptions);
      // final subscription = box.values
      //     .firstWhere((sub) => sub.cardId == nmId, orElse: () => null);

      final subscription = box.values.where((sub) => sub.cardId == nmId);
      if (subscription.isEmpty) {
        return right(null);
      }
      return right(subscription.first);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getOne",
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> deleteAll() async {
    try {
      final box =
          await Hive.openBox<SubscriptionModel>(HiveBoxes.subscriptions);
      await box.clear();
      return right(true);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "deleteAll",
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubscriptionModel>>>
      getActiveSubscriptions() async {
    try {
      final box =
          await Hive.openBox<SubscriptionModel>(HiveBoxes.subscriptions);
      final tomorrow =
          DateTime.now().add(Duration(days: 1)).toIso8601String().split('T')[0];

      final result = box.values
          .where((sub) => sub.endDate.compareTo(tomorrow) > 0)
          .toList();

      return right(result);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "getActiveSubscriptions",
      ));
    }
  }

  static Future<Either<RewildError, List<SubscriptionModel>>>
      getActiveSubscriptionsInBg() async {
    try {
      final box =
          await Hive.openBox<SubscriptionModel>(HiveBoxes.subscriptions);
      final tomorrow =
          DateTime.now().add(Duration(days: 1)).toIso8601String().split('T')[0];

      final result = box.values
          .where((sub) => sub.endDate.compareTo(tomorrow) > 0)
          .toList();

      return right(result);
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
