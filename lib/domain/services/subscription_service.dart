import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subscription_api_models.dart';

import 'package:rewild_bot_front/domain/entities/subscription_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild_bot_front/presentation/payment/payment_screen/payment_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/payment/payment_web_view/payment_webview_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/single_card_screen/single_card_screen_view_model.dart';

// Api
abstract class SubscriptionServiceSubscriptionApiClient {
  Future<Either<RewildError, AddSubscriptionV2Response>> addSubscriptionV2({
    required String token,
    required String subscriptionType,
    required String startDate,
    required String endDate,
  });
  Future<Either<RewildError, SubscriptionV2Response>> getSubscriptionV2({
    required String token,
  });
  Future<Either<RewildError, UpdateSubscriptionV2Response>>
      updateSubscriptionV2({
    required String token,
    required int subscriptionID,
    required String subscriptionType,
    required String startDate,
    required String endDate,
  });

  Future<Either<RewildError, ExtendSubscriptionV2Response>>
      extendSubscriptionV2({
    required String token,
    required int subscriptionId,
    required String newEndDate,
  });
  Future<Either<RewildError, AddCardsToSubscriptionResponse>>
      addCardsToSubscription({
    required String token,
    required List<CardToSubscription> cards,
  });

  Future<Either<RewildError, RemoveCardFromSubscriptionResponse>>
      removeCardFromSubscription({
    required String token,
    required int sku,
  });
}

// Data Provider
abstract class SubscriptionServiceSubscriptionDataProvider {
  Future<Either<RewildError, int>> save(SubscriptionModel subscription);
  Future<Either<RewildError, List<SubscriptionModel>>> getAllNotExpired();
  Future<Either<RewildError, bool>> deleteAll();
  Future<Either<RewildError, SubscriptionModel?>> getOne(int nmId);
}

// Failed request
abstract class SubsServiceSubscriptionDataProvider {
  Future<Either<RewildError, void>> addSubscriptionId(int subscriptionId);
  Future<Either<RewildError, void>> deleteSubscriptionId(int subscriptionId);
  Future<Either<RewildError, List<int>>> getAllSubscriptionIds();
}

// User name
abstract class SubscriptionServiceUserNameSecureStorage {
  Future<Either<RewildError, String?>> getServerToken();
}

