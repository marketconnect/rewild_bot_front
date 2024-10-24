import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:fpdart/fpdart.dart';

// import 'package:rewild_bot_front/.env.dart';
import 'package:rewild_bot_front/core/constants/regions_nums.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

// import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/commission_model.dart';
import 'package:rewild_bot_front/domain/entities/initial_stock_model.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/entities/order_model.dart';
import 'package:rewild_bot_front/domain/entities/orders_history_model.dart';
import 'package:rewild_bot_front/domain/entities/prices.dart';
import 'package:rewild_bot_front/domain/entities/seller_model.dart';
import 'package:rewild_bot_front/domain/entities/stocks_model.dart';
import 'package:rewild_bot_front/domain/entities/stream_notification_event.dart';
import 'package:rewild_bot_front/domain/entities/supply_model.dart';
import 'package:rewild_bot_front/domain/entities/tariff_model.dart';
import 'package:rewild_bot_front/domain/entities/warehouse.dart';
import 'package:rewild_bot_front/presentation/products/cards/notification_card_screen/notification_card_view_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

import 'package:web/web.dart' as html;

import 'package:js/js.dart';

// card
abstract class SingleCardScreenCardOfProductService {
  Future<Either<RewildError, CardOfProductModel?>> getOne(int nmId);
  // Future<Either<RewildError, List<NmId>>> getAllUserNmIds();
}

// warehouse
abstract class SingleCardScreenWarehouseService {
  Future<Either<RewildError, Warehouse?>> getById({required int id});
}

// initial stock
abstract class SingleCardScreenInitialStockService {
  Future<Either<RewildError, List<InitialStockModel>>> get(
      {required int nmId, DateTime? dateFrom, DateTime? dateTo});
}

// stock
abstract class SingleCardScreenStockService {
  Future<Either<RewildError, List<StocksModel>>> get({required int nmId});
}

// seller
abstract class SingleCardScreenSellerService {
  Future<Either<RewildError, SellerModel>> get({required int supplierId});
}

// commission
abstract class SingleCardScreenCommissionService {
  Future<Either<RewildError, CommissionModel>> get(
      {required String token, required int id});
}

// tarriff
abstract class SingleCardScreenTariffService {
  Future<Either<RewildError, List<TariffModel>>> getByStoreId(int storeId);
}

// orders history
abstract class SingleCardScreenOrdersHistoryService {
  Future<Either<RewildError, OrdersHistoryModel>> get({required int nmId});
}

// supply
abstract class SingleCardScreenSupplyService {
  Future<Either<RewildError, List<SupplyModel>?>> getForOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo});
}

// notification
abstract class SingleCardScreenNotificationService {
  Future<Either<RewildError, bool>> checkForParent({required int campaignId});
  Future<Either<RewildError, void>> deleteAllForParent(
      {required String token, required int parentId});
}

// Token
abstract class SingleCardScreenAuthService {
  Future<Either<RewildError, String>> getToken();
}

// price
abstract class SingleCardScreenPriceService {
  Future<Either<RewildError, Prices>> getPrice(String token);
}

// Week orders
abstract class SingleCardScreenWeekOrdersService {
  Future<Either<RewildError, List<OrderModel>>> getOrdersFromTo(
      {required String token, required List<int> skus});
}

// Update
abstract class SingleCardScreenUpdateService {
  Future<Either<RewildError, void>> update(String token);
  Future<Either<RewildError, void>> fetchAllUserCardsFromServerAndSync(
      String token);
}

abstract class SingleCardCardKeywordsService {
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsForCards(
      {required String token, required List<int> skus});
}

class SingleCardScreenViewModel extends ResourceChangeNotifier {
  SingleCardScreenViewModel(
      {required super.context,
      required this.tokenProvider,
      required this.id,
      required this.fromBot,
      required this.initialStocksService,
      required this.keywordsService,
      required this.updateService,
      required this.notificationService,
      required this.stockService,
      required this.sellerService,
      required this.commissionService,
      required this.weekOrdersService,
      required this.tariffService,
      required this.priceService,
      required this.cardOfProductService,
      required this.ordersHistoryService,
      required this.supplyService,
      required this.streamNotification,
      required this.warehouseService}) {
    asyncInit();
  }

