import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:rewild_bot_front/core/constants/notification_constants.dart';
import 'package:rewild_bot_front/core/constants/subsciption_constants.dart';

import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/filter_model.dart';
import 'package:rewild_bot_front/domain/entities/group_model.dart';
import 'package:rewild_bot_front/domain/entities/nm_id.dart';
import 'package:rewild_bot_front/domain/entities/notification.dart';
import 'package:rewild_bot_front/domain/entities/stream_notification_event.dart';
import 'package:rewild_bot_front/domain/entities/subscription_api_models.dart';

import 'package:rewild_bot_front/domain/entities/supply_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

abstract class AllCardsScreenTotalCostService {
  Future<Either<RewildError, Map<int, double>>> getAllGrossProfit(
      int averageLogistics);
}

// average logistics
abstract class AllCardsScreenAverageLogisticsService {
  Future<Either<RewildError, int>> getCurrentAverageLogistics(
      {required String token});
}

// Token
abstract class AllCardsScreenAuthService {
  Future<Either<RewildError, String>> getToken();
}

// Cards
abstract class AllCardsScreenCardOfProductService {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]);
  Future<Either<RewildError, List<NmId>>> getAllUserNmIds();
}

// Filter
abstract class AllCardsScreenFilterService {
  Future<Either<RewildError, FilterModel>> getCurrentFilter();
  Future<Either<RewildError, void>> deleteFilter();
}

// Groups
abstract class AllCardsScreenGroupsService {
  Future<Either<RewildError, List<GroupModel>?>> getAll([List<int>? nmIds]);
}

// Supply
abstract class AllCardsScreenSupplyService {
  Future<Either<RewildError, List<SupplyModel>?>> getForOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo});
}

// Update
abstract class AllCardsScreenUpdateService {
  Future<Either<RewildError, void>> update(String token);
  Future<Either<RewildError, void>> fetchAllUserCardsFromServer(String token);

  Future<Either<RewildError, int>> deleteLocal({required List<int> nmIds});
}

// Subscriptions
abstract class AllCardsScreenSubscriptionsService {
  Future<Either<RewildError, void>> removeCardsFromSubscription(
      {required String token, required List<int> cardIds});
  Future<Either<RewildError, SubscriptionV2Response>> getLocalSubscription(
      {required String token});
  Future<Either<RewildError, SubscriptionV2Response>> updateSubscription({
    required String token,
    required int subscriptionID,
    required String subscriptionType,
    required String startDate,
    required String endDate,
  });

  Future<Either<RewildError, SubscriptionV2Response>> getSubscription(
      {required String token});
  Future<Either<RewildError, List<CardOfProductModel>>> getSubscribedCardsIds(
      String token);
  Future<Either<RewildError, void>> addCardsToSubscription({
    required String token,
    required List<CardOfProductModel> cardModels,
  });
}

// Notifications
abstract class AllCardsScreenNotificationsService {
  Future<Either<RewildError, List<ReWildNotificationModel>>> getAll();
}

class AllCardsScreenViewModel extends ResourceChangeNotifier {
  //
  final AllCardsScreenAuthService tokenService;
  final AllCardsScreenCardOfProductService cardsOfProductsService;
  final AllCardsScreenUpdateService updateService;
  final AllCardsScreenGroupsService groupsProvider;
  final AllCardsScreenFilterService filterService;
  final AllCardsScreenTotalCostService totalCostService;
  final AllCardsScreenSupplyService supplyService;
  final AllCardsScreenNotificationsService notificationsService;
  final AllCardsScreenSubscriptionsService subscriptionsService;

  final AllCardsScreenAverageLogisticsService averageLogisticsService;
  // Stream
  Stream<StreamNotificationEvent> streamNotification;
  AllCardsScreenViewModel(
      {required super.context,
      required this.tokenService,
      required this.updateService,
      required this.groupsProvider,
      required this.filterService,
      required this.supplyService,
      required this.averageLogisticsService,
      required this.notificationsService,
      required this.totalCostService,
      required this.subscriptionsService,
      required this.streamNotification,
      required this.cardsOfProductsService}) {
    asyncInit();
  }

  final dateFormat = DateFormat('yyyy-MM-dd');

  // user`s nmIds
  List<int> _userNmIds = [];

  bool isUserNmId(int nmId) => _userNmIds.contains(nmId);
  bool get someUserNmIdIsSelected =>
      _selectedNmIds.any((element) => isUserNmId(element));
  void setUserNmIds(List<int> value) {
    _userNmIds = value;
    notify();
  }

  // selecting cards process
  bool? _selectingForPayment;
  bool? get selectingForHandle => _selectingForPayment;
  void setIsSelectingForPayment(bool value) {
    _selectingForPayment = value;
    notify();
  }