class SubscriptionService
    implements
        PaymentScreenSubscriptionsService,
        SingleCardScreenSubscriptionsService,
        PaymentWebViewSubscriptionsService,
        MainNavigationSubscriptionService,
        AllCardsScreenSubscriptionsService {
  final SubscriptionServiceSubscriptionApiClient apiClient;
  final SubscriptionServiceSubscriptionDataProvider dataProvider;
  // final SubscriptionServiceUserNameSecureStorage userNameStorage;
  // final SubsServiceSubscriptionDataProvider subsToDeleteDataProvider;
  final StreamController<(int, int)> cardsNumberStreamController;

  SubscriptionService(
      {required this.apiClient,
      required this.dataProvider,
      // required this.subsToDeleteDataProvider,
      // required this.userNameStorage,
      required this.cardsNumberStreamController});

  Future<Either<RewildError, bool>> subscriptionsIsNotEmpty() async {
    final subsEither = await dataProvider.getAllNotExpired();
    if (subsEither.isRight()) {
      return right(subsEither
          .fold((l) => throw UnimplementedError(), (r) => r)
          .isNotEmpty);
    }
    return right(false);
  }

  @override
  Future<Either<RewildError, List<SubscriptionModel>>> getSubscriptions(
      {required String token}) async {
    // get subscriptions from server
    final subscriptionsfromServerEither =
        await apiClient.getSubscriptionV2(token: token);
    if (subscriptionsfromServerEither is Left) {
      return subscriptionsfromServerEither;
    }
    final subscriptionsfromServer = subscriptionsfromServerEither.fold(
        (l) => throw UnimplementedError(), (r) => r);

    // update local subscriptions

    final voidEither = await _syncSubscriptions(subscriptionsfromServer);
    if (voidEither is Left) {
      return voidEither.fold((l) => left(l), (r) => throw UnimplementedError());
    }
    final now = DateTime.now();
    return right(subscriptionsfromServer
        .where((element) => now.isBefore(DateTime.parse(element.endDate)))
        .toList());
  }

  Future<Either<RewildError, void>> _syncSubscriptions(
      List<SubscriptionModel> subs) async {
    // Get subscriptions from API client

    // If the API returns no error, delete all local subscriptions
    await dataProvider.deleteAll();
    // Save subscriptions to local data provider
    for (var subscription in subs) {
      final saveResult = await dataProvider.save(subscription);
      if (saveResult.isLeft()) {
        return saveResult;
      }
    }
    _addSubsToStream(subs);
    return right(null);
  }

  @override
  Future<Either<RewildError, void>> clearSubscriptions(
      {required String token, required List<int> cardIds}) async {
    // Delete from API client
    final apiResult =
        await apiClient.clearSubscriptions(token: token, cardIds: cardIds);
    if (apiResult.isLeft()) {
      return apiResult; // If the API deletion fails, return the error
    }
    final apiSubs = apiResult.fold((l) => throw UnimplementedError(), (r) => r);

    final res = await _syncSubscriptions(apiSubs);
    if (res.isLeft()) {
      return res;
    }
    return right(null); // Return success
  }

  void _addSubsToStream(List<SubscriptionModel> subs) {
    final now = DateTime.now();
    final activeSubs =
        subs.where((element) => now.isBefore(DateTime.parse(element.endDate)));
    final totalSubsLength = activeSubs.length;
    final takenSubsLength =
        activeSubs.where((element) => element.cardId != 0).length;
    cardsNumberStreamController.add((totalSubsLength, takenSubsLength));
  }

  @override
  Future<Either<RewildError, List<SubscriptionModel>>> createSubscriptions({
    required String token,
    required List<int> cardIds,
    required String startDate,
    required String endDate,
  }) async {
    // Create subscriptions in the API client
    final allSubsOnServerEither = await apiClient.createSubscriptions(
        token: token, cardIds: cardIds, startDate: startDate, endDate: endDate);
    if (allSubsOnServerEither.isLeft()) {
      return allSubsOnServerEither; // If API creation fails, return the error
    }
    final allSubscriptionsOnServer =
        allSubsOnServerEither.fold((l) => throw UnimplementedError(), (r) => r);
    // Save all server`s subscriptions to the local data provider
    List<SubscriptionModel> allSubscriptionsFromServer = [];

    final res = await _syncSubscriptions(allSubscriptionsOnServer);
    if (res.isLeft()) {
      return res.fold((l) => left(l), (r) => throw UnimplementedError());
    }
    return right(
        allSubscriptionsFromServer); // Return the list of saved subscriptions
  }

  @override
  Future<Either<RewildError, List<SubscriptionModel>>> addZeroSubscriptions({
    required String token,
    required int qty,
    required String startDate,
    required String endDate,
  }) async {
    // Create subscriptions in the API client
    final allSubsOnServerEither = await apiClient.addZeroSubscriptions(
        token: token, qty: qty, startDate: startDate, endDate: endDate);
    if (allSubsOnServerEither.isLeft()) {
      return allSubsOnServerEither; // If API creation fails, return the error
    }

    final allSubscriptionsOnServer =
        allSubsOnServerEither.fold((l) => throw UnimplementedError(), (r) => r);

    // Save all server`s subscriptions to the local data provider
    List<SubscriptionModel> allSubscriptionsFromServer = [];

    final res = await _syncSubscriptions(allSubscriptionsOnServer);
    if (res.isLeft()) {
      return res.fold((l) => left(l), (r) => throw UnimplementedError());
    }

    return right(
        allSubscriptionsFromServer); // Return the list of saved subscriptions
  }

  // @override
  // Future<Either<RewildError, bool>> isSubscribed(int nmId) async {
  //   final subsEither = await dataProvider.getOne(nmId);
  //   if (subsEither.isLeft()) {
  //     return left(subsEither.fold((l) => l, (r) => throw UnimplementedError()));
  //   }
  //   final subs = subsEither.fold((l) => throw UnimplementedError(), (r) => r);
  //   return right(subs != null);
  // }
}