  // constructor params
  final SingleCardScreenCardOfProductService cardOfProductService;
  final SingleCardScreenSellerService sellerService;
  final SingleCardScreenCommissionService commissionService;
  final SingleCardScreenInitialStockService initialStocksService;
  final SingleCardScreenWarehouseService warehouseService;
  final SingleCardScreenStockService stockService;
  final SingleCardScreenTariffService tariffService;
  final SingleCardScreenSupplyService supplyService;
  final SingleCardScreenOrdersHistoryService ordersHistoryService;
  final SingleCardScreenNotificationService notificationService;
  final SingleCardScreenAuthService tokenProvider;
  final SingleCardScreenPriceService priceService;
  final SingleCardCardKeywordsService keywordsService;
  final SingleCardScreenWeekOrdersService weekOrdersService;
  final SingleCardScreenUpdateService updateService;

  Stream<StreamNotificationEvent> streamNotification;
  final int id;
  final bool fromBot;

  // Fields ====================================================================
  bool _isLoading = false;

  void setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  bool get isLoading => _isLoading;

  // Keywords
  final List<KwByLemma> _keywords = [];
  void setKeywords(List<KwByLemma> value) {
    _keywords.clear();
    _keywords.addAll(value);
    notify();
  }

  List<KwByLemma> get keywords => _keywords;

  // week orders
  final Map<String, int> _weekOrdersHistoryFromServer = {};
  void addOrderHistoryFromServer(String name, int qty) {
    _weekOrdersHistoryFromServer[name] = qty;
  }

  Map<String, int> get weekOrdersHistoryFromServer =>
      _weekOrdersHistoryFromServer;

  // month orders
  final Map<String, int> _monthOrdersHistoryFromServer = {};
  Map<String, int> get monthOrdersHistoryFromServer =>
      _monthOrdersHistoryFromServer;

  // number of week and month
  int weekNum = 0;
  int monthNum = 0;

  // logistics coef
  int? _logisticsCoef;
  void setLogisticsCoef(int value) {
    _logisticsCoef = value;
  }

  int get logisticsCoef => _logisticsCoef ?? 23;

  // created at
  int? _createdAt;
  int? get createdAt => _createdAt;

  bool _tracked = false;

  void setTracked() {
    _tracked = true;
    notify();
  }

  void setUntracked() {
    _tracked = false;
    notify();
  }

  bool get tracked => _tracked;

  final List<String> listTilesNames = [
    'Общая информация',
    'Карточка',
    'Стоимость логистики',
    'Остатки по складам',
    'Заказы за сегодня',
    'Заказы за пред. неделю',
    'Заказы за пред. месяц',
    'Ключевые слова'
  ];
  String getTitle(int index) {
    return listTilesNames[index];
  }

  // stet for notification screen

  String _promo = '';
  String get promo => _promo;

  // volume
  int? _volume;
  int? get volume => _volume;

  // price
  int _price = 0;
  int get price => _price;

  // pics
  int _pics = 0;

  Map<Warehouse, int> _notificationScreenWarehouses = {};
  set notificationScreenWarehouses(Map<Warehouse, int> value) {
    _notificationScreenWarehouses = value;
  }

  // review rating
  double _reviewRating = 0;
  double get reviewRating => _reviewRating;

  //
  // Uri
  Uri? websiteUri;
  // Name
  String _name = '';
  String get name => _name;

  // Seller name
  String _sellerName = '-';
  String get sellerName => _sellerName;

  // Brand
  String _brand = '-';
  String get brand => _brand;

  // Trademark
  String _tradeMark = '-';
  String get tradeMark => _tradeMark;

  // category
  String _category = '-';
  String get category => _category;

  // subject Id
  int _subjectId = 0;
  int get subjectId => _subjectId;

  // subject
  String _subjectName = '-';
  String get subjectName => _subjectName;

  // commission
  double? _commission;
  double? get commission => _commission;

// is high buyout
  bool _isHighBuyout = false;
  bool get isHighBuyout => _isHighBuyout;

  // Image
  String _img = '';
  String get img => _img;

  // Feedback
  int _feedbacks = 0;
  int get feedbacks => _feedbacks;
  // Review rating

  // region
  String _region = '-';
  String get region => _region;
  // Warehouses
  final Map<String, int> _warehouses = {};
  void setWarehouses(Map<String, int> warehouses) {
    _warehouses.clear();
    _warehouses.addAll(warehouses);
  }

  // returns copy of warehouses
  Map<String, int> get warehouses => Map.from(_warehouses);

  // Tarrifs
  final Map<String, List<TariffModel>> _tarrifs = {};
  void setTarrifs(Map<String, List<TariffModel>> tarrifs) {
    _tarrifs.clear();
    _tarrifs.addAll(tarrifs);
  }

