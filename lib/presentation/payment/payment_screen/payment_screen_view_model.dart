import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/subsciption_constants.dart';

import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/payment_info.dart';
import 'package:rewild_bot_front/domain/entities/prices.dart';
import 'package:rewild_bot_front/domain/entities/subscription_api_models.dart';

import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// Token
abstract class PaymentScreenTokenService {
  Future<Either<RewildError, String>> getToken();
}

// Subscriptions
abstract class PaymentScreenSubscriptionsService {
  Future<Either<RewildError, SubscriptionV2Response?>> getSubscription(
      {required String token});
  Future<Either<RewildError, SubscriptionV2Response>> updateSubscription({
    required String token,
    required int subscriptionID,
    required String subscriptionType,
    required String startDate,
    required String endDate,
  });
}

// Price
abstract class PaymentScreenPriceService {
  Future<Either<RewildError, Prices>> getPrice(String token);
}

class PaymentScreenViewModel extends ResourceChangeNotifier {
  final PaymentScreenSubscriptionsService subService;
  final PaymentScreenPriceService paymentStoreService;

  final PaymentScreenTokenService tokenService;
  PaymentScreenViewModel({
    required this.subService,
    required this.paymentStoreService,
    required this.tokenService,
    required super.context,
  }) {
    _asyncInit();
  }

  _asyncInit() async {
    setIsLoading(true);

    final token = await fetch(() => tokenService.getToken());
    if (token == null) {
      return;
    }

    final savedSubscriptionOrNull =
        await fetch(() => subService.getSubscription(token: token));
    if (savedSubscriptionOrNull != null) {
      _subscription = savedSubscriptionOrNull;
      final indexOfCurrentSubscription = getSubscriptionIndexByType(
          subscriptionType: savedSubscriptionOrNull.subscriptionTypeName);

      setTypeOfUserSubscriptions(indexOfCurrentSubscription);
    }

    // Price
    final fetchedPrice = await fetch(() => paymentStoreService.getPrice(token));
    if (fetchedPrice != null) {
      setPrice(fetchedPrice);
      setSubscriptions(fetchedPrice);
    }

    setIsLoading(false);
  }

  // current subscription
  late final SubscriptionV2Response _subscription;
  int _indexOfCurrentSubscription = -1;

  int get indexOfCurrentSubscription => _indexOfCurrentSubscription;

  DateTime get currentSubscriptionEndDatePlusOneMonth =>
      DateTime.parse(_subscription.endDate).add(const Duration(days: 30));

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
      'Генерация текста OpenAI gpt-3.5-turbo 300000 токенов',
      'Дополнительные инструменты и функции'
    ],
    [
      'Отслеживание 50 карточек',
      'Генерация текста OpenAI gpt-3.5-turbo 600000 токенов',
      'Дополнительные инструменты и функции'
    ],
    [
      'Отслеживание 100 карточек',
      'Генерация текста OpenAI gpt-3.5-turbo 1000000 токенов',
      'Дополнительные инструменты и функции'
    ],
  ];
  List<Map<String, dynamic>> _subscriptionsInfo = [];
  List<Map<String, dynamic>> get subscriptionsInfo => _subscriptionsInfo;
  void setSubscriptions(Prices value) {
    final typeOfUserSubscription = getSubscriptionIndexByType(
        subscriptionType: _subscription.subscriptionTypeName);

    _subscriptionsInfo = [];
    // current subscription end date
    final currentSubscriptionEndDate = DateTime.parse(_subscription.endDate);
    final today = DateTime.now();
    final days = currentSubscriptionEndDate.difference(today).inDays;
    final currentMonthPrice =
        value.getPriceBySubscriptionType(_subscription.subscriptionTypeName);
    int unspent = 0;
    if (days > 1) {
      unspent = ((days - 1) * (currentMonthPrice / 31)).floor();
    }

    _subscriptionsInfo.add({
      'title': 'Базовый',
      'price': '₽${value.price1}',
      'units': ['Отслеживание 20 карточек']
    });
    _subscriptionsInfo.add({
      'title': 'Расширенный',
      'price':
          '₽${(typeOfUserSubscription >= 2) ? value.price2 : (value.price2 - unspent) < 300 ? 300 : (value.price2 - unspent)}',
      'units': ['Отслеживание 50 карточек']
    });
    _subscriptionsInfo.add({
      'title': 'Премиум',
      'price':
          '₽${(typeOfUserSubscription == 3) ? value.price3 : (value.price3 - unspent) < 500 ? 500 : (value.price3 - unspent)}',
      'units': ['Отслеживание 100 карточек']
    });

    setActive(typeOfUserSubscription);

    if (typeOfUserSubscription == 3) {
      _indexOfCurrentSubscription = 2;
      _subscriptionsInfo[2]['endDate'] = formatDate(_subscription.endDate);
      _subscriptionsInfo[2]['endDatePlusOneMonth'] =
          formatDate(currentSubscriptionEndDatePlusOneMonth.toIso8601String());
    } else if (typeOfUserSubscription == 2) {
      _indexOfCurrentSubscription = 1;
      _subscriptionsInfo[1]['endDate'] = formatDate(_subscription.endDate);
      _subscriptionsInfo[1]['endDatePlusOneMonth'] =
          formatDate(currentSubscriptionEndDatePlusOneMonth.toIso8601String());
    } else if (typeOfUserSubscription == 1) {
      _indexOfCurrentSubscription = 0;
      _subscriptionsInfo[0]['endDate'] = formatDate(_subscription.endDate);
      _subscriptionsInfo[0]['endDatePlusOneMonth'] =
          formatDate(currentSubscriptionEndDatePlusOneMonth.toIso8601String());
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

  int cardCount = 0;
  int difBetweenNewcardsAndEmpty = 0;

  bool _isProcessing = false;

  void setIsProcesing(bool value) {
    _isProcessing = value;
    notify();
  }

  bool get isProcessing => _isProcessing;
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  DateTime get todayPlusOneMonth => _endDate;
  void processPayment() async {
    // if prolongation subscription
    if (activeIndex == _indexOfCurrentSubscription) {
      _endDate = currentSubscriptionEndDatePlusOneMonth;
    }

    final res = await Navigator.of(context).pushNamed(
        MainNavigationRouteNames.paymentWebView,
        arguments: PaymentInfo(
            amount: _subscriptionsInfo[_activeIndex]['price'],
            description:
                'Тариф «${_subscriptionsInfo[_activeIndex]['title']}» до ${formatDate(_endDate.toIso8601String())}.',
            endDate: _endDate,
            subscriptionType: getSubscriptionTypeByIndex(index: activeIndex)));
    if (res == true) {
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }
}
