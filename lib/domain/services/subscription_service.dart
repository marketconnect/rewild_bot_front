import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/subscription_api_models.dart';
import 'package:rewild_bot_front/domain/entities/user_auth_data.dart';

import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild_bot_front/presentation/payment/payment_screen/payment_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/payment/payment_web_view/payment_webview_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/notification_card_screen/notification_card_view_model.dart';

// Api
abstract class SubscriptionServiceSubscriptionApiClient {
  Future<Either<RewildError, SubscriptionV2Response>> updateSubscriptionV2({
    required String token,
    required int subscriptionID,
    required String subscriptionType,
    required String startDate,
    required String endDate,
  });
  Future<Either<RewildError, SubscriptionV2Response>> getSubscriptionV2({
    required String token,
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
}

// Cards Api Client
abstract class SubsServiceCardsApiClient {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll({
    required String token,
  });
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

abstract class SubscriptionServiceSecureDataProvider {
  Future<Either<RewildError, void>> updateUserInfo(
      {String? token, String? expiredAt, bool? freebie});
}

// When the app starts it fetches subscriptions from the server
// and saves them in the local database.
// Then it uses local database to fetch subscriptions (getSubscriptionLocal method).
class SubscriptionService
    implements
        PaymentScreenSubscriptionsService,
        NotificationCardSubscriptionService,
        PaymentWebViewSubscriptionsService,
        MainNavigationSubscriptionService,
        AllCardsScreenSubscriptionsService {
  final SubscriptionServiceSubscriptionApiClient apiClient;
  final SubscriptionServiceSubscriptionDataProvider subsDataProvider;
  final SubsServiceCardsDataProvider cardsDataProvider;
  final StreamController<(int, int)> cardsNumberStreamController;
  final SubsServiceCardsApiClient cardsApiClient;
  final SubscriptionServiceSecureDataProvider secureDataProvider;
  SubscriptionService(
      {required this.apiClient,
      required this.subsDataProvider,
      required this.cardsApiClient,
      required this.cardsDataProvider,
      required this.secureDataProvider,
      required this.cardsNumberStreamController});
  // Initialization of the service
  // synchronize subscriptions with local data provider
  // // synchronize cards with local data provider
  // Future<void> _asyncInit() async {
  //   await _syncSubscriptions();
  // }

  @override

  /// Update subscription on server and in local db
  /// Return either [RewildError] if error occurred or [SubscriptionV2Response] of updated subscription
  Future<Either<RewildError, SubscriptionV2Response>> updateSubscription({
    required String token,
    required int subscriptionID,
    required String subscriptionType,
    required String startDate,
    required String endDate,
  }) async {
    // Create subscriptions in the API client
    final subOnServerEither = await apiClient.updateSubscriptionV2(
        subscriptionID: subscriptionID,
        token: token,
        subscriptionType: subscriptionType,
        startDate: startDate,
        endDate: endDate);
    if (subOnServerEither.isLeft()) {
      return left(subOnServerEither.fold(
          (l) => l,
          (r) =>
              throw UnimplementedError())); // If API creation fails, return the error
    }
    final subscriptionOnServer =
        subOnServerEither.fold((l) => throw UnimplementedError(), (r) => r);

    await _saveAuthData(UserAuthData(
        token: subscriptionOnServer.token,
        freebie: true,
        expiredAt: subscriptionOnServer.expiredAt));
    final res = await _syncSubscriptions(subscriptionOnServer);
    if (res.isLeft()) {
      return res.fold((l) => left(l), (r) => throw UnimplementedError());
    }
    return right(
        subscriptionOnServer); // Return the list of saved subscriptions
  }

  @override

  /// Get local subscription
  /// Return either [RewildError] if error occurred or [SubscriptionV2Response]
  /// of local subscription. If there are no subscriptions, return null.
  Future<Either<RewildError, SubscriptionV2Response>> getLocalSubscription(
      {required String token}) async {
    final subscriptions = await subsDataProvider.get();
    if (subscriptions.isLeft()) {
      return left(
          subscriptions.fold((l) => l, (r) => throw UnimplementedError()));
    }

    final subs =
        subscriptions.fold((l) => throw UnimplementedError(), (r) => r);
    if (subs.isEmpty) {
      final subs = await getSubscription(token: token);
      if (subs.isLeft()) {
        return left(subs.fold((l) => l, (r) => throw UnimplementedError()));
      }

      return right(subs.fold((l) => throw UnimplementedError(), (r) => r));
    }
    return right(subs.first);
  }

  /// Get subscription from server and update local subscriptions
  /// Return either [RewildError] if error occurred or [SubscriptionV2Response]
  /// of updated subscription.
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
    await _saveAuthData(UserAuthData(
        token: subscriptionsfromServer.token,
        freebie: true,
        expiredAt: subscriptionsfromServer.expiredAt));
    // update local subscriptions
    final voidEither = await _syncSubscriptions(subscriptionsfromServer);
    if (voidEither is Left) {
      return voidEither.fold((l) => left(l), (r) => throw UnimplementedError());
    }
    // final now = DateTime.now();
    return right(subscriptionsfromServer);
  }

  @override

  /// Add cards to subscription on server and in local db
  ///
  /// Return either [RewildError] if error occurred or [void] if success
  Future<Either<RewildError, void>> addCardsToSubscription({
    required String token,
    required List<CardOfProductModel> cardModels,
  }) async {
    List<CardToSubscription> cards = [];
    for (final card in cardModels) {
      cards.add(
          CardToSubscription(image: card.img, name: card.name, sku: card.nmId));
    }
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

  /// Get a list of IDs of cards that are subscribed from local db
  ///
  /// Return either [RewildError] if error occurred or [List<int>] of IDs of cards with active subscriptions
  Future<Either<RewildError, List<CardOfProductModel>>> getSubscribedCardsIds(
      String token) async {
    final res = await cardsApiClient.getAll(token: token);
    if (res.isLeft()) {
      return res;
    }

    _syncCardsSubscriptions(res.fold((l) => throw UnimplementedError(),
        (r) => r.map((e) => e.nmId).toList()));

    return right(res.fold((l) => throw UnimplementedError(), (r) => r));
  }

  @override

  /// Remove cards from subscription on server and in local db
  ///
  /// Return either [RewildError] if error occurred or [void] if success
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

  /// Synchronize subscriptions with local data provider
  /// Return either [RewildError] if error occurred or [void] if success
  /// This function is not exposed in the public API of the service and is supposed to be used internally.
  /// [sub] is the subscription to be saved
  Future<Either<RewildError, void>> _syncSubscriptions(
      SubscriptionV2Response sub) async {
    await subsDataProvider.deleteAll();

    // Save subscriptions to local data provider

    final saveResult = await subsDataProvider.save(sub);
    if (saveResult.isLeft()) {
      return saveResult;
    }

    // _addSubsToStream(subs);
    return right(null);
  }

  /// Synchronize subscribed cards ids with local db
  /// Return either [RewildError] if error occurred or [void] if success
  /// This function is not exposed in the public API of the service and is supposed to be used internally.
  /// [skus] is the list of card IDs to be saved
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

  Future<Either<RewildError, void>> _saveAuthData(UserAuthData authData) async {
    final token = authData.token;
    final freebie = authData.freebie;
    final expiredAt = authData.expiredAt;
    final saveEither = await secureDataProvider.updateUserInfo(
      token: token,
      expiredAt: expiredAt.toString(),
      freebie: freebie,
    );
    if (saveEither.isLeft()) {
      return left(saveEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    return right(null);
  }
}
