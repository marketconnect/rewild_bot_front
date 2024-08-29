import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/total_cost_calculator.dart';

// import 'package:rewild/core/utils/sqflite_service.dart';

// Token
abstract class ExpenseManagerScreenTokenService {
  Future<Either<RewildError, String>> getToken();
}

// Total cost
abstract class ExpenseManagerTotalCostService {
  Future<Either<RewildError, TotalCostCalculator>> getTotalCost(int nmId);
  Future<Either<RewildError, void>> addOrUpdateExpense(
      int nmId, String name, double value);
  Future<Either<RewildError, void>> removeExpense(int nmId, String name);
  Future<Either<RewildError, List<int>>> getAllNmIds();
  Future<Either<RewildError, void>> updateWith(
      {required int nmIdFrom, required int nmIdTo});
}

// Card of product
abstract class ExpenseManagerCardOfProductService {
  Future<Either<RewildError, CardOfProductModel?>> getOne(int nmId);
}

abstract class ExpenseManagerAverageLogisticsService {
  Future<Either<RewildError, int>> getCurrentAverageLogistics(
      {required String token});
}

class ExpenseManagerViewModel extends ResourceChangeNotifier {
  final (int, int, double) nmIdPlusAverageLogisticsCom;
  final ExpenseManagerTotalCostService totalCostService;
  final ExpenseManagerCardOfProductService cardOfProductService;
  final ExpenseManagerScreenTokenService tokenService;
  final ExpenseManagerAverageLogisticsService averageLogisticsService;
  ExpenseManagerViewModel({
    required super.context,
    required this.averageLogisticsService,
    required this.nmIdPlusAverageLogisticsCom,
    required this.totalCostService,
    required this.tokenService,
    required this.cardOfProductService,
  }) {
    _asyncInit();
  }

  _asyncInit() async {
    // SqfliteService.printTableContent('total_cost_calculator');

    setIsLoading(true);
    // token
    final tokenEither = await tokenService.getToken();
    if (tokenEither.isLeft()) {
      setIsLoading(false);
      return;
    }
    final token = tokenEither.fold((l) => throw UnimplementedError(), (r) => r);

    final values = await Future.wait([
      fetch(
          () => totalCostService.getTotalCost(nmIdPlusAverageLogisticsCom.$1)),
      fetch(() => cardOfProductService.getOne(nmIdPlusAverageLogisticsCom.$1)),
      fetch(() => totalCostService.getAllNmIds()),
      fetch(() =>
          averageLogisticsService.getCurrentAverageLogistics(token: token))
    ]);

    // total cost is a list of expenses and other info
    final totalCost = values[0] as TotalCostCalculator?;
    if (totalCost == null) {
      setIsLoading(false);
      return;
    }

    // average logistics

    setAverageLogistics(nmIdPlusAverageLogisticsCom.$2);
    setCommission(nmIdPlusAverageLogisticsCom.$3);
    // card
    final card = values[1] as CardOfProductModel?;
    if (card == null) {
      setIsLoading(false);
      return;
    }
    // set card info
    setProductName(card.name);
    setProductImage(card.img);
    setInitProductPrice(card.basicPriceU);

    // all nmIds with total cost
    final nmIds = values[2] as List<int>;
    _nmIds.clear();
    setNmIds(nmIds
        .where((element) => element != nmIdPlusAverageLogisticsCom.$1)
        .toList());
    // images for the nmIds
    _nmIdCards.clear();
    for (final nmId in nmIds) {
      final card = await fetch(() => cardOfProductService.getOne(nmId));
      if (card != null) {
        addNmIdCard(nmId, card);
      }
    }

    for (final expense in totalCost.expenses.entries) {
      final k = expense.key;

      if (k == TotalCostCalculator.priceKey) {
        setRealProductPrice(expense.value.toInt());
      } else if (k == TotalCostCalculator.logisticsKey) {
        setAverageLogistics(expense.value.toInt());
        _averageLogisticCustom = true;
      } else if (k == TotalCostCalculator.returnsKey) {
        setReturnsPercentage(expense.value.toInt());
      } else if (k == TotalCostCalculator.taxKey) {
        setTax(expense.value.toInt());
      }
    }
    // set total cost
    setTotalCost(totalCost);
    setIsLoading(false);
  }

