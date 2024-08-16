class FetchDetailResult {
  final List<AnaliticsDetail> details;
  final bool isNextPage;
  final int page;

  FetchDetailResult(
      {required this.details, required this.isNextPage, required this.page});
}

class AnaliticsDetail {
  final int nmID;
  final String vendorCode;
  final String brandName;
  final List<Tag> tags;
  final ProductCategory object;
  final Statistics statistics;
  final Stocks stocks;

  bool isNonSelling;

  bool isBestOpenCardCount;
  bool isWorstOpenCardCount;
  bool isBestAddToCartPercent;
  bool isWorstAddToCartPercent;
  bool isBestCartToOrderPercent;
  bool isWorstCartToOrderPercent;

  bool isWorstAddToCartPercentDynamic;
  bool isWorstCartToOrderPercentDynamic;
  bool isWorstOpenCardDynamics;

  AnaliticsDetail({
    required this.nmID,
    required this.vendorCode,
    required this.brandName,
    required this.tags,
    required this.object,
    required this.statistics,
    required this.stocks,
    this.isNonSelling = false,
    this.isBestOpenCardCount = false,
    this.isWorstOpenCardCount = false,
    this.isBestAddToCartPercent = false,
    this.isWorstAddToCartPercent = false,
    this.isBestCartToOrderPercent = false,
    this.isWorstCartToOrderPercent = false,
    this.isWorstAddToCartPercentDynamic = false,
    this.isWorstCartToOrderPercentDynamic = false,
    this.isWorstOpenCardDynamics = false,
  });

  factory AnaliticsDetail.fromJson(Map<String, dynamic> json) =>
      AnaliticsDetail(
        nmID: json['nmID'],
        vendorCode: json['vendorCode'],
        brandName: json['brandName'],
        tags: json['tags'] != null
            ? List<Tag>.from(json['tags'].map((x) => Tag.fromJson(x)))
            : [],
        object: ProductCategory.fromJson(json['object']),
        statistics: Statistics.fromJson(json['statistics']),
        stocks: Stocks.fromJson(json['stocks']),
      );
}

class Tag {
  final int id;
  final String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'],
        name: json['name'],
      );
}

class ProductCategory {
  final int id;
  final String name;

  ProductCategory({required this.id, required this.name});

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      ProductCategory(
        id: json['id'],
        name: json['name'],
      );
}

class Statistics {
  final Period selectedPeriod;
  final Period previousPeriod;
  final PeriodComparison periodComparison;

  Statistics(
      {required this.selectedPeriod,
      required this.previousPeriod,
      required this.periodComparison});

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
        selectedPeriod: Period.fromJson(json['selectedPeriod']),
        previousPeriod: Period.fromJson(json['previousPeriod']),
        periodComparison: PeriodComparison.fromJson(json['periodComparison']),
      );
}

class Period {
  final String begin;
  final String end;
  final int openCardCount;
  final int addToCartCount;
  final int ordersCount;
  final int ordersSumRub;
  final int buyoutsCount;
  final int buyoutsSumRub;
  final int cancelCount;
  final int cancelSumRub;
  final int avgPriceRub;
  final double avgOrdersCountPerDay;
  final Conversions conversions;

  Period({
    required this.begin,
    required this.end,
    required this.openCardCount,
    required this.addToCartCount,
    required this.ordersCount,
    required this.ordersSumRub,
    required this.buyoutsCount,
    required this.buyoutsSumRub,
    required this.cancelCount,
    required this.cancelSumRub,
    required this.avgPriceRub,
    required this.avgOrdersCountPerDay,
    required this.conversions,
  });

  factory Period.fromJson(Map<String, dynamic> json) => Period(
        begin: json['begin'],
        end: json['end'],
        openCardCount: json['openCardCount'],
        addToCartCount: json['addToCartCount'],
        ordersCount: json['ordersCount'],
        ordersSumRub: json['ordersSumRub'],
        buyoutsCount: json['buyoutsCount'],
        buyoutsSumRub: json['buyoutsSumRub'],
        cancelCount: json['cancelCount'],
        cancelSumRub: json['cancelSumRub'],
        avgPriceRub: json['avgPriceRub'],
        avgOrdersCountPerDay: json['avgOrdersCountPerDay'].toDouble(),
        conversions: Conversions.fromJson(json['conversions']),
      );
}

class Conversions {
  final double addToCartPercent;
  final double cartToOrderPercent;
  final double buyoutsPercent;

  Conversions({
    required this.addToCartPercent,
    required this.cartToOrderPercent,
    required this.buyoutsPercent,
  });

  factory Conversions.fromJson(Map<String, dynamic> json) => Conversions(
        addToCartPercent: json['addToCartPercent'].toDouble(),
        cartToOrderPercent: json['cartToOrderPercent'].toDouble(),
        buyoutsPercent: json['buyoutsPercent'].toDouble(),
      );
}

class PeriodComparison {
  final int openCardDynamics;
  final int addToCartDynamics;
  final int ordersCountDynamics;
  final int ordersSumRubDynamics;
  final int buyoutsCountDynamics;
  final int buyoutsSumRubDynamics;
  final int cancelCountDynamics;
  final int cancelSumRubDynamics;
  final int avgPriceRubDynamics;
  final double avgOrdersCountPerDayDynamics;
  final ConversionDynamics conversions;

  PeriodComparison({
    required this.openCardDynamics,
    required this.addToCartDynamics,
    required this.ordersCountDynamics,
    required this.ordersSumRubDynamics,
    required this.buyoutsCountDynamics,
    required this.buyoutsSumRubDynamics,
    required this.cancelCountDynamics,
    required this.cancelSumRubDynamics,
    required this.avgPriceRubDynamics,
    required this.avgOrdersCountPerDayDynamics,
    required this.conversions,
  });

  factory PeriodComparison.fromJson(Map<String, dynamic> json) =>
      PeriodComparison(
        openCardDynamics: json['openCardDynamics'],
        addToCartDynamics: json['addToCartDynamics'],
        ordersCountDynamics: json['ordersCountDynamics'],
        ordersSumRubDynamics: json['ordersSumRubDynamics'],
        buyoutsCountDynamics: json['buyoutsCountDynamics'],
        buyoutsSumRubDynamics: json['buyoutsSumRubDynamics'],
        cancelCountDynamics: json['cancelCountDynamics'],
        cancelSumRubDynamics: json['cancelSumRubDynamics'],
        avgPriceRubDynamics: json['avgPriceRubDynamics'],
        avgOrdersCountPerDayDynamics:
            json['avgOrdersCountPerDayDynamics'].toDouble(),
        conversions: ConversionDynamics.fromJson(json['conversions']),
      );
}

class ConversionDynamics {
  final int addToCartPercent;
  final int cartToOrderPercent;
  final int buyoutsPercent;

  ConversionDynamics({
    required this.addToCartPercent,
    required this.cartToOrderPercent,
    required this.buyoutsPercent,
  });

  factory ConversionDynamics.fromJson(Map<String, dynamic> json) =>
      ConversionDynamics(
        addToCartPercent: json['addToCartPercent'],
        cartToOrderPercent: json['cartToOrderPercent'],
        buyoutsPercent: json['buyoutsPercent'],
      );
}

class Stocks {
  final int stocksMp;
  final int stocksWb;

  Stocks({required this.stocksMp, required this.stocksWb});

  factory Stocks.fromJson(Map<String, dynamic> json) => Stocks(
        stocksMp: json['stocksMp'],
        stocksWb: json['stocksWb'],
      );
}
