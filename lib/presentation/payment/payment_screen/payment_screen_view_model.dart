import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';

import 'package:rewild_bot_front/domain/entities/payment_info.dart';
import 'package:rewild_bot_front/domain/entities/prices.dart';
import 'package:rewild_bot_front/domain/entities/subscription_api_models.dart';
import 'package:rewild_bot_front/domain/entities/subscription_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// Token
abstract class PaymentScreenTokenService {
  Future<Either<RewildError, String>> getToken();
}

// Subscriptions
abstract class PaymentScreenSubscriptionsService {
  Future<Either<RewildError, SubscriptionV2Response>> getSubscription(
      {required String token});
  Future<Either<RewildError, AddSubscriptionV2Response>> createSubscriptions({
    required String token,
    required List<int> cardIds,
    required String startDate,
    required String endDate,
  });
}

// Price
abstract class PaymentScreenPriceService {
  Future<Either<RewildError, Prices>> getPrice(String token);
}

// Cards
abstract class PaymentScreenCardsService {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]);
}

class PaymentScreenViewModel extends ResourceChangeNotifier {
  final List<int> cardNmIds;
  final PaymentScreenSubscriptionsService subService;
  final PaymentScreenPriceService paymentStoreService;
  final PaymentScreenCardsService cardService;

  final PaymentScreenTokenService tokenService;
  PaymentScreenViewModel({
    required this.cardNmIds,
    required this.subService,
    required this.cardService,
    required this.paymentStoreService,
    required this.tokenService,
    required super.context,
  }) {
    _asyncInit();
  }

  _asyncInit() async {
    setIsLoading(true);

    cardCount = cardNmIds.length;

    final values = await Future.wait([
      fetch(() => tokenService.getToken()),
      fetch(() => cardService.getAll(cardNmIds))
    ]);

    final token = values[0] as String?;
    if (token == null) {
      return;
    }
    final cardsFromLocalStorage = values[1] as List<CardOfProductModel>?;
    if (cardsFromLocalStorage != null) {
      _cards = cardsFromLocalStorage;
    }

    final savedSubscription =
        await fetch(() => subService.getSubscription(token: token));
    if (savedSubscription != null) {
      // TODO modify to use info about saved and not saved cards
      // _subscriptions = savedSubscriptions;
      // _emptySubscriptions =          savedSubscriptions.where((e) => e.cardId == 0).toList();
      if (savedSubscription.subscriptionTypeName == "Premium") {
        setTypeOfUserSubscriptions(3);
      } else if (savedSubscription.subscriptionTypeName == "Paid") {
        setTypeOfUserSubscriptions(2);
      } else if (savedSubscription.subscriptionTypeName == "Free") {
        setTypeOfUserSubscriptions(1);
      }
    }

    // Price
    final fetchedPrice = await fetch(() => paymentStoreService.getPrice(token));
    if (fetchedPrice != null) {
      setPrice(fetchedPrice);
      setSubscriptions(fetchedPrice);
    }

    setIsLoading(false);
  }

  // subscriptions
  List<SubscriptionModel> _subscriptions = [];

  // type of user subscriptions
  int _typeOfUserSubscriptions = 0;
  int get typeOfUserSubscriptions => _typeOfUserSubscriptions;
  void setTypeOfUserSubscriptions(int value) {
    _typeOfUserSubscriptions = value;
    notify();
  }

  int _activeIndex = 0;
  int get activeIndex => _activeIndex;
  void setActive(int value) {
    _activeIndex = value;
    notify();
  }

  // fetched prices
  Prices? _price;
  Prices? get price => _price;
  void setPrice(Prices value) {
    _price = value;
    notify();
  }

  final units = [
    [
      'Отслеживание 20 карточек',
      'Генерация текста GigaChat Lite+ 40000 токенов',
      'Дополнительные инструменты и функции'
    ],
    [
      'Отслеживание 50 карточек',
      'Генерация текста GigaChat Lite+ 80000 токенов',
      'Дополнительные инструменты и функции'
    ],
    [
      'Отслеживание 100 карточек',
      'Генерация текста GigaChat Lite+ 120000 токенов',
      'Дополнительные инструменты и функции'
    ],
  ];
  List<Map<String, dynamic>> _subscriptionsInfo = [];
  List<Map<String, dynamic>> get subscriptionsInfo => _subscriptionsInfo;
  void setSubscriptions(Prices value) {
    final typeOfUserSubscriptions = _subscriptions.length > 50
        ? 3
        : _subscriptions.length > 20
            ? 2
            : 1;
    _subscriptionsInfo = [];

    _subscriptions.sort(
      (a, b) => a.endDate.compareTo(b.endDate),
    );

    _subscriptionsInfo.add({
      'title': 'Базовый',
      'price': '₽${value.price1}',
      'units': ['Отслеживание 20 карточек']
    });
    _subscriptionsInfo.add({
      'title': 'Расширенный',
      'price': '₽${value.price2}',
      'units': ['Отслеживание 50 карточек']
    });
    _subscriptionsInfo.add({
      'title': 'Премиум',
      'price': '₽${value.price3}',
      'units': ['Отслеживание 100 карточек']
    });
    setActive(typeOfUserSubscriptions - 1);
    if (_subscriptions.isEmpty) {
      notify();
      return;
    }
    if (typeOfUserSubscriptions == 3) {
      _subscriptionsInfo[2]['endDate'] =
          formatDate(_subscriptions.first.endDate);
    } else if (typeOfUserSubscriptions == 2) {
      _subscriptionsInfo[1]['endDate'] =
          formatDate(_subscriptions.first.endDate);
    } else if (typeOfUserSubscriptions == 1) {
      _subscriptionsInfo[0]['endDate'] =
          formatDate(_subscriptions.first.endDate);
    }
    notify();
  }