  void addTariff(String name, List<TariffModel> tariff) {
    _tarrifs[name] = tariff;
  }

  Map<String, List<TariffModel>> get tariffs => _tarrifs;

  // Stocks sum
  int _stocksSum = 0;
  int get stocksSum => _stocksSum;

  // Initial  Stocks
  Map<String, int> _initialStocks = {};
  Map<String, int> get initialStocks => _initialStocks;
  void setInitialStocks(Map<String, int> initialStocks) {
    _initialStocks = initialStocks;
  }

// Supplies
  Map<String, int> _supplies = {};
  Map<String, int> get supplies => _supplies;
  // Initial Stocks
  int _initStocksSum = 0;
  int get initStocksSum => _initStocksSum;

  // Supply
  int _supplySum = 0;
  int get supplySum => _supplySum;

  // Sales
  final Map<String, int> _orders = {};
  void setOrders(Map<String, int> orders) {
    _orders.clear();
    _orders.addAll(orders);
  }

  void addOrder(String name, int qty) {
    _orders[name] = qty;
  }

  Map<String, int> get orders => Map.from(_orders);
  // Null
  bool _isNull = true;
  bool get isNull => _isNull;

  // macx logistic
  int _maxLogistic = 0;
  void setMaxLogistic(double value) {
    int logistic = value.ceil();
    if (_maxLogistic < logistic) {
      _maxLogistic = logistic;
    }
  }

