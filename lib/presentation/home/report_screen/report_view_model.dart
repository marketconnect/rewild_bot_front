import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/color.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/realization_report.dart';
import 'package:rewild_bot_front/domain/entities/total_cost_calculator.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// cards
abstract class ReportUserCardService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

// total cost
abstract class ReportTotalCostService {
  Future<Either<RewildError, TotalCostCalculator>> getTotalCost(int nmId);
}

// reports
abstract class ReportRealizationReportService {
  Future<Either<RewildError, List<RealizationReport>>>
      fetchReportDetailByPeriod({
    required String dateFrom,
    required String dateTo,
    int limit = 100000,
    int rrdid = 0,
  });
  Future<Either<RewildError, bool>> apiKeyExists();
}

// adverts
abstract class ReportAdvertService {
  Future<Either<RewildError, int>> getExpensesSum({
    required DateTime from,
    required DateTime to,
  });
  Future<Either<RewildError, String?>> getApiKey();
}

class ReportViewModel extends ResourceChangeNotifier {
  final ReportRealizationReportService realizationReportService;
  final ReportUserCardService userCardService;
  final ReportTotalCostService totalCostService;
  final ReportAdvertService advertService;
  ReportViewModel(
      {required super.context,
      required this.userCardService,
      required this.totalCostService,
      required this.advertService,
      required this.realizationReportService}) {
    _asyncInit();
  }

  _asyncInit() async {
    // SqfliteService.printTableContent('total_cost_calculator');
    setIsLoading(true);
    final apiKeyExistOrNull =
        await fetch(() => realizationReportService.apiKeyExists());
    if (apiKeyExistOrNull == null) {
      setApiKeyExists(false);
      setIsLoading(false);
      return;
    }
    setApiKeyExists(apiKeyExistOrNull);
    setIsLoading(false);
  }

  // loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setIsLoading(bool loading) {
    _isLoading = loading;
    notify();
  }

  // colors
  List<Color>? _colors;
  List<Color>? get colors => _colors;
  void setColors(int qty) {
    _colors = generateRandomColors(qty);
  }

  // api key exists
  bool _apiKeyExists = false;
  bool get apiKeyExists => _apiKeyExists;
  void setApiKeyExists(bool exists) {
    _apiKeyExists = exists;
  }