  // Payment
  String customerKey = '';
  int amount = 0;
  ValueNotifier<bool> threeDs = ValueNotifier<bool>(false);
  ValueNotifier<bool> threeDsV2Frictionless = ValueNotifier<bool>(false);
  ValueNotifier<bool> threeDsV2Challenge = ValueNotifier<bool>(false);
  ValueNotifier<String?> status = ValueNotifier<String?>('');
  ValueNotifier<String?> cardType = ValueNotifier<String?>('');
  int? lastPaymentId;

  bool _isLoading = false;
  void setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  bool get isLoading => _isLoading;

  bool _success = false;
  void setSuccess(bool value) {
    _success = value;
    notify();
  }

  bool get success => _success;

  List<CardOfProductModel> _cards = [];
  List<CardOfProductModel> get cards => _cards;
  int cardCount = 0;
  int difBetweenNewcardsAndEmpty = 0;
  List<SubscriptionModel>? _emptySubscriptions = [];
  int get emptySubscriptionsLength =>
      _emptySubscriptions == null ? 0 : _emptySubscriptions!.length;

  // int _price = 0;
  // int get price => _price;
  // int get totalCost => (cardNmIds.length - emptySubscriptionsLength) * _price;
  bool _isProcessing = false;

  void setIsProcesing(bool value) {
    _isProcessing = value;
    notify();
  }

  bool get isProcessing => _isProcessing;

  // There are several (three) types of subscriptions
  // each differs in the number of cards
  void processPayment() async {
    if (price == null) {
      return;
    }

    DateTime endDate = DateTime.now().add(const Duration(days: 30));
    // at first we need to get all early subscribed cards ids
    final earlySubscribedCardsIds =
        _subscriptions.map((element) => element.cardId);

    // then get all cards that are early subscribed
    final allSubscribedCards = _cards
        .where((element) => earlySubscribedCardsIds.contains(element.nmId))
        .toList();

    // then get num of cards to add
    // hardcoded for now
    int cardsToAddNum = activeIndex == 0
        ? 20
        : activeIndex == 1
            ? 50
            : 100;
    // Set up cards for different variants
    List<CardOfProductModel> cardsToAdd = [];
    // the user has not subscribed early
    if (allSubscribedCards.isEmpty) {
      // then add empty cards with end dates month later
      for (int i = 0; i < cardsToAddNum; i++) {
        cardsToAdd.add(CardOfProductModel(
          nmId: 0,
          name: '',
        ));
      }

      // the user has subscribed early and new subscription higher than early subscription
    } else if (allSubscribedCards.length < cardsToAddNum) {
      // then add empty cards with end dates month later
      for (int i = 0; i < cardsToAddNum - allSubscribedCards.length; i++) {
        cardsToAdd.add(CardOfProductModel(
          nmId: 0,
          name: '',
        ));
      }
      // and add subscribed cards
      cardsToAdd.addAll(allSubscribedCards);
    }
    // the user has subscribed early and new subscription lower than early subscription
    else if (allSubscribedCards.length > cardsToAddNum) {
      // get random cards from early subscribed
      cardsToAdd
          .addAll(allSubscribedCards.skip(0).take(cardsToAddNum).toList());
    }
    // the user has subscribed early and new subscription equal to early subscription
    else if (allSubscribedCards.length == cardsToAddNum) {
      cardsToAdd.addAll(allSubscribedCards);
    }
    if (_subscriptions.isNotEmpty) {
      // sort _subscriptions by end date
      _subscriptions.sort((a, b) => a.endDate.compareTo(b.endDate));
      final prevEndDate = _subscriptions[0].endDate;
      //  parse prev end date and add 30 days
      endDate =
          DateTime.parse(prevEndDate.toString()).add(const Duration(days: 30));
    }

    final res = await Navigator.of(context).pushNamed(
        MainNavigationRouteNames.paymentWebView,
        arguments: PaymentInfo(
            amount: activeIndex == 0
                ? price!.price1
                : activeIndex == 1
                    ? price!.price2
                    : price!.price3,
            description:
                'Тариф «${_subscriptionsInfo[_activeIndex]['title']}» на 1 мес.',
            endDate: endDate,
            cards: cardsToAdd));
    if (res == true) {
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }
  // }
}