  void resetIsSelectingForPayment() {
    _selectingForPayment = null;
    notify();
  }

  // Subscription
  List<int> _missingCardIds = [];

  List<int> get missingCardIds => _missingCardIds;

  // empty subscriptions qty
  int get emptySubscriptionsQty => _emptySubscriptionsQty;
  int _emptySubscriptionsQty = 0;
  void setEmptySubscriptionsQty(int value) {
    _emptySubscriptionsQty = value;
    notify();
  }

  // loading
  bool _loading = true;

  void setLoading(bool value) {
    _loading = value;
    notify();
  }

  bool get isLoading => _loading;

  // filter
  FilterModel? _filter;
  FilterModel? get filter => _filter;

  bool _filterIsEmpty = true;
  bool get filterIsEmpty => _filterIsEmpty;

  bool _firstLoad = true;

  Future<void> asyncInit() async {
    // SqfliteService.printTableContent('subs');
    setLoading(true);

    streamNotification.listen((event) async {
      if (event.parentType == ParentType.card) {
        await _update();
      }
    });
    final userNmIdsOrNull =
        await fetch(() => cardsOfProductsService.getAllUserNmIds());
    if (userNmIdsOrNull != null) {
      setUserNmIds(userNmIdsOrNull.map((e) => e.nmId).toList());
    }
    _groups.insert(
        0,
        GroupModel(
            name: "Все",
            bgColor: const Color(0xFF6750A4).value,
            cardsNmIds: [],
            fontColor: const Color(0xFFFFFFFF).value));

    await _update(false);
    setLoading(false);

    // await p();
  }

  void checkFilter() {
    if (_filter == null) {
      _filterIsEmpty = true;
      return;
    }

    if (_filter!.subjects != null && _filter!.subjects!.isNotEmpty ||
        _filter!.brands != null && _filter!.brands!.isNotEmpty ||
        _filter!.suppliers != null && _filter!.suppliers!.isNotEmpty ||
        _filter!.promos != null && _filter!.promos!.isNotEmpty ||
        _filter!.withSales != null ||
        _filter!.withStocks != null) {
      _filterIsEmpty = false;

      return;
    }
    _filterIsEmpty = true;
  }

  Future<void> resetFilter() async {
    await fetch(() => filterService.deleteFilter());
    await _update();
  }

  List<CardOfProductModel> _productCards = [];
  List<int> get allNmIds => _productCards.map((e) => e.nmId).toList();
  void setProductCards(List<CardOfProductModel> productCards) {
    _productCards = productCards;
  }

  List<CardOfProductModel> get productCards => _productCards;

  bool _selectionInProcess = false;
  bool get selectionInProcess => _selectionInProcess;
  final List<int> _selectedNmIds = [];
  List<int> get selectedNmIds => _selectedNmIds;

  int get selectedLength => _selectedNmIds.length;

  List<GroupModel> _groups = [];
  void setGroups(List<GroupModel> groups) {
    _groups = groups;
  }

  List<GroupModel> get groups => _groups;

  GroupModel? _selectedGroup;
  GroupModel? get selectedGroup => _selectedGroup;

  Future<String> _getToken() async {
    final token = await fetch(() => tokenService.getToken());
    if (token == null) {
      return "";
    }
    return token;
  }

  Future<void> refresh() async {
    return await _update();
  }

  // Total costs
  Map<int, double> _totalCostsGrossProfit = {};

  Map<int, double> get grossProfit => _totalCostsGrossProfit;