  // isLoading
  bool _isLoading = false;
  void setIsLoading(bool loading) {
    _isLoading = loading;
    notify();
  }

  bool get isLoading => _isLoading;

  // average logistics from server
  int? _averageLogisticsFromServer;
  int get averageLogisticsFromServer => _averageLogisticsFromServer ?? 50;
  void setAverageLogisticsFromServer(int? averageLogistics) {
    _averageLogisticsFromServer = averageLogistics;
    notify();
  }

  // product name
  String _productName = "";
  String get productName => _productName;
  void setProductName(String name) {
    _productName = name;
    notify();
  }

  // product image
  String? _productImage = "";
  String? get productImage => _productImage;
  void setProductImage(String? image) {
    _productImage = image;
  }

  // init product price
  int _initProductPrice = 0;
  int get initProductPrice => _initProductPrice;
  void setInitProductPrice(int? price) {
    final newPrice = price ?? 0;
    _initProductPrice = newPrice ~/ 100;
    notify();
  }

  // wb discount

  double get wbDiscount => _initProductPrice == 0 || _realProductPrice == 0
      ? 0
      : (((_initProductPrice - _realProductPrice) / _initProductPrice) * 100)
          .abs();

  // real product price
  int _realProductPrice = 0;
  int get realProductPrice =>
      _realProductPrice == 0 ? _initProductPrice : _realProductPrice;
  void setRealProductPrice(int price) {
    _realProductPrice = price;
  }

  int calculateBreakEvenPoint() {
    double result = totalCost;
    double calculatedCost;
    double comRub;
    double taxRub;

    while (true) {
      comRub = (commission * result / 100);
      taxRub = (tax * result / 100);
      calculatedCost = totalCost +
          averageLogistics +
          ((averageLogistics + 50) * returnsPercentage / 100);

      double newResult = calculatedCost + comRub + taxRub;

      if ((newResult - result).abs() < 0.01) {
        // Проверка на сходимость с допустимой ошибкой
        break;
      }
      result = newResult;
    }

    return result.ceil();
  }

  // double calculateBreakEvenPoint() {
  //   double realProductPrice = totalCost;
  //   double calculatedCost;

  //   do {
  //     final comRub = (commission * realProductPrice / 100).ceil();
  //     final taxRub = (tax * realProductPrice / 100).ceil();

  //     final returnRub = (averageLogistics + 50) * returnsPercentage / 100;
  //     calculatedCost =
  //         totalCost + averageLogistics + comRub + returnRub + taxRub;
  //     realProductPrice = calculatedCost;
  //   } while (realProductPrice != calculatedCost);

  //   return realProductPrice;
  // }

  // average logistics
  bool _averageLogisticCustom = false;
  bool get averageLogisticCustom => _averageLogisticCustom;
  int _averageLogistics = 0;

  int get averageLogistics =>
      _averageLogistics == 0 ? averageLogisticsFromServer : _averageLogistics;
  void setAverageLogistics(int logistics) {
    _averageLogistics = logistics;
    notify();
  }

  // returns percentage
  int _reyturnsPercentage = 0;
  int get returnsPercentage => _reyturnsPercentage;
  void setReturnsPercentage(int cost) {
    _reyturnsPercentage = cost;
    notify();
  }

  // tax
  int _tax = 0;
  int get tax => _tax;
  void setTax(int cost) {
    _tax = cost;
    notify();
  }

  double _commission = 0;
  double get commission => _commission;
  void setCommission(double cost) {
    _commission = cost;
    notify();
  }

  // total cost
  TotalCostCalculator? _totalCost;
  Map<String, double> get expenses => _totalCost?.getExpenses() ?? {};
  void setTotalCost(TotalCostCalculator totalCost) {
    _totalCost = totalCost;
  }

  // all nmIds
  List<int> _nmIds = [];
  List<int> get nmIds => _nmIds;
  void setNmIds(List<int> nmIds) {
    _nmIds = nmIds;
  }

