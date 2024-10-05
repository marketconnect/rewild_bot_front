// card
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/constants/api_key_constants.dart';

import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/advert_base.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/subscription_api_models.dart';

import 'package:rewild_bot_front/domain/entities/stream_advert_event.dart';

import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// import 'package:rewild_bot_front/domain/entities/hive/subscription_model.dart';
// card
abstract class MainNavigationCardService {
  Future<Either<RewildError, int>> count();
}

// token for update
abstract class MainNavigationAuthService {
  Future<Either<RewildError, String>> getToken();
}

// update
abstract class MainNavigationUpdateService {
  Future<Either<RewildError, void>> update(String token);
}

// question
abstract class MainNavigationQuestionService {
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, String?>> getUsername();
}

// subscription
abstract class MainNavigationSubscriptionService {
  Future<Either<RewildError, SubscriptionV2Response>> getSubscription(
      {required String token});

  Future<Either<RewildError, List<CardOfProductModel>>> getSubscribedCardsIds(
      String token);
}

// advert
abstract class MainNavigationAdvertService {
  Future<Either<RewildError, List<Advert>>> getAllAdverts(
      {required String token});
  Future<Either<RewildError, String?>> getApiKey();
  Future<Either<RewildError, int>> getBudget(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> checkAdvertIsActive(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> stopAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> startAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, int?>> getBallance({required String token});
}

class MainNavigationViewModel extends ResourceChangeNotifier {
  final MainNavigationCardService cardService;
  final MainNavigationAdvertService advertService;
  final MainNavigationQuestionService questionService;
  final MainNavigationAuthService tokenProvider;
  final MainNavigationUpdateService updateService;
  final MainNavigationSubscriptionService subscriptionService;
  final Stream<(int, int)> cardsNumberStream;
  final Stream<StreamAdvertEvent> updatedAdvertStream;
  final Stream<Map<ApiKeyType, String>> apiKeyExistsStream;

  MainNavigationViewModel(
      {required this.cardService,
      required this.advertService,
      required this.questionService,
      required this.tokenProvider,
      required this.updateService,
      required this.cardsNumberStream,
      required this.updatedAdvertStream,
      required this.apiKeyExistsStream,
      required this.subscriptionService,
      required super.context}) {
    _asyncInit();
  }

  Future<String> _getToken() async {
    final token = await fetch(() => tokenProvider.getToken());
    if (token == null) {
      return "";
    }
    return token;
  }

  void _asyncInit() async {
    final token = await _getToken();
    await updateService.update(token);
    // Update in MainNavigationCardsWidget cards number
    cardsNumberStream.listen((event) {
      setSubscriptionsNum(event.$1);
      setTrackedCardsNumber(event.$2);
      notify();
    });

    // Update in MainNavigationAdvertViewModel EmptyWidget or not
    apiKeyExistsStream.listen((event) {
      if (event[ApiKeyType.promo] != null) {
        setAdvertApiKey(
            event[ApiKeyType.promo] == "" ? null : event[ApiKeyType.promo]);
      } else if (event[ApiKeyType.question] != null) {
        setFeedbackApiKey(event[ApiKeyType.question] == ""
            ? null
            : event[ApiKeyType.question]);
      }
      notify();
    });

    // Update in MainNavigationAdvertScreen status of _AllAdvertsWidget
    updatedAdvertStream.listen((event) async {
      if (event.status != null) {
        final oldAdverts =
            _adverts.where((a) => a.campaignId == event.campaignId);
        if (oldAdverts.isEmpty) {
          return;
        }
        final newAdvert = oldAdverts.first.copyWith(status: event.status);
        updateAdvert(newAdvert);
      }

      notify();
    });

    // multiple
    final value = await Future.wait([
      fetch(() => subscriptionService.getSubscription(token: token)),
      fetch(() => subscriptionService.getSubscribedCardsIds(token)),
      fetch(() => advertService.getApiKey()),
      fetch(() => questionService.getApiKey()),
    ]);
    final subscriptions = value[0] as SubscriptionV2Response?;
    if (subscriptions == null) {
      return;
    }

    setSubscriptionsNum(subscriptions.cardLimit);

    // get added cards quantity
    final cardsQtyOrNull = value[1] as List<CardOfProductModel>?;
    if (cardsQtyOrNull == null) {
      return;
    }

    setTrackedCardsNumber(cardsQtyOrNull.length);

    // setTrackedCardsNumber(subscriptions.where((element) => element.cardId != 0).toList().length);

    // Api keys exist
    // Advert

    final advertApiKey = value[2] as String?;
    if (advertApiKey == null) {
      return;
    }
    setAdvertApiKey(advertApiKey);

    // depends on advertApiKey
    final newAdverts =
        await fetch(() => advertService.getAllAdverts(token: _advertApiKey!));
    if (newAdverts == null) {
      return;
    }
    // Question

    final questionApiKey = value[3] as String?;
    if (questionApiKey == null) {
      return;
    }

    setFeedbackApiKey(questionApiKey);

    notify();
  } // _asyncInit

  // balance
  int? _balance;
  void setBalance(int? value) {
    _balance = value;
  }

  int? get balance => _balance;

  // cards num
  int _trackedCardsNumber = 0;
  void setTrackedCardsNumber(int value) {
    _trackedCardsNumber = value;
    notify();
  }

  int get trackedCardsNumber => _trackedCardsNumber;

  // subscription
  int? _subscriptionsNum;
  void setSubscriptionsNum(int value) {
    _subscriptionsNum = value;
    notify();
  }

  int? get subscriptionsNum => _subscriptionsNum;

  // Adverts
  List<Advert> _adverts = [];
  void setAdverts(List<Advert> value) {
    _adverts = value;
    notify();
  }

  void updateAdvert(Advert advert) {
    _adverts.removeWhere((element) => element.campaignId == advert.campaignId);
    _adverts.insert(0, advert);
    notify();
  }

  List<Advert> get adverts => _adverts;

  // budget
  Map<int, int> _budget = {};
  void setBudget(Map<int, int> value) {
    _budget = value;
  }

  void addBudget(int advId, int value) {
    _budget[advId] = value;
  }

  Map<int, int> get budget => _budget;

  bool _isLoading = false;
  void setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  bool get isLoading => _isLoading;

  Future<void> updateAdverts() async {
    setIsLoading(true);
    if (_advertApiKey == null) {
      return;
    }
    final balance =
        await fetch(() => advertService.getBallance(token: _advertApiKey!));
    if (balance == null) {
      return;
    }
    setBalance(balance);
    notify();

    final newAdverts =
        await fetch(() => advertService.getAllAdverts(token: _advertApiKey!));
    if (newAdverts == null) {
      return;
    }
    setAdverts(newAdverts);

    for (final advert in _adverts) {
      final budget = await fetch(() => advertService.getBudget(
          token: _advertApiKey!, campaignId: advert.campaignId));
      if (budget != null) {
        addBudget(advert.campaignId, budget);
        notify();
      }
    }
    setIsLoading(false);
  }

  // ApiKeysExists
  String? _advertApiKey;
  void setAdvertApiKey(String? value) {
    _advertApiKey = value;
  }

  bool get advertApiKeyExists => _advertApiKey != null;

  String? _feedbackApiKey;
  void setFeedbackApiKey(String? value) {
    _feedbackApiKey = value;
  }

  bool get feedbackApiKeyExists => _feedbackApiKey != null;

  // Home screen feedBack
  Future<String> userName() async {
    var userName = await fetch(() => questionService.getUsername());
    userName ??= "anonymous";
    return userName;
  }

  Future<void> goToSubscriptionsScreeen(BuildContext context) async {
    final res = await Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.paymentScreen);

    if (res == true) {
      // subscription
      final token = await _getToken();
      final subscription =
          await fetch(() => subscriptionService.getSubscription(token: token));
      if (subscription == null) {
        return;
      }

      setSubscriptionsNum(subscription.cardLimit);
    }
  }
}
