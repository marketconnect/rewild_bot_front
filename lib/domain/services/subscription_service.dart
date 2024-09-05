import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subscription_api_models.dart';

import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild_bot_front/presentation/payment/payment_screen/payment_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/payment/payment_web_view/payment_webview_model.dart';

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
      removeCardsFromSubscription({
    required String token,
    required List<int> skus,
  });
}

// Subs data Provider
abstract class SubscriptionServiceSubscriptionDataProvider {
  Future<Either<RewildError, int>> save(SubscriptionV2Response subscription);
  Future<Either<RewildError, List<SubscriptionV2Response>>> get();
  Future<Either<RewildError, bool>> deleteAll();
  // Future<Either<RewildError, List<SubscriptionModel>>> getAllNotExpired();
  // Future<Either<RewildError, SubscriptionModel?>> getOne(int nmId);
}

// Cards data Provider
abstract class SubsServiceCardsDataProvider {
  Future<Either<RewildError, List<int>>> getAllIds();
  Future<Either<RewildError, void>> addAllIds(List<int> ids);
  Future<Either<RewildError, bool>> deleteAll();
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
        // SingleCardScreenSubscriptionsService,
        PaymentWebViewSubscriptionsService,
        MainNavigationSubscriptionService,
        AllCardsScreenSubscriptionsService {
  final SubscriptionServiceSubscriptionApiClient apiClient;
  final SubscriptionServiceSubscriptionDataProvider dataProvider;
  final SubsServiceCardsDataProvider cardsDataProvider;
  final StreamController<(int, int)> cardsNumberStreamController;

  SubscriptionService(
      {required this.apiClient,
      required this.dataProvider,
      required this.cardsDataProvider,
      // required this.subsToDeleteDataProvider,
      // required this.userNameStorage,
      required this.cardsNumberStreamController});

  Future<Either<RewildError, bool>> subscriptionsIsNotEmpty() async {
    final subsEither = await dataProvider.get();
    if (subsEither.isRight()) {
      return right(subsEither
          .fold((l) => throw UnimplementedError(), (r) => r)
          .isNotEmpty);
    }
    final subs = subsEither.fold((l) => throw UnimplementedError(), (r) => r);
    for (var sub in subs) {
      if (DateTime.parse(sub.endDate).isAfter(DateTime.now())) {
        return right(true);
      }
    }

    return right(false);
  }

  @override
  Future<Either<RewildError, SubscriptionV2Response>> getSubscription(
      {required String token}) async {
    // get subscriptions from server
    final subscriptionsfromServerEither =
        await apiClient.getSubscriptionV2(token: token);
    if (subscriptionsfromServerEither is Left) {
      return left(subscriptionsfromServerEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }
    final subscriptionsfromServer = subscriptionsfromServerEither.fold(
        (l) => throw UnimplementedError(), (r) => r);

    // update local subscriptions

    final voidEither = await _syncSubscriptions(subscriptionsfromServer);
    if (voidEither is Left) {
      return voidEither.fold((l) => left(l), (r) => throw UnimplementedError());
    }
    // final now = DateTime.now();
    return right(subscriptionsfromServer);
  }

  @override
  Future<Either<RewildError, void>> addCardsToSubscription({
    required String token,
    required List<CardToSubscription> cards,
  }) async {
    final apiResult =
        await apiClient.addCardsToSubscription(token: token, cards: cards);
    if (apiResult.isLeft()) {
      return apiResult; // If the API deletion fails, return the error
    }

    final cardsIds = apiResult.fold(
        (l) => throw UnimplementedError(), (r) => r.subscriptionCardIds);

    final res = await _syncCardsSubscriptions(cardsIds);
    if (res.isLeft()) {
      return res;
    }
    return right(null); // Return success
  }

  @override
  Future<Either<RewildError, List<int>>> getCardsIds() async {
    final res = await cardsDataProvider.getAllIds();
    if (res.isLeft()) {
      return res;
    }
    return right(res.fold((l) => throw UnimplementedError(), (r) => r));
  }

  @override
  Future<Either<RewildError, void>> removeCardsFromSubscription(
      {required String token, required List<int> cardIds}) async {
    // Delete from API client
    final apiResult = await apiClient.removeCardsFromSubscription(
        token: token, skus: cardIds);
    if (apiResult.isLeft()) {
      return apiResult; // If the API deletion fails, return the error
    }
    final apiSubsResp =
        apiResult.fold((l) => throw UnimplementedError(), (r) => r);

    final res = await _syncCardsSubscriptions(apiSubsResp.subscriptionCardIds);
    if (res.isLeft()) {
      return res;
    }
    return right(null); // Return success
  }

  Future<Either<RewildError, void>> _syncSubscriptions(
      SubscriptionV2Response sub) async {
    // Get subscriptions from API client

    // If the API returns no error, delete all local subscriptions
    await dataProvider.deleteAll();
    // Save subscriptions to local data provider

    final saveResult = await dataProvider.save(sub);
    if (saveResult.isLeft()) {
      return saveResult;
    }

    // _addSubsToStream(subs);
    return right(null);
  }

  Future<Either<RewildError, void>> _syncCardsSubscriptions(
      List<int> skus) async {
    // Get subscriptions from API client

    // If the API returns no error, delete all local subscriptions
    await cardsDataProvider.deleteAll();
    // Save subscriptions to local data provider

    final saveResult = await cardsDataProvider.addAllIds(skus);
    if (saveResult.isLeft()) {
      return saveResult;
    }

    // _addSubsToStream(subs);
    return right(null);
  }

  // void _addSubsToStream(List<SubscriptionV2Response> subs) {
  //   final now = DateTime.now();
  //   final activeSubs =
  //       subs.where((element) => now.isBefore(DateTime.parse(element.endDate)));
  //   final totalSubsLength = activeSubs.length;
  //   final takenSubsLength =
  //       activeSubs.where((element) => element.cardId != 0).length;
  //   cardsNumberStreamController.add((totalSubsLength, takenSubsLength));
  // }

  @override
  Future<Either<RewildError, AddSubscriptionV2Response>> createSubscriptions({
    required String token,
    required List<int> cardIds,
    required String startDate,
    required String endDate,
  }) async {
    // Create subscriptions in the API client
    final allSubsOnServerEither = await apiClient.addSubscriptionV2(
        token: token,
        subscriptionType: "Premium",
        startDate: startDate,
        endDate: endDate);
    if (allSubsOnServerEither.isLeft()) {
      return left(allSubsOnServerEither.fold(
          (l) => l,
          (r) =>
              throw UnimplementedError())); // If API creation fails, return the error
    }
    final allSubscriptionsOnServer =
        allSubsOnServerEither.fold((l) => throw UnimplementedError(), (r) => r);
    // Save all server`s subscriptions to the local data provider
    // List<SubscriptionModel> allSubscriptionsFromServer = [];

    // TODO add sync
    // final res = await _syncSubscriptions(allSubscriptionsOnServer);
    // if (res.isLeft()) {
    //   return res.fold((l) => left(l), (r) => throw UnimplementedError());
    // }
    return right(
        allSubscriptionsOnServer); // Return the list of saved subscriptions
  }

  // @override
  // Future<Either<RewildError, List<SubscriptionModel>>> addZeroSubscriptions({
  //   required String token,
  //   required int qty,
  //   required String startDate,
  //   required String endDate,
  // }) async {
  //   // Create subscriptions in the API client
  //   final allSubsOnServerEither = await apiClient.addZeroSubscriptions(
  //       token: token, qty: qty, startDate: startDate, endDate: endDate);
  //   if (allSubsOnServerEither.isLeft()) {
  //     return allSubsOnServerEither; // If API creation fails, return the error
  //   }

  //   final allSubscriptionsOnServer =
  //       allSubsOnServerEither.fold((l) => throw UnimplementedError(), (r) => r);

  //   // Save all server`s subscriptions to the local data provider
  //   List<SubscriptionModel> allSubscriptionsFromServer = [];

  //   final res = await _syncSubscriptions(allSubscriptionsOnServer);
  //   if (res.isLeft()) {
  //     return res.fold((l) => left(l), (r) => throw UnimplementedError());
  //   }

  //   return right(
  //       allSubscriptionsFromServer); // Return the list of saved subscriptions
  // }

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