  // all images for the nmIds
  Map<int, CardOfProductModel> _nmIdCards = {};
  Map<int, CardOfProductModel> get nmIdCards => _nmIdCards;
  void setNmIdImages(Map<int, CardOfProductModel> nmIdCards) {
    _nmIdCards = nmIdCards;
  }

  void addNmIdCard(int nmId, CardOfProductModel card) {
    _nmIdCards[nmId] = card;
  }

  // calculate total cost
  double get totalCost => _totalCost?.totalCost ?? 0;

  double get calculateReturns =>
      (averageLogistics + averageLogisticsFromServer) *
      _reyturnsPercentage /
      100;
  // calc ACPU
  double get acpu {
    if (_totalCost == null) {
      return 0;
    }

    final returns = (averageLogistics + averageLogisticsFromServer) *
        _reyturnsPercentage /
        100;

    final logistics = averageLogistics + returns;
    final tax = _tax * realProductPrice / 100;
    final wbCommission = commission * realProductPrice / 100;
    final fees = tax + wbCommission;
    return totalCost + logistics + fees;
  }

  bool priceWasSaved = false;
  bool commissionWasSaved = false;
  bool averageLogisticsWasSaved = false;

  Future<void> add(String name, String value) async {
    if (!priceWasSaved && name != TotalCostCalculator.priceKey) {
      await fetch(() => totalCostService.addOrUpdateExpense(
          nmIdPlusAverageLogisticsCom.$1,
          TotalCostCalculator.priceKey,
          realProductPrice.toDouble()));
      priceWasSaved = true;
    }
    if (!commissionWasSaved && name != TotalCostCalculator.wbCommission) {
      await fetch(() => totalCostService.addOrUpdateExpense(
          nmIdPlusAverageLogisticsCom.$1,
          TotalCostCalculator.wbCommission,
          _commission.toDouble() / 100));
      commissionWasSaved = true;
    }
    if (!averageLogisticsWasSaved && name != TotalCostCalculator.logisticsKey) {
      await fetch(() => totalCostService.addOrUpdateExpense(
          nmIdPlusAverageLogisticsCom.$1,
          TotalCostCalculator.logisticsKey,
          averageLogistics.toDouble()));
      averageLogisticsWasSaved = true;
    }
    final doubleValue = double.tryParse(value) ?? 0;
    await fetch(() => totalCostService.addOrUpdateExpense(
        nmIdPlusAverageLogisticsCom.$1, name, doubleValue));
    _asyncInit();
  }

  Future<void> remove(String name) async {
    await totalCostService.removeExpense(nmIdPlusAverageLogisticsCom.$1, name);
    _asyncInit();
  }

  Future<void> updateWithOtherCardData(int otherCardNmId) async {
    if (!priceWasSaved) {
      await fetch(() => totalCostService.addOrUpdateExpense(
          nmIdPlusAverageLogisticsCom.$1,
          TotalCostCalculator.priceKey,
          realProductPrice.toDouble()));
      priceWasSaved = true;
    }
    if (!commissionWasSaved) {
      await fetch(() => totalCostService.addOrUpdateExpense(
          nmIdPlusAverageLogisticsCom.$1,
          TotalCostCalculator.wbCommission,
          _commission.toDouble() / 100));
      commissionWasSaved = true;
    }
    if (!averageLogisticsWasSaved) {
      await fetch(() => totalCostService.addOrUpdateExpense(
          nmIdPlusAverageLogisticsCom.$1,
          TotalCostCalculator.logisticsKey,
          averageLogistics.toDouble()));
      averageLogisticsWasSaved = true;
    }
    if (otherCardNmId == nmIdPlusAverageLogisticsCom.$1) {
      return;
    }
    await totalCostService.updateWith(
        nmIdFrom: otherCardNmId, nmIdTo: nmIdPlusAverageLogisticsCom.$1);
    _asyncInit();
  }

  // static const _url =
  //     'https://marketconnect.ru/kak-prodavat-na-wildberries-i-ustanavlivat-konkurentnye-tseny-poshagovoe-rukovodstvo/#ue_video';
  // Future<void> launchURL() async {
  //   final Uri uri = Uri.parse(_url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     if (!context.mounted) {
  //       return;
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //       content: Text("Не удается открыть ссылку"),
  //     ));
  //   }
  // }
}