// Images
  // Map<int, (String, double)> _images = {};
  // Images
  Map<int, (String, double, double)> _images = {};

  // do not used only for warning
  void setterImages(Map<int, (String, double, double)> images) {
    _images = images;
  }

  // void addImage(int nmId, String value, double revenue) {
  //   _images[nmId] = (value, revenue);
  // }
  void addImage(int nmId, String value, double revenue, double profit) {
    _images[nmId] = (value, revenue, profit);
  }

  void sortImages() {
    _images = Map.fromEntries(_images.entries.toList()
      ..sort((a, b) => b.value.$2.compareTo(a.value.$2)));
  }

  Map<int, (String, double, double)> get images => _images;

  // Future<void> setImages(List<int> nmIds) async {
  //   for (final nmId in nmIds) {
  //     final image = await fetch(
  //       () => cardOfProductService.getImageForNmId(nmId: nmId),
  //     );
  //     if (image == null) {
  //       continue;
  //     }
  //     addImage(nmId, image);
  //   }
  //   setCurrentDetailNmId(images.keys.first);
  // }

  // current detail nmId
  int _currentDetailNmId = -1;
  void setCurrentDetailNmId(int nmId) {
    _currentDetailNmId = nmId;

    updsateSummary(nmId);

    notify();
  }

  int get currentDetailNmId => _currentDetailNmId;

  // gross profit
  Map<int, double> _cogs = {};
  // Map<int, double> get cogs => _cogs;
  void setGrossProfit(Map<int, double> grossProfit) {
    _cogs = grossProfit;
    notify();
  }

  void addCogs(int nmId, double value) {
    if (_cogs[nmId] == null) {
      _cogs[nmId] = value;
    }
  }

  List<int> _emptyCogs = [];
  void setEmptyCogs(List<int> emptyCogs) {
    _emptyCogs = emptyCogs;
    notify();
  }

  void addEmptyCogs(int nmId) {
    if (!_emptyCogs.contains(nmId)) {
      _emptyCogs.add(nmId);
    }
  }

  List<int> get emptyCogs => _emptyCogs;

  void removeEmptyCogs(int nmId, double cogs) {
    addCogs(nmId, cogs);
    _emptyCogs.remove(nmId);
  }

  // reports
  List<RealizationReport> _reports = [];
  List<RealizationReport> get reports => _reports;
  void setReports(List<RealizationReport> reports) {
    _reports = reports;
    notify();
  }

  // report id
  int _reportId = 0;
  int get reportId => _reportId;
  void setReportId(int reportId) {
    _reportId = reportId;
  }

  //  total revenue
  double _totalRevenue = 0.0;
  double get totalRevenue => _totalRevenue;
  void setTotalRevenue(double totalRevenue) {
    _totalRevenue = totalRevenue;
  }

  double _storage = 0.0;
  double get storage => _storage;
  int _salesNum = 0;
  int get salesNum => _salesNum;
  int _returnsNum = 0;
  int get returnsNum => _returnsNum;
  double _revenue = 0.0;
  double get revenue => _revenue;
  double _wbCommission = 0.0;
  double get wbCommission => _wbCommission;
  double _delivery = 0.0;
  double get delivery => _delivery;
  double _expensesAndOthers = 0.0;
  double get expensesAndOthers => _expensesAndOthers;
  double _penalties = 0.0;
  double get penalties => _penalties;
  double _deduction = 0.0;
  double get deduction => _deduction;
  double _additionalPayment = 0.0;
  double get additionalPayment => _additionalPayment;

  double _cogsSum = 0.0;
  double get cogsSum => _cogsSum;
  double _pay = 0.0;
  double get pay => _pay;
  // double _expenses = 0.0;
  double _profit = 0.0;
  double get profit => _profit;
  double _profitabilityOfSales = 0.0;
  double get profitabilityOfSales => _profitabilityOfSales;
  double _ebitda = 0.0;
  double get ebitda => _ebitda;
  double _tax = 0.0;
  double get tax => _tax;
  double _taxValue = 0.0;
  double get taxValue => _taxValue;

  double _minPpvzForPay = 0.0;
  double get minPpvzForPay => _minPpvzForPay;

  double _advSpentFromBalance = 0.0;
  double get advSpentFromBalance => _advSpentFromBalance;

  String _minPpvzForPayWarehouse = '';
  String get minPpvzForPayWarehouse => _minPpvzForPayWarehouse;

  int _advertExpenses = 0;
  setExpenses(int expenses) {
    _advertExpenses = expenses;
    notify();
  }

  int get advertExpenses => _advertExpenses;

  void resetSummary() {
    _revenue = 0.0;
    _penalties = 0.0;
    _additionalPayment = 0.0;
    _cogsSum = 0.0;
    // _expenses = 0.0;
    _profit = 0.0;
    _profitabilityOfSales = 0.0;
    _reports = [];
    _reportId = 0;
  }

