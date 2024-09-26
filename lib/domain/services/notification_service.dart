import 'dart:async';

import 'package:fpdart/fpdart.dart';
// import 'package:rewild_bot_front/core/constants/notification_constants.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/get_all_subscriptions_for_user_response.dart';
import 'package:rewild_bot_front/domain/entities/notification.dart';
import 'package:rewild_bot_front/domain/entities/product_watch_delete_subscription_response.dart';
import 'package:rewild_bot_front/domain/entities/product_watch_subscription_response.dart';
import 'package:rewild_bot_front/domain/entities/stream_notification_event.dart';

import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/notification_card_screen/notification_card_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/single_card_screen/single_card_screen_view_model.dart';

// import 'package:rewild/presentation/single_advert_stats_screen/single_advert_stats_view_model.dart';

abstract class NotificationServiceNotificationDataProvider {
  Future<Either<RewildError, List<ReWildNotificationModel>?>> getAll();
  Future<Either<RewildError, bool>> save(
      {required ReWildNotificationModel notification});
  Future<Either<RewildError, int>> deleteAll({required int parentId});
  Future<Either<RewildError, List<ReWildNotificationModel>>> getForParent(
      {required int parentId});
  Future<Either<RewildError, bool>> delete(
      {required int parentId, required int condition, bool? reusableAlso});
  Future<Either<RewildError, bool>> checkForParent({required int id});
  Future<Either<RewildError, List<ReWildNotificationModel>?>> getByCondition(
      List<String> conditions);
}

abstract class NotificationServiceSecureDataProvider {
  Future<Either<RewildError, String?>> getUsername();
}

abstract class NotificationServiceProductWatchSubscriptionApiClient {
  Future<Either<RewildError, ProductWatchSubscriptionResponse>>
      addProductWatchSubscription({
    required String token,
    required String endDate,
    required List<Map<String, dynamic>> subscriptions,
  });
  Future<Either<RewildError, ProductWatchDeleteSubscriptionResponse>>
      deleteProductWatchSubscription({
    required String token,
    required List<Map<String, dynamic>> subscriptions,
  });
  Future<Either<RewildError, GetAllSubscriptionsForUserAndProductResponse>>
      getAllSubscriptionsForUserAndProduct({
    required String token,
    required int productId,
  });
}

class NotificationService
    implements
        AllCardsScreenNotificationsService,
        // CampaignManagementNotificationService,
        // NotificationFeedbackNotificationService,
        SingleCardScreenNotificationService,
        NotificationCardNotificationService {
  final NotificationServiceNotificationDataProvider notificationDataProvider;
  final NotificationServiceSecureDataProvider secureDataProvider;

  final NotificationServiceProductWatchSubscriptionApiClient
      productWatchSubscriptionApiClient;
  final StreamController<StreamNotificationEvent>
      updatedNotificationStreamController;
  NotificationService(
      {required this.notificationDataProvider,
      required this.secureDataProvider,
      required this.productWatchSubscriptionApiClient,
      required this.updatedNotificationStreamController});

  // Future<Either<RewildError, bool>> delete(
  //     {required int id, required int condition, bool? isEmpty}) async {
  //   final either = await notificationDataProvider.delete(
  //       parentId: id, condition: condition);
  //   return either.fold((l) => left(l), (r) {
  //     if (isEmpty != null && isEmpty) {
  //       updatedNotificationStreamController.add(StreamNotificationEvent(
  //           parentId: id,
  //           parentType:
  //               condition == NotificationConditionConstants.budgetLessThan
  //                   ? ParentType.advert
  //                   : ParentType.card,
  //           exists: false));
  //     }
  //     return either;
  //   });
  // }

  @override
  Future<Either<RewildError, bool>> checkForParent(
      {required int campaignId}) async {
    final resource =
        await notificationDataProvider.checkForParent(id: campaignId);

    return resource;
  }

  @override
  Future<Either<RewildError, void>> addForParent(
      {required String token,
      required String endDate,
      required List<ReWildNotificationModel> notifications,
      required int parentId,
      required bool wasEmpty}) async {
    // get for api request
    final subscriptionsEither = await productWatchSubscriptionApiClient
        .getAllSubscriptionsForUserAndProduct(
            token: token, productId: parentId);
    if (subscriptionsEither.isLeft()) {
      return subscriptionsEither;
    }

    // all user subscriptions for this product
    final subscriptions = subscriptionsEither.fold(
        (l) => <ProductSubscriptionServiceSubscription>[],
        (r) => r.subscriptions);

    // convert notifications to server subscriptions
    final chatIdEither = await secureDataProvider.getUsername();
    if (chatIdEither.isLeft()) {
      return chatIdEither;
    }

    final chatId = chatIdEither.fold((l) => "", (r) => r ?? "");

    final notificationsToAdd = notifications
        .map((notification) =>
            notification.toServerSubscription(int.parse(chatId)))
        .toList();

    // delete subscriptions on the server
    if (subscriptions.isNotEmpty) {
      final deleteResponse = await productWatchSubscriptionApiClient
          .deleteProductWatchSubscription(
              token: token,
              subscriptions: subscriptions.map((s) => s.toJson()).toList());
      if (deleteResponse.isLeft()) {
        return deleteResponse;
      }
    }
    // add subscriptions on the server
    if (notificationsToAdd.isNotEmpty) {
      final addResponse =
          await productWatchSubscriptionApiClient.addProductWatchSubscription(
              token: token,
              endDate: endDate,
              subscriptions:
                  notificationsToAdd.map((s) => s.toJson()).toList());
      if (addResponse.isLeft()) {
        return addResponse;
      }
    }
    final either = await notificationDataProvider.deleteAll(parentId: parentId);
    if (either.isLeft()) {
      return either;
    }

    for (final notification in notifications) {
      final either =
          await notificationDataProvider.save(notification: notification);
      if (either.isLeft()) {
        return either;
      }
    }
    if ((wasEmpty && notifications.isNotEmpty) ||
        (!wasEmpty && notifications.isEmpty)) {
      updatedNotificationStreamController.add(StreamNotificationEvent(
          parentId: parentId,
          parentType: ParentType.card,
          exists: notifications.isNotEmpty));
    }

    return right(null);
  }

  @override
  Future<Either<RewildError, List<ReWildNotificationModel>>> getForParent(
      {required int parentId}) async {
    final either =
        await notificationDataProvider.getForParent(parentId: parentId);
    if (either.isLeft()) {
      return either;
    }
    return either.fold((l) => left(l), (notifications) {
      if (notifications.isEmpty) {
        return right([]);
      }
      return either;
    });
  }

  @override
  Future<Either<RewildError, List<ReWildNotificationModel>>> getAll() async {
    final either = await notificationDataProvider.getAll();

    return either.fold((l) => left(l), (notifications) {
      if (notifications == null || notifications.isEmpty) {
        return right([]);
      }
      return right(notifications);
    });
  }

  // @override
  // Future<Either<RewildError, List<ReWildNotificationModel>?>> getByCondition(
  //     List<String> conditions) async {
  //   final either = await notificationDataProvider.getByCondition(conditions);
  //   return either.fold((l) => left(l), (notifications) {
  //     if (notifications == null || notifications.isEmpty) {
  //       return right(null);
  //     }
  //     return right(notifications);
  //   });
  // }
}