  Future<void> _update([bool toNotify = true]) async {
    // filter
    _filter = await fetch(() => filterService.getCurrentFilter());
    if (_filter == null) {
      return;
    }
    checkFilter();
    if (!context.mounted) {
      return;
    }
    final token = await _getToken();

    await fetch(() => updateService.fetchAllUserCardsFromServer(token));

    // Update
    await fetch(() => updateService.update(token));

    // get cards
    final fetchedCardsOfProducts =
        await fetch(() => cardsOfProductsService.getAll());

    if (fetchedCardsOfProducts == null) {
      return;
    }

    List<CardOfProductModel> oldCards = List.from(_productCards);

    // reassign productCards
    if (fetchedCardsOfProducts.isNotEmpty) {
      _productCards.clear();
    }

    // tracked ids
    List<int> trackedIds = [];
    final notifications = await fetch(() => notificationsService.getAll());
    if (notifications != null) {
      for (final n in notifications) {
        if (n.condition != NotificationConditionConstants.budgetLessThan) {
          trackedIds.add(n.parentId);
        }
      }
    }
    final dateFrom = yesterdayEndOfTheDay();
    final dateTo = DateTime.now();
    // calculate stocks, initial stocks, supplies, was ordered field
    for (CardOfProductModel card in fetchedCardsOfProducts) {
      card.calculate(dateFrom, dateTo);
      final oldCard = oldCards.where((old) {
        return old.nmId == card.nmId;
      });

      // tracked
      if (trackedIds.contains(card.nmId)) {
        card.setTracked();
      }

      if (oldCard.isNotEmpty &&
          card.weekOrdersSum > oldCard.first.weekOrdersSum) {
        card.setWasOrdered();
      } else {
        card.setWasNotOrdered();
      }

      _productCards.add(card);
    }
    // sort by orders sum
    _productCards.sort((a, b) => b.weekOrdersSum.compareTo(a.weekOrdersSum));

    final fetchedGroups = await fetch(() => groupsProvider.getAll());
    final cardsNmIds = _productCards.map((card) => card.nmId).toList();
    // append groups
    if (fetchedGroups != null) {
      for (final g in fetchedGroups) {
        if (_groups.where((element) => element.name == g.name).isEmpty) {
          if (g.cardsNmIds.any((element) => cardsNmIds.contains(element))) {}
          _groups.add(g);
        }
        final cardsWithGroup =
            _productCards.where((card) => g.cardsNmIds.contains(card.nmId));
        for (final card in cardsWithGroup) {
          card.setGroup(g);
        }
      }
    }
    // Filter cards
    _productCards = _productCards.where((card) {
      return filterCard(card);
    }).toList();
    // Filter groups
    _groups = _groups.where((group) {
      if (group.name == "Все") {
        return true;
      }
      // Drop extra groups
      final cardsNmIds = _productCards.map((e) => e.nmId).toList();
      for (int id in group.cardsNmIds) {
        if (cardsNmIds.contains(id)) {
          return true;
        }
      }
      return false;
    }).toList();

    // Subscription ==========================================================

    await _handleSubscriptions(token);

    // Total costs
    int averageLogistics = 50;
    final averageLogisticsFromApiOrNull = await fetch(
        () => averageLogisticsService.getCurrentAverageLogistics(token: token));
    if (averageLogisticsFromApiOrNull != null) {
      averageLogistics = averageLogisticsFromApiOrNull;
    }
    final totalCostsGrossProfitOrNull =
        await fetch(() => totalCostService.getAllGrossProfit(averageLogistics));

    if (totalCostsGrossProfitOrNull != null) {
      _totalCostsGrossProfit = totalCostsGrossProfitOrNull;
    }

    if (!toNotify) {
      return;
    }

    notify();
  }

  Future<void> _handleSubscriptions(String token) async {
    // Get local subscription
    SubscriptionV2Response? localSubscriptionOrNull;
    // when the screen is opened get all subsribed cards
    if (_firstLoad) {
      localSubscriptionOrNull =
          await fetch(() => subscriptionsService.getSubscription(token: token));
      _firstLoad = false;
    } else {
      localSubscriptionOrNull = await fetch(
          () => subscriptionsService.getLocalSubscription(token: token));
    }
    if (localSubscriptionOrNull != null) {
      // Find subscribed card IDs
      final subscribedCardsIdsOrNull =
          await fetch(() => subscriptionsService.getSubscribedCardsIds(token));

      if (subscribedCardsIdsOrNull == null) {
        return;
      }
      // for (int id in subscribedCardsIdsOrNull) {
      //   print("susbcribed id: $id");
      // }
      final subscribedCardsIds =
          subscribedCardsIdsOrNull.map((el) => el.nmId).toList();
      // Get missing card IDs
      _missingCardIds = _productCards
          .where((card) => !subscribedCardsIds.contains(card.nmId))
          .map((card) => card.nmId)
          .toList();
      for (int id in _missingCardIds) {
        print("missing id: $id");
      }

      for (int id in subscribedCardsIds) {
        print("subscribed id: $id");
      }
      // get subscription limit
      final subCardsQtyLimit = getSubscriptionLimit(
          subscriptionTypeName: localSubscriptionOrNull.subscriptionTypeName);

      // Set empty subscriptions qty
      setEmptySubscriptionsQty(
          subCardsQtyLimit - subscribedCardsIdsOrNull.length);
    }
  }

  // Future<void> p() async {
  //   const timeDuration = TimeConstants.updatePeriod;

  //   Timer.periodic(timeDuration, (Timer t) async {
  //     if (!context.mounted) {
  //       return;
  //     }

  //     await _update();
  //   });
  // }