// set summary
  void calculateSums(List<RealizationReport> reportsList) {
    _storage = reportsList.fold<double>(
        0, (sum, report) => sum + (report.storageFee ?? 0));
    _revenue = reportsList.fold<double>(
        0, (sum, report) => sum + (report.retailAmount ?? 0));
    _penalties = reportsList.fold<double>(
        0, (sum, report) => sum + (report.penalty ?? 0));
    _additionalPayment = reportsList.fold<double>(
        0, (sum, report) => sum + (report.additionalPayment ?? 0));
  }

  List<RealizationReport> filterReports(List<RealizationReport> reportsList) {
    final returnsReports = reportsList.where(
        (element) => element.returnAmount != null && element.returnAmount! > 0);
    _returnsNum = returnsReports.length;

    final salesReports = reportsList.where((element) =>
        element.supplierOperName == 'Продажа' ||
        element.supplierOperName == 'продажа');
    _salesNum = salesReports.length;
    return salesReports.toList();
  }

  void calculateMinPpvzForPay(List<RealizationReport> reportsList,
      List<RealizationReport> salesReports) {
    String srid = "";
    _minPpvzForPayWarehouse = "";
    _minPpvzForPay = salesReports.fold(-1, (previousValue, element) {
      if (element.ppvzForPay != null &&
          element.ppvzForPay! > 0 &&
          previousValue == -1) {
        _minPpvzForPayWarehouse = element.officeName ?? '';
        srid = element.srid ?? '';
        return element.ppvzForPay!;
      }
      if (element.ppvzForPay != null && element.ppvzForPay! > 0) {
        if (previousValue > element.ppvzForPay!) {
          _minPpvzForPayWarehouse = element.officeName ?? '';
          srid = element.srid ?? '';
          return element.ppvzForPay!;
        }
      }
      return previousValue;
    });
    if (srid.isNotEmpty) {
      final deliveryCosts = reportsList.where((element) =>
          element.srid == srid &&
          element.deliveryRub != null &&
          element.deliveryRub! > 0);
      if (deliveryCosts.isNotEmpty) {
        _minPpvzForPay -= deliveryCosts.first.deliveryRub!;
      }
    }
  }

  void calculateFinancialMetrics(List<RealizationReport> reportsList,
      List<RealizationReport> salesReports) {
    _deduction = reportsList.fold<double>(0, (previousValue, report) {
      if (report.bonusTypeName == 'Оказание услуг «ВБ.Продвижение»') {
        _advSpentFromBalance += (report.deduction ?? 0);
        return previousValue;
      }
      return previousValue + (report.deduction ?? 0);
    });

    final ppvzForPay = reportsList.fold<double>(
        0, (previousValue, report) => previousValue + (report.ppvzForPay ?? 0));
    _wbCommission = _revenue - ppvzForPay;

    _delivery = reportsList.fold<double>(0,
        (previousValue, report) => previousValue + (report.deliveryRub ?? 0));

    _expensesAndOthers = delivery +
        _storage +
        _penalties +
        _additionalPayment +
        _wbCommission +
        _deduction;
    if (_currentDetailNmId == -1) {
      _pay = _revenue - _expensesAndOthers;
    } else {
      _pay = ppvzForPay - _delivery;
    }

    _cogsSum = salesReports.fold<double>(0, (sum, report) {
      final nmId = report.nmId ?? 0;
      final qty = report.quantity ?? 0;
      final cogs = _cogs[nmId] ?? 0;
      if (cogs == 0) {
        addEmptyCogs(nmId);
      }
      return sum + (qty * cogs);
    });
    if (_currentDetailNmId == -1) {
      _ebitda = _pay - _cogsSum - _advertExpenses;
    } else {
      _ebitda = _pay - _cogsSum;
    }
    _taxValue = _revenue * _tax / 100;
    _profit = _ebitda - _taxValue;

    _profitabilityOfSales = _revenue > 0 ? (_profit / _revenue) * 100 : 0;
  }

  void setSummary(List<RealizationReport> reportsList) {
    calculateSums(reportsList);

    if (_currentDetailNmId == -1) {
      setTotalRevenue(_revenue);
    }
    final salesReports = filterReports(reportsList);

    if (_currentDetailNmId != -1) {
      calculateMinPpvzForPay(reportsList, salesReports);
    } else {
      _minPpvzForPay = 0.0;
      _minPpvzForPayWarehouse = "";
    }
    calculateFinancialMetrics(reportsList, salesReports);
  }

  void updsateSummary(int nmId) {
    // if chosen all  use saved _reports
    if (nmId == -1) {
      setSummary(_reports);
      return;
    }
    // else use only chosen nmId reports
    final nmIdReportsList =
        _reports.where((element) => element.nmId == nmId).toList();

    setSummary(nmIdReportsList);
    notify();
  }

  // dateFrom dateTo
  DateTime? _dateFrom;
  String get dateFrom => _dateFrom == null
      ? ''
      : '${_dateFrom!.day.toString().padLeft(2, '0')}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.year}';
  void setDateFrom(DateTime dateFrom) {
    _dateFrom = dateFrom;
  }

  DateTime? _dateTo;
  String get dateTo => _dateTo == null
      ? ''
      : '${_dateTo!.day.toString().padLeft(2, '0')}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.year}';
  void setDateTo(DateTime dateTo) {
    _dateTo = dateTo;
  }

  // void setInterval(DateTime dateFrom) {
  //   final dateTo = dateFrom.add(const Duration(days: 6));

  //   setDateFrom(dateFrom);
  //   setDateTo(dateTo);
  //   resetSummary();
  //   notify();
  // }
  void setInterval(List<DateTime> dateTimes) {
    if (dateTimes.isEmpty) return;

    dateTimes.sort();
    final dateFrom = dateTimes.first;
    final dateTo = dateTimes.last.add(const Duration(days: 6));

    setDateFrom(dateFrom);
    setDateTo(dateTo);
    resetSummary();
    notify();
  }

  // fetch reports
  Future<void> fetchData() async {
    if (_dateFrom == null || _dateTo == null) {
      return;
    }
    final dateFromStr =
        '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}';
    final dateToStr =
        '${_dateTo!.year}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}';
    setIsLoading(true);

    final values = await Future.wait([
      fetch(
          () => realizationReportService.fetchReportDetailByPeriod(
                dateFrom: dateFromStr,
                dateTo: dateToStr,
              ),
          showError: true,
          message: "Ошибка получения данных от API Статистики"),
      fetch(() => advertService.getApiKey())
    ]);

    final reportsOrNull = values[0] as List<RealizationReport>?;
    final advApiKey = values[1] as String?;
    if (advApiKey != null) {
      final expensesOrNull = await fetch(
          () => advertService.getExpensesSum(from: _dateFrom!, to: _dateTo!));
      if (expensesOrNull != null) {
        setExpenses(expensesOrNull);
      }
    }

    if (reportsOrNull == null) {
      setIsLoading(false);
      return;
    }
    setReports(reportsOrNull);
    final ids =
        reportsOrNull.where((element) => element.realizationreportId >= 100);
    if (ids.isNotEmpty) {
      setReportId(ids.length > 1 ? 0 : ids.first.realizationreportId);
    }

    final allCardsRevenue = reportsOrNull.fold<double>(
        0, (sum, report) => sum + (report.retailAmount ?? 0));

    for (final report in reportsOrNull) {
      final nmId = report.nmId;
      if (nmId == null) {
        continue;
      }
      if (_cogs[nmId] == null) {
        final totalCost =
            await fetch(() => totalCostService.getTotalCost(nmId));
        if (totalCost != null) {
          addCogs(nmId, totalCost.totalCost);

          final taxValue = totalCost.getTax();
          if (_tax == 0 && taxValue != 0) {
            _tax = taxValue;
          }
        }
      }
      final allReportsForNmId =
          reportsOrNull.where((element) => element.nmId == nmId);

      // Revenue for each nmId
      final rev = allReportsForNmId.fold<double>(
          0, (sum, report) => sum + (report.retailAmount ?? 0));

      // Profit for each nmId
      final ppvzForPay = allReportsForNmId.fold<double>(0,
          (previousValue, report) => previousValue + (report.ppvzForPay ?? 0));
      final delivery = allReportsForNmId.fold<double>(0,
          (previousValue, report) => previousValue + (report.deliveryRub ?? 0));

      final pay = ppvzForPay - delivery;

      final revenue = allReportsForNmId.fold<double>(
          0, (sum, report) => sum + (report.retailAmount ?? 0));

      final salesReports = allReportsForNmId.where((element) =>
          element.supplierOperName == 'Продажа' ||
          element.supplierOperName == 'продажа');

      final cogsSum = salesReports.fold<double>(0, (sum, report) {
        final nmId = report.nmId ?? 0;
        final qty = report.quantity ?? 0;
        final cogs = _cogs[nmId] ?? 0;

        return sum + (qty * cogs);
      });
      final ebitda = pay - cogsSum;
      final taxValue = revenue * _tax / 100;
      final profit = ebitda - taxValue;

      // Add images info
      if (_images[nmId] == null) {
        final image =
            await fetch(() => userCardService.getImageForNmId(nmId: nmId));
        if (image != null) {
          addImage(nmId, image, rev / allCardsRevenue, profit);
        }
      }
    }

    sortImages();

    setColors(_images.length);

    setSummary(reportsOrNull);

    setIsLoading(false);
  }

  // Future<void> fetchData() async {
  //   if (_dateFrom == null || _dateTo == null) {
  //     return;
  //   }
  //   final dateFromStr =
  //       '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}';
  //   final dateToStr =
  //       '${_dateTo!.year}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}';
  //   setIsLoading(true);

  //   final values = await Future.wait([
  //     fetch(
  //         () => realizationReportService.fetchReportDetailByPeriod(
  //               dateFrom: dateFromStr,
  //               dateTo: dateToStr,
  //             ),
  //         showError: true,
  //         message: "Ошибка получения данных от API Статистики"),
  //     fetch(() => advertService.getApiKey())
  //   ]);
  //   final reportsOrNull = values[0] as List<RealizationReport>?;
  //   final advApiKey = values[1] as String?;
  //   if (advApiKey != null) {
  //     final expensesOrNull = await fetch(
  //         () => advertService.getExpensesSum(from: _dateFrom!, to: _dateTo!));
  //     if (expensesOrNull != null) {
  //       setExpenses(expensesOrNull);
  //     }
  //   }

  //   if (reportsOrNull == null) {
  //     setIsLoading(false);
  //     return;
  //   }
  //   setReports(reportsOrNull);
  //   final ids =
  //       reportsOrNull.where((element) => element.realizationreportId >= 100);
  //   if (ids.isNotEmpty) {
  //     setReportId(ids.first.realizationreportId);
  //   }

  //   double totalRevenue = 0.0;
  //   double totalProfit = 0.0;
  //   Map<int, double> revenueByNmId = {};
  //   Map<int, double> profitByNmId = {};
  //   Map<int, int> quantityByNmId = {};

  //   for (final report in reportsOrNull) {
  //     final nmId = report.nmId;
  //     if (nmId == null) {
  //       continue;
  //     }

  //     final retailAmount = report.retailAmount ?? 0;
  //     final quantity = report.quantity ?? 0;
  //     final cogs = _cogs[nmId] ?? 0;

  //     revenueByNmId[nmId] = (revenueByNmId[nmId] ?? 0) + retailAmount;
  //     quantityByNmId[nmId] = (quantityByNmId[nmId] ?? 0) + quantity;
  //     profitByNmId[nmId] =
  //         (profitByNmId[nmId] ?? 0) + (retailAmount - cogs * quantity);

  //     totalRevenue += retailAmount;
  //     totalProfit += retailAmount - cogs * quantity;
  //   }

  //   for (final nmId in revenueByNmId.keys) {
  //     if (_images[nmId] == null) {
  //       final image =
  //           await fetch(() => cardOfProductService.getImageForNmId(nmId: nmId));
  //       if (image != null) {
  //         final revenue = revenueByNmId[nmId]!;
  //         final profit = profitByNmId[nmId]!;
  //         addImage(nmId, image, revenue / totalRevenue, profit / totalProfit);
  //       }
  //     }
  //     if (_cogs[nmId] == null) {
  //       final totalCost =
  //           await fetch(() => totalCostService.getTotalCost(nmId));
  //       if (totalCost != null) {
  //         addCogs(nmId, totalCost.totalCost);

  //         final taxValue = totalCost.getTax();
  //         if (_tax == 0 && taxValue != 0) {
  //           _tax = taxValue;
  //         }
  //       }
  //     }
  //   }

  //   sortImages();

  //   setColors(_images.length);

  //   setSummary(reportsOrNull);

  //   setIsLoading(false);
  // }

  bool isMondayFrom3To16() {
    DateTime now = DateTime.now();
    bool isMonday = now.weekday == DateTime.monday;
    bool isTimeBetween = now.hour >= 3 && now.hour < 16;
    return isMonday && isTimeBetween;
  }

  //
  Future<void> addToken() async {
    await Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.apiKeysScreen);
    _asyncInit();
  }

  // Map<String, double> getRevenueDistribution() {
  //   Map<String, double> distribution = {};

  //   for (var entry in _images.entries) {
  //     final nmId = entry.key;
  //     final revenue = entry.value.$2;

  //     if (revenue > 0) {
  //       distribution[nmId.toString()] = revenue;
  //     }
  //   }

  //   return distribution;
  // }
  // Map<String, (double, String)> getRevenueDistributionWithImages() {
  //   Map<String, (double, String)> distribution = {};

  //   for (var entry in _images.entries) {
  //     final nmId = entry.key;
  //     final revenue = entry.value.$2;
  //     final imageUrl = entry.value.$1;

  //     if (revenue > 0) {
  //       distribution[nmId.toString()] = (revenue, imageUrl);
  //     }
  //   }

  //   return distribution;
  // }

  bool _isProfitDestributionActive = false;

  bool get isProfitDestributionActive => _isProfitDestributionActive;
  void setIsRevenueDestributionActive(bool value) {
    _isProfitDestributionActive = value;
    notify();
  }

  Map<String, (double, double, String, bool)>
      getRevenueDistributionWithImages() {
    Map<String, (double, double, String, bool)> distribution = {};

    double totalRevenue =
        _images.values.fold(0, (sum, entry) => sum + entry.$2);
    double totalProfit = _images.values.fold(0, (sum, entry) => sum + entry.$3);

    double cumulativeRevenue = 0;
    double cumulativeProfit = 0;

    List<MapEntry<int, (String, double, double)>> sortedEntries = [];

    if (isProfitDestributionActive) {
      sortedEntries = _images.entries.toList()
        ..sort((a, b) => b.value.$3.compareTo(a.value.$3));
    } else {
      sortedEntries = _images.entries.toList()
        ..sort((a, b) => b.value.$2.compareTo(a.value.$2));
    }

    for (var entry in sortedEntries) {
      final nmId = entry.key;
      final revenue = entry.value.$2;
      final profit = entry.value.$3;
      final imageUrl = entry.value.$1;

      cumulativeRevenue += revenue;
      cumulativeProfit += profit;
      bool isTopContributor = false;
      if (isProfitDestributionActive) {
        isTopContributor = cumulativeProfit / totalProfit <= 0.8;
      } else {
        isTopContributor = cumulativeRevenue / totalRevenue <= 0.8;
      }

      // Ensure that if cumulativeRevenue just exceeded 80%, we still mark this entry
      if (isProfitDestributionActive) {
        if (!isTopContributor &&
            (cumulativeProfit - profit) / totalProfit <= 0.8) {
          isTopContributor = true;
        }
      } else {
        if (!isTopContributor &&
            (cumulativeRevenue - revenue) / totalRevenue <= 0.8) {
          isTopContributor = true;
        }
      }

      distribution[nmId.toString()] =
          (revenue, profit / totalProfit, imageUrl, isTopContributor);
    }

    return distribution;
  }
}