  // Methods ===================================================================
  Future<void> asyncInit() async {
    setIsLoading(true);

    // Stream update track
    streamNotification.listen((event) async {
      if (event.parentType == ParentType.card) {
        if (event.exists) {
          setTracked();
        } else {
          setUntracked();
        }
      }
    });

    // Token
    final token = await fetch(() => tokenProvider.getToken());
    if (token == null) {
      setIsLoading(false);
      return;
    }

    // if from telegram bot then update
    if (fromBot) {
      // if a user added a card and return to this screen from telegram bot
      // then the local storage does not contain this card yet
      // so we need to fetch it from server
      await fetch(
        () => updateService.fetchAllUserCardsFromServerAndSync(token),
      );

      await fetch(
        () => updateService.update(token),
      );
    }

    // multiple futures
    final values = await Future.wait([
      fetch(
        () => cardOfProductService.getOne(id),
      ), // 0

      fetch(
        () => stockService.get(nmId: id),
      ), // 1
      fetch(
        () => supplyService.getForOne(
            nmId: id, dateFrom: yesterdayEndOfTheDay(), dateTo: DateTime.now()),
      ), // 2
      fetch(
        () => initialStocksService.get(nmId: id),
      ), // 3
      fetch(
        () => ordersHistoryService.get(nmId: id),
      ), // 4
      fetch(
        () => notificationService.checkForParent(campaignId: id),
      ), // 5
      fetch(
        () => priceService.getPrice(token),
      ), // 6
      fetch(
        () => weekOrdersService.getOrdersFromTo(token: token, skus: [id]),
      ), // 7
      fetch(() => keywordsService.getKeywordsForCards(
            token: token,
            skus: [id],
          )), // 8
    ]);

    // Get card
    final cardOfProduct = values[0] as CardOfProductModel?;

    if (cardOfProduct == null) {
      // when a user go to the screen from telegram bot and the card already deleted
      if (context.mounted) {
        final result = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Карточка не найдена'),
              content: const Text('Что вы хотите сделать?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Добавить'),
                  onPressed: () {
                    Navigator.of(context).pop('add');
                  },
                ),
                TextButton(
                  child: const Text('Удалить'),
                  onPressed: () async {
                    await fetch(() => notificationService.deleteAllForParent(
                        token: token, parentId: id));
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );

        if (result == 'add') {
          // if (context.mounted) {
          //   Navigator.of(context).pushNamed('/addCardScreen', arguments: id);
          // }
          openBrowserAndCloseApp();
        } else if (result == 'delete') {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      }
      setIsLoading(false);
      return;
    }
    _isNull = false;

    // name, img, feedbacks, reviewRating
    _name = cardOfProduct.name;
    _img = cardOfProduct.img.replaceFirst("/tm/", "/big/");
    _feedbacks = cardOfProduct.feedbacks ?? 0;
    _reviewRating = cardOfProduct.reviewRating ?? 0;
    _price = cardOfProduct.basicPriceU ?? 0;
    _pics = cardOfProduct.pics ?? 0;
    _promo = cardOfProduct.promoTextCard ?? '';
    _volume = cardOfProduct.volume;
    _createdAt = cardOfProduct.createdAt;

    // Seller
    if (_sellerName == "-") {
      if (cardOfProduct.supplierId != null) {
        final seller = await fetch(
            () => sellerService.get(supplierId: cardOfProduct.supplierId!));
        if (seller == null) {
          setIsLoading(false);
          return;
        }
        _tradeMark = seller.trademark ?? '-';
        _sellerName = seller.name;
        // region

        final ogrn = seller.ogrn;
        _region = (ogrn != null && ogrn.length > 3)
            ? "${RegionsNumsConstants.regions[ogrn.substring(3, 5)]}"
            : "-";
      }
    }

    // Commission, category, subject
    if (_subjectId == 0) {
      _subjectId = cardOfProduct.subjectId ?? 0;
    }

    if (_commission == null && _subjectId != 0) {
      final commissionResource = await fetch(
          () => commissionService.get(token: token, id: _subjectId));
      if (commissionResource == null) {
        setIsLoading(false);
        return;
      }
      _commission = commissionResource.commission;
      _category = utf8.decode(commissionResource.category.runes.toList());
      _subjectName = utf8.decode(commissionResource.subject.runes.toList());
    }

    // brand
    _brand = cardOfProduct.brand ?? '-';
    // get stocks
    final stocks = values[1] as List<StocksModel>?;

    if (stocks == null) {
      setIsLoading(false);
      return;
    }

    //  add stocks
    for (final stock in stocks) {
      final wareHouse =
          await fetch(() => warehouseService.getById(id: stock.wh));
      if (wareHouse == null) {
        setIsLoading(false);
        return;
      }

      _notificationScreenWarehouses[wareHouse] = stock.qty;
      addWarehouse(wareHouse.name, stock.qty);

      // tariff
      final tariff = await fetch(() => tariffService.getByStoreId(stock.wh));
      if (tariff == null) {
        setIsLoading(false);
        return;
      }

      if (wareHouse.name.contains("Склад продавца")) {
        final tariff = await fetch(() => tariffService.getByStoreId(1));
        if (tariff == null) {
          setIsLoading(false);
          return;
        }

        addTariff("Склад продавца", tariff);
      } else {
        addTariff(wareHouse.name, tariff);
      }
    }

    // get supplies
    final supplies = values[2] as List<SupplyModel>? ?? [];

    // get initial stocks
    final initialStocks = values[3] as List<InitialStockModel>?;
    if (initialStocks == null) {
      setIsLoading(false);
      return;
    }

    // add initial stocks and orders
    for (final initStock in initialStocks) {
      final wh = initStock.wh;
      final warehouse = await fetch(() => warehouseService.getById(id: wh));
      if (warehouse == null) {
        setIsLoading(false);
        return;
      }

      addInitialStock(warehouse.name, initStock.qty);

      // orders
      final stock = warehouses[warehouse.name] ?? 0;
      final iSt = _initialStocks[warehouse.name] ?? 0;
      int supplyQty = 0;
      final supply = supplies.where((element) =>
          element.nmId == id &&
          element.wh == wh &&
          element.sizeOptionId == initStock.sizeOptionId);
      if (supply.isNotEmpty) {
        supplyQty = supply.first.qty;
      }
      addSupply(warehouse.name, supplyQty);
      final qty = iSt + supplyQty - stock;
      addOrder(warehouse.name, qty);
      _stocksSum += stock;
    }

    _initStocksSum = _initialStocks.values.isNotEmpty
        ? _initialStocks.values.reduce((value, element) => value + element)
        : 0;
    _supplySum = _supplies.values.isNotEmpty
        ? _supplies.values.reduce((value, element) => value + element)
        : 0;
    final ordersHistory = values[4] as OrdersHistoryModel?;
    if (ordersHistory == null) {
      setIsLoading(false);
      return;
    }

    // _totalOrdersQty = ordersHistory.qty;
    // is high buyout
    _isHighBuyout = ordersHistory.highBuyout;

    // Notification
    final notificationsExists = values[5] as bool?;
    if (notificationsExists != null && notificationsExists) {
      setTracked();
    }

    // logistics coef

    final logisticsCoefResource = values[6] as Prices?;
    if (logisticsCoefResource == null) {
      setIsLoading(false);
      return;
    }
    setLogisticsCoef(logisticsCoefResource.logisticsCoef);

    final ordersOrNull = values[7] as List<OrderModel>?;
    if (ordersOrNull != null) {
      for (final order in ordersOrNull) {
        final wh = order.warehouse;
        final period = order.period;
        final warehouse = await fetch(() => warehouseService.getById(id: wh));
        if (warehouse == null) {
          setIsLoading(false);
          return;
        }
        _addOrderHistoryFromServer(warehouse.name, order.qty, period);
      }
    }
    final keywordsResult = values[8] as List<KwByLemma>?;
    if (keywordsResult != null) {
      setKeywords(keywordsResult);
    }

    setIsLoading(false);
  } // asyncInit

  void _addOrderHistoryFromServer(String name, int qty, String period) {
    if (!_weekOrdersHistoryFromServer.containsKey(name)) {
      if (period.startsWith('m')) {
        if (monthNum == 0) {
          monthNum = int.tryParse(period.split('m')[1]) ?? 0;
        }
        _monthOrdersHistoryFromServer[name] = qty;
      } else if (period.startsWith('w')) {
        if (weekNum == 0) {
          weekNum = int.tryParse(period.split('w')[1]) ?? 0;
        }
        _weekOrdersHistoryFromServer[name] = qty;
      }
      return;
    }
    if (period == 'm') {
      _monthOrdersHistoryFromServer[name] =
          _monthOrdersHistoryFromServer[name]! + qty;
    } else if (period == 'w') {
      _weekOrdersHistoryFromServer[name] =
          _weekOrdersHistoryFromServer[name]! + qty;
    }
  }

  void addWarehouse(String name, int qty) {
    if (_warehouses[name] == null) {
      _warehouses[name] = qty;

      return;
    }
    final sumQty = _warehouses[name]! + qty;
    _warehouses[name] = sumQty;
  }

  void addInitialStock(String name, int qty) {
    if (_initialStocks[name] == null) {
      _initialStocks[name] = qty;
      return;
    }
    final sumQty = _initialStocks[name]! + qty;
    _initialStocks[name] = sumQty;
  }

  void setSupplies(Map<String, int> supplies) {
    _supplies = supplies;
  }

  void addSupply(String name, int qty) {
    if (_supplies[name] == null) {
      _supplies[name] = qty;
      return;
    }
    final sumQty = _supplies[name]! + qty;
    _supplies[name] = sumQty;
  }

  // int calculateMaxTariffCost(Map<String, List<TariffModel>> tariffs) {
  //   int max = 0;

  //   for (var entry in tariffs.entries) {
  //     for (var tariff in entry.value) {
  //       if (tariff.coef > max) {
  //         // print('tar ${tariff.coef}');
  //         max = tariff.coef;
  //       }
  //     }
  //   }
  //   return ((max / 100) * ((volume! / 10) * 7 + logisticsCoef)).ceil();
  // }

  void notificationsScreen() {
    final state = NotificationCardState(
      nmId: id,
      price: _price,
      promo: _promo,
      name: _name,
      pics: _pics,
      reviewRating: _reviewRating,
      warehouses: _notificationScreenWarehouses,
    );

    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.cardNotificationsSettingsScreen,
        arguments: state);
  }

  void expenseManagercreen() {
    // final maxLogistic = calculateMaxTariffCost(_tarrifs);

    Navigator.of(context).pushNamed(
        MainNavigationRouteNames.expenseManagerScreen,
        arguments: (id, _maxLogistic, _commission ?? 0));
  }

  void openBrowserAndCloseApp() {
    // first open browser
    html.window.open(
        'https://www.wildberries.ru/catalog/$id/detail.aspx?targetUrl=EX',
        'wb');

    // Wait for 5 seconds before closing the app to be sure that the browser window is closed
    Future.delayed(const Duration(seconds: 5), () {
      closeTelegramApp();
    });
  }

  void navigateToAllSubjectsScreen() {
    Navigator.of(context).pushNamed(MainNavigationRouteNames.allSubjectsScreen,
        arguments: [_category]);
  }

  void goToSubject() {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.topProductsScreen,
      arguments: (subjectId, _subjectName),
    );
  }

  void goToAdBidsScreen(String keyword) {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.geoSearchScreen,
      arguments: keyword,
    );
  }
}

// external function from index.html
@JS('closeTelegramApp')
external void closeTelegramApp();