  void onCardTap(int nmId) {
    // If there are no selected cards and the card is paid or user`s, open single card screen
    if (_selectedNmIds.isEmpty &&
        (!_missingCardIds.contains(nmId) || isUserNmId(nmId))) {
      Navigator.of(context).pushNamed(
        MainNavigationRouteNames.singleCardScreen,
        arguments: nmId,
      );
      return;
    }

    _select(nmId);
    notifyListeners();
  }

  void onCardLongPress(int index) {
    _select(index);
    notifyListeners();
  }

  // Future<void> deleteUnsubscribedCards() async {
  //   // delete cards
  //   await fetch(() => updateService.deleteLocal(nmIds: _missingCardIds));
  // }

  Future<void> deleteCards() async {
    List<int> idsForDelete = [];
    for (final nmId in _selectedNmIds) {
      final deletedCardList =
          _productCards.where((element) => element.nmId == nmId);
      if (deletedCardList.isEmpty) {
        continue;
      }
      final deletedCard = deletedCardList.first;
      _productCards.remove(deletedCard);
      idsForDelete.add(deletedCard.nmId);
    }

    onClearSelected();

    final token = await _getToken();

    // delete cards
    // await fetch(() => updateService.delete(token: token, nmIds: idsForDelete));
    // delete subscriptions
    await fetch(() => subscriptionsService.removeCardsFromSubscription(
        token: token, cardIds: idsForDelete));
    await fetch(() => updateService.deleteLocal(nmIds: idsForDelete));
    _update();
  }

  void onClearSelected() {
    resetIsSelectingForPayment();
    _selectedNmIds.clear();
    _selectionInProcess = false;
    notifyListeners();
  }

  void combine() {
    // Navigator.of(context).pushReplacementNamed(
    //   MainNavigationRouteNames.addGroupsScreen,
    //   arguments: _selectedNmIds,
    // );
  }

  Future<void> track() async {
    final ids = _selectedNmIds.toList();
    final selectedCardModels =
        _productCards.where((element) => ids.contains(element.nmId));

    if (selectedCardModels.isEmpty) {
      return;
    }

    // Token
    final token = await fetch(() => tokenService.getToken());
    if (token == null) {
      return;
    }

    onClearSelected();
    final result = await subscriptionsService.addCardsToSubscription(
      token: token,
      cardModels: selectedCardModels.toList(),
    );
    if (result.isLeft()) {
      return;
    }

    // putOnServerNewCards returns void so fetch is not used here
    // final cardsResult = await updateService.putOnServerNewCards(
    //   token: token,
    //   cardOfProductsToPutOnServer: selectedCardModels.toList(),
    // );
    // if (cardsResult is Left) {
    //   return;
    // }

    await _handleSubscriptions(token);
  }

  void _select(int nmId) {
    if (_selectingForPayment == null) {
      final selectedCardWithoutSubscription = _missingCardIds.contains(nmId);
      setIsSelectingForPayment(selectedCardWithoutSubscription);
    }

    bool found = _selectedNmIds.contains(nmId);
    if (found) {
      _selectedNmIds.remove(nmId);
    } else {
      _selectedNmIds.add(nmId);
    }
    if (_selectedNmIds.isNotEmpty) {
      _selectionInProcess = true;
    } else {
      _selectionInProcess = false;
    }
    if (_selectedNmIds.isEmpty) {
      resetIsSelectingForPayment();
    }
  }

  void selectGroup(int index) {
    if (index == 0) {
      _selectedGroup = null;
    } else {
      _selectedGroup = _groups[index];
    }
    notifyListeners();
  }

  bool filterCard(CardOfProductModel card) {
    if (_filter == null) {
      return true;
    }

    // check subject
    if (_filter!.subjects != null && _filter!.subjects!.isNotEmpty) {
      final found = _filter!.subjects!.keys.contains(card.subjectId);

      if (!found) {
        return false;
      }
    }
    // check supplier
    if (_filter!.suppliers != null && _filter!.suppliers!.isNotEmpty) {
      final found = _filter!.suppliers!.keys.contains(card.supplierId);
      if (!found) {
        return false;
      }
    }
    // check brand
    if (_filter!.brands != null && _filter!.brands!.isNotEmpty) {
      final found = _filter!.brands!.values.contains(card.brand);
      if (!found) {
        return false;
      }
    }
    // check promo
    if (_filter!.promos != null && _filter!.promos!.isNotEmpty) {
      final found = _filter!.promos!.values.contains(card.promoTextCard);
      if (!found) {
        return false;
      }
    }
    // check with sales
    if (_filter!.withSales != null) {
      final found = card.weekOrdersSum > 0;
      if (!found) {
        return false;
      }
    }
    // check with stocks
    if (_filter!.withStocks != null) {
      final found = card.stocksSum > 0;
      if (!found) {
        return false;
      }
    }
    return true;
  }
}
