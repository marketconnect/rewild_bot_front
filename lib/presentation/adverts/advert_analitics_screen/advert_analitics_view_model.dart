import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/campaign_data.dart';
import 'package:rewild_bot_front/domain/entities/total_cost_calculator.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// advert analitics
abstract class AdvertAnaliticsAdvertsAnaliticsService {
  Future<Either<RewildError, CampaignData?>> getCampaignDataByInterval(
      {required int campaignId, required (String, String) interval});
  Future<Either<RewildError, bool>> apiKeyExists();
}

// cards
abstract class AdvertAnaliticsScreenCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
}

// total cost
abstract class AdvertAnaliticsTotalCostService {
  Future<Either<RewildError, TotalCostCalculator>> getTotalCost(int nmId);
}

// token
abstract class AdvertAnaliticsAuthService {
  Future<Either<RewildError, String>> getToken();
}

// average logistics price from server
abstract class AdvertAnaliticsTariffService {
  Future<Either<RewildError, int>> getCurrentAverageLogistics(
      {required String token});
}

class AdvertAnaliticsViewModel extends ResourceChangeNotifier {
  final (int, DateTime, String) campaignInfo;
  final AdvertAnaliticsAdvertsAnaliticsService advAnaliticsService;
  final AdvertAnaliticsScreenCardOfProductService cardOfProductService;
  final AdvertAnaliticsTotalCostService totalCostService;
  final AdvertAnaliticsAuthService authService;
  final AdvertAnaliticsTariffService tariffService;
  AdvertAnaliticsViewModel(
      {required super.context,
      required this.campaignInfo,
      required this.tariffService,
      required this.authService,
      required this.cardOfProductService,
      required this.totalCostService,
      required this.advAnaliticsService}) {
    setCampaignCreatedAt(campaignInfo.$2);
    setCampaignName(campaignInfo.$3);
    if (_campaignCreatedAt.isAfter(startDate)) {
      _startDate = _campaignCreatedAt;
    }
    _asyncInit();
  }

  _asyncInit() async {
    setIsLoading(true);
    setLoadingText("Получаю информацию о кампании...");
    // await SubscriptionDataProvider.fakeInsert();
    // SqfliteService.printTableContent('subs');
    // check api key
    final apiKey = await fetch(() => advAnaliticsService.apiKeyExists());
    if (apiKey == null || !apiKey) {
      setApiKeyExists(false);
    } else {
      setApiKeyExists(true);
    }

    // token
    final tokenOrNull = await fetch(() => authService.getToken());
    if (tokenOrNull == null) {
      setIsLoading(false);
      return;
    }

    final prof = await calculateTotalProfit();
    setProfit(prof);

    setIsLoading(false);
  } // _asyncInit

  // loading
  bool _isLoading = false;
  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notify();
  }

  bool get isLoading => _isLoading;

  // loading text
  String? _loadingText = "";
  void setLoadingText(String loadingText) {
    _loadingText = loadingText;
    notify();
  }

  String? get loadingText => _loadingText;

  // Api key exists
  bool _apiKeyExists = false;
  void setApiKeyExists(bool apiKeyExists) {
    _apiKeyExists = apiKeyExists;
    notify();
  }

  bool get apiKeyExists => _apiKeyExists;

  // profit
  double _profit = 0;
  void setProfit(double profit) {
    _profit = profit;
  }

  double get profit => _profit;
  // campaign name
  String _campaignName = "";
  void setCampaignName(String campaignName) {
    _campaignName = campaignName;
  }

  String get campaignName => _campaignName;

  // campaign createdAt
  DateTime _campaignCreatedAt = DateTime.now();
  void setCampaignCreatedAt(DateTime? date) {
    if (date == null) {
      return;
    }
    _campaignCreatedAt = date;
  }

  DateTime get createdAt => _campaignCreatedAt;

  // Images
  // ignore: prefer_final_fields
  Map<int, String> _images = {};

  void addImage(int nmId, String value) {
    _images[nmId] = value;
  }

  Map<int, String> get images => _images;

  // current detail nmId
  int _currentDetailNmId = -1;
  void setCurrentDetailNmId(int nmId) {
    _currentDetailNmId = nmId;
    notify();
  }

  int get currentDetailNmId => _currentDetailNmId;

  // Period
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  void setStartDate(DateTime? date) {
    if (date == null) {
      return;
    }

    _startDate = date;
  }

  DateTime get startDate => _startDate;

  // end
  DateTime _endDate = DateTime.now();
  void setEndDate(DateTime? date) {
    if (date == null) {
      return;
    }
    _endDate = date;
  }

  DateTime get endDate => _endDate;

  // Days
  // selected days
  bool noDays = true;
  List<CampaignDataDay> _selectedData = [];
  void setSelectedData(List<CampaignDataDay> selectedData) {
    _selectedData = selectedData;
    if (_selectedData.isNotEmpty) {
      noDays = false;
    }
  }

  List<CampaignDataDay> get selectedData => _selectedData;

  // previous days
  List<CampaignDataDay> _previousData = [];
  bool noPreviousDays = true;
  void setPreviousData(List<CampaignDataDay> previousData) {
    _previousData = previousData;
    if (_previousData.isNotEmpty) {
      noPreviousDays = false;
    }
  }

  List<CampaignDataDay> get previousData => _previousData;

  // nmIds days
  // selected
  final Map<int, List<CampaignDataDay>> _nmIdsSelectedData = {};

  void setNmIdsSelectedData(int nmId, List<CampaignDataDay> data) {
    if (_nmIdsSelectedData[nmId] == null) {
      _nmIdsSelectedData[nmId] = data;
      return;
    }
    _nmIdsSelectedData[nmId]!.addAll(data);
  }

  List<CampaignDataDay>? getNmIdsSelectedData(int nmId) {
    return _nmIdsSelectedData[nmId];
  }

  // previous nmIds days
  final Map<int, List<CampaignDataDay>> _nmIdsPreviousData = {};

  void setNmIdsPreviousData(int nmId, List<CampaignDataDay> data) {
    if (_nmIdsPreviousData[nmId] == null) {
      _nmIdsPreviousData[nmId] = data;
      return;
    }
    _nmIdsPreviousData[nmId]!.addAll(data);
  }

  List<CampaignDataDay>? getNmIdsPreviousData(int nmId) {
    return _nmIdsPreviousData[nmId];
  }

  // Total
  // selected data
  CampaignDataDay? _totalSelectedData;
  void setTotalSelectedData(CampaignDataDay? totalData) {
    _totalSelectedData = totalData;
  }

  CampaignDataDay? get totalSelectedData => _totalSelectedData;
  // date
  String _selectedStartDate = '';
  void setSelectedStartDate(String selectedStartDate) {
    _selectedStartDate = selectedStartDate;
  }

  String get selectedStartDate => _selectedStartDate;
  String _selectedEndDate = '';
  void setSelectedEndDate(String selectedEndDate) {
    _selectedEndDate = selectedEndDate;
  }

  String get selectedEndDate => _selectedEndDate;

  // previous data
  CampaignDataDay? _totalPreviousData;
  void setTotalPreviousData(CampaignDataDay? totalData) {
    _totalPreviousData = totalData;
  }

  CampaignDataDay? get totalPreviousData => _totalPreviousData;

  // selected nmIds data
  final Map<int, CampaignDataDay> _nmIdsTotalSelectedData = {};

  void setNmIdsTotalSelectedData(int nmId, CampaignDataDay data) {
    _nmIdsTotalSelectedData[nmId] = data;
  }

  CampaignDataDay? getNmIdsTotalSelectedData(int nmId) {
    return _nmIdsTotalSelectedData[nmId];
  }

  // previous nmIds data
  final Map<int, CampaignDataDay> _nmIdsTotalPreviousData = {};

  void setNmIdsTotalPreviousData(int nmId, CampaignDataDay data) {
    _nmIdsTotalPreviousData[nmId] = data;
  }

  CampaignDataDay? getNmIdsTotalPreviousData(int nmId) {
    return _nmIdsTotalPreviousData[nmId];
  }

  int _averageLogisticCost = 50;
  void setAverageLogisticCost(int averageLogisticCost) {
    _averageLogisticCost = averageLogisticCost;
  }

  int get averageLogisticCost => _averageLogisticCost;

  // date
  String _previousStartDate = '';
  void setPreviousStartDate(String previousStartDate) {
    _previousStartDate = previousStartDate;
  }

  String get previousStartDate => _previousStartDate;

  String _previousEndDate = '';
  void setPreviousEndDate(String previousEndDate) {
    _previousEndDate = previousEndDate;
  }

  String get previousEndDate => _previousEndDate;

  // Total costs
  Map<int, TotalCostCalculator?> _totalCosts = {};
  void setTotalCosts(Map<int, TotalCostCalculator> value) {
    _totalCosts = value;
  }

  void addTotalCost(int nmId, TotalCostCalculator? value) {
    _totalCosts[nmId] = value;
  }

  Map<int, TotalCostCalculator?> get totalCosts => _totalCosts;
  bool gotNullFromWb = false;
  //
  // Cpms
  // List<double> _cpms = [];
  // void setCpms(List<double> cpms) {
  //   _cpms = cpms;
  // }

  // List<double> get cpms => _cpms;

  // CTRs
  // List<double> _ctrs = [];
  // void setCtr(List<double> ctrs) {
  //   _ctrs = ctrs;
  // }

  // List<double> get ctrs => _ctrs;

  // ROIs
  // List<double> _rois = [];
  // void setRoi(List<double> rois) {
  //   _rois = rois;
  // }

  // List<double> get rois => _rois;

  // corelation
  bool notEnoughData = true;
  bool thresholdIsNotExceeded = true;

  // CPM -> CTR
  double? _cpmCtrcorrelation;
  void setCpmCtrCorrelation(double? correlation) {
    _cpmCtrcorrelation = correlation;
  }

  double? get cpmCtrcorrelation => _cpmCtrcorrelation;
  // CPM -> ROI
  double? _cpmRoiCorrelation;
  void setCpmRoiCorrelation(double? correlation) {
    _cpmRoiCorrelation = correlation;
  }

  double? get cpmRoiCorrelation => _cpmRoiCorrelation;

  // fetch ==========================================================================================
  Future<void> fetchCampaignData() async {
    gotNullFromWb = false;
    setIsLoading(true);

    // prepare interval for fetch
    (String, String) interval =
        (formatYYYYMMDD(_startDate), formatYYYYMMDD(_endDate));

    final startEndRange = DateTimeRange(
      start: _startDate,
      end: _endDate.add(const Duration(days: 1)),
    );
    DateTime prevStartDate = _startDate.subtract(startEndRange.duration);
    if (prevStartDate.isBefore(_campaignCreatedAt)) {
      prevStartDate = _campaignCreatedAt;
    }

    interval = (formatYYYYMMDD(prevStartDate), formatYYYYMMDD(_endDate));

    // fetch data
    final fetchedCampaignDataOrNull = await fetch(() =>
        advAnaliticsService.getCampaignDataByInterval(
            campaignId: campaignInfo.$1, interval: interval));

    if (fetchedCampaignDataOrNull == null) {
      gotNullFromWb = true;
      setIsLoading(false);
      return;
    }
    final fetchedCampaignDays = fetchedCampaignDataOrNull.days;

    _previousData = fetchedCampaignDays
        .where((element) => DateTime.parse(element.date).isBefore(_startDate))
        .toList();
    _selectedData = fetchedCampaignDays
        .where((element) => DateTime.parse(element.date).isAfter(_startDate))
        .toList();

    // previous
    if (_previousData.isNotEmpty) {
      setPreviousData(_previousData);
      setTotalPreviousData(_calculateTotalForPeriod(_previousData));
      final first = convertDateTime(_previousData.first.date);
      setPreviousStartDate(first);
      final last = convertDateTime(_previousData.last.date);
      setPreviousEndDate(last);
    }
    // selected
    setSelectedData(_selectedData);
    setTotalSelectedData(_calculateTotalForPeriod(_selectedData));
    final sFirst = convertDateTime(_selectedData.first.date);
    final sLast = convertDateTime(_selectedData.last.date);
    setSelectedStartDate(sFirst);
    setSelectedEndDate(sLast);

    // images and nmIds data
    final firsApp = _selectedData.first.apps;
    if (firsApp.isNotEmpty) {
      final nmIds = firsApp.first.nm;
      for (final nmId in nmIds) {
        final image = await fetch(
          () => cardOfProductService.getImageForNmId(nmId: nmId.nmId),
        );
        if (image == null) {
          continue;
        }
        // Image
        addImage(nmId.nmId, image);

        // selected data
        setNmIdsSelectedData(
            nmId.nmId, daysFromAppsForNmId(nmId.nmId, _selectedData));
        if (_nmIdsSelectedData[nmId.nmId] != null) {
          setNmIdsTotalSelectedData(nmId.nmId,
              _calculateTotalForPeriod(_nmIdsSelectedData[nmId.nmId]!));
        }

        // previous data
        if (_previousData.isNotEmpty) {
          setNmIdsPreviousData(
              nmId.nmId, daysFromAppsForNmId(nmId.nmId, _previousData));
          if (_nmIdsPreviousData[nmId.nmId] != null) {
            setNmIdsTotalPreviousData(nmId.nmId,
                _calculateTotalForPeriod(_nmIdsPreviousData[nmId.nmId]!));
          }
        }

        // total cost
        final totalCostOrNull = await fetch(
          () => totalCostService.getTotalCost(nmId.nmId),
        );
        if (totalCostOrNull == null) {
          continue;
        }
        addTotalCost(nmId.nmId, totalCostOrNull);
      }
    }
    final prof = await calculateTotalProfit();
    setProfit(prof);

    // correlation
    if (_selectedData.length < 25) {
      setIsLoading(false);
      return;
    }
    notEnoughData = false;
    if (!_isThresholdExceeded(_selectedData)) {
      setIsLoading(false);
      return;
    }

    thresholdIsNotExceeded = false;

    // Correlations
    setCorrelations(_selectedData);

    setIsLoading(false);
    return;
  } // fetchCampaignData =======================================================================close

  Future<double> calculateTotalProfit() async {
    // total orders
    Map<int, int> nmIdOrders = {};
    for (final day in _selectedData) {
      for (final app in day.apps) {
        for (final nmId in app.nm) {
          // update orders for nmId
          if (nmIdOrders[nmId.nmId] == null) {
            nmIdOrders[nmId.nmId] = nmId.shks;
          } else {
            nmIdOrders[nmId.nmId] = nmIdOrders[nmId.nmId]! + nmId.shks;
          }
        }
      }
    }

    // average logistic cost from server

    final averageLogisticCostFromServerOrNull = await fetch(
      () => tariffService.getCurrentAverageLogistics(token: 'token'),
    );
    if (averageLogisticCostFromServerOrNull != null) {
      setAverageLogisticCost(averageLogisticCostFromServerOrNull);
    }
    // gross profit
    Map<int, int> nmIdGrossProfit = {};
    for (final nmId in nmIdOrders.keys) {
      final totalCost = _totalCosts[nmId];
      if (totalCost != null) {
        nmIdGrossProfit[nmId] =
            totalCost.grossProfit(_averageLogisticCost).round();
      }
    }

    double totalProfit = 0;
    for (final nmId in nmIdGrossProfit.keys) {
      final orders = nmIdOrders[nmId];
      if (orders != null) {
        totalProfit += nmIdGrossProfit[nmId]! * orders;
      }
    }
    return totalProfit;
  }

  void setCorrelations(List<CampaignDataDay> selectedData) {
    List<double> cpms = [];
    List<double> ctrs = [];
    List<double> rois = [];
    // Correlations
    cpms.clear();
    ctrs.clear();
    rois.clear();
    // CPM -> CTR
    for (var data in selectedData) {
      cpms.add(data.cpm);
      ctrs.add(data.ctr);
    }

    final cpmCtrCorelationCoef = analyzeCorrelation(cpms, ctrs);
    setCpmCtrCorrelation(cpmCtrCorelationCoef);

    // CPM -> ROI
    rois = selectedData.map((data) => data.roi).toList();
    final cpmRoiCorelationCoef = analyzeCorrelation(cpms, rois);
    setCpmRoiCorrelation(cpmRoiCorelationCoef);
    // setCtr(_ctrs);
    // setRoi(rois);
  }

  CampaignDataDay _calculateTotalForPeriod(List<CampaignDataDay> dataDays) {
    int totalViews = 0;
    int totalClicks = 0;
    double totalSum = 0.0;
    int totalAtbs = 0;
    int totalOrders = 0;
    int totalCr = 0;
    int totalShks = 0;
    double totalSumPrice = 0.0;

    // sort by date
    dataDays.sort(
        (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

    // for calculating the average CTR and CPC, we add all CTR and CPC, and then divide by the number of days
    double totalCtr = 0.0;
    double totalCpc = 0.0;

    for (var day in dataDays) {
      totalViews += day.views;
      totalClicks += day.clicks;
      totalSum += day.sum;
      totalAtbs += day.atbs;
      totalOrders += day.orders;
      totalCr += day.cr;
      totalShks += day.shks;
      totalSumPrice += day.sumPrice;

      // add CTR and CPC for each day to calculate the average
      totalCtr += day.ctr;
      totalCpc += day.cpc;
    }

    // calculate average CTR and CPC
    double averageCtr = dataDays.isNotEmpty ? totalCtr / dataDays.length : 0.0;
    double averageCpc = dataDays.isNotEmpty ? totalCpc / dataDays.length : 0.0;

    return CampaignDataDay(
      date: dataDays.first.date,
      views: totalViews,
      clicks: totalClicks,
      ctr: averageCtr,
      cpc: averageCpc,
      sum: totalSum,
      atbs: totalAtbs,
      orders: totalOrders,
      cr: totalCr,
      shks: totalShks,
      sumPrice: totalSumPrice,
      apps: [],
    );
  }

  Map<String, dynamic>? calculateDynamic(
      CampaignDataDay? totalPreviousData, CampaignDataDay? totalSelectedData) {
    if (totalSelectedData == null || totalPreviousData == null) {
      return null;
    }

    Map<String, dynamic> dynamicData = {};

    dynamicData['viewsChange'] = _calculatePercentageChange(
        totalPreviousData.views, totalSelectedData.views);
    dynamicData['clicksChange'] = _calculatePercentageChange(
        totalPreviousData.clicks, totalSelectedData.clicks);
    dynamicData['ctrChange'] = _calculatePercentageChange(
        totalPreviousData.ctr, totalSelectedData.ctr);
    dynamicData['cpcChange'] = _calculatePercentageChange(
        totalPreviousData.cpc, totalSelectedData.cpc);
    dynamicData['sumChange'] = _calculatePercentageChange(
        totalPreviousData.sum, totalSelectedData.sum);
    dynamicData['atbsChange'] = _calculatePercentageChange(
        totalPreviousData.atbs, totalSelectedData.atbs);
    dynamicData['ordersChange'] = _calculatePercentageChange(
        totalPreviousData.orders, totalSelectedData.orders);
    dynamicData['crChange'] =
        _calculatePercentageChange(totalPreviousData.cr, totalSelectedData.cr);
    dynamicData['shksChange'] = _calculatePercentageChange(
        totalPreviousData.shks, totalSelectedData.shks);
    dynamicData['sumPriceChange'] = _calculatePercentageChange(
        totalPreviousData.sumPrice, totalSelectedData.sumPrice);
    dynamicData['roiChange'] = _calculatePercentageChange(
        totalPreviousData.roi, totalSelectedData.roi);
    dynamicData['costPerOrderChange'] = _calculatePercentageChange(
        totalPreviousData.sum / totalPreviousData.orders,
        totalSelectedData.sum / totalSelectedData.orders);
    return dynamicData;
  }

  int _calculatePercentageChange(num oldValue, num newValue) {
    if (oldValue == 0) {
      if (newValue == 0) {
        return 0;
      }

      return newValue > 0 ? 100 : -100;
    }

    num change = ((newValue - oldValue) / oldValue) * 100;

    return change.round();
  }

  double? analyzeCorrelation(List<double> xList, List<double> yList) {
    if (xList.length != yList.length) {
      return null;
    }

    double averageCPM = xList.reduce((a, b) => a + b) / xList.length;
    double averageCTR = yList.reduce((a, b) => a + b) / yList.length;

    double numerator = 0;
    double denominatorPart1 = 0;
    double denominatorPart2 = 0;

    for (int i = 0; i < xList.length; i++) {
      double cpmDeviation = xList[i] - averageCPM;
      double ctrDeviation = yList[i] - averageCTR;

      numerator += cpmDeviation * ctrDeviation;
      denominatorPart1 += cpmDeviation * cpmDeviation;
      denominatorPart2 += ctrDeviation * ctrDeviation;
    }

    // Check for division by zero
    if (denominatorPart1 == 0 || denominatorPart2 == 0) {
      return double.nan;
    }

    double correlationCoefficient =
        numerator / (sqrt(denominatorPart1) * sqrt(denominatorPart2));

    // round to 2 decimal places
    correlationCoefficient =
        double.parse(correlationCoefficient.toStringAsFixed(2));

    return correlationCoefficient;
  }

  double _calculateAverageCPM(List<CampaignDataDay> campaignData) {
    double sum = 0;
    for (var data in campaignData) {
      sum += data.cpm;
    }
    return sum / campaignData.length;
  }

  bool _isThresholdExceeded(List<CampaignDataDay> campaignData,
      {double lowerBound = 10}) {
    double averageCPM = _calculateAverageCPM(campaignData);
    double minChange = averageCPM * (lowerBound / 100);
    // double maxChange = averageCPM * (upperBound / 100);

    for (int i = 1; i < campaignData.length; i++) {
      double previousCPM = campaignData[i - 1].cpm;
      double currentCPM = campaignData[i].cpm;
      double change = (currentCPM - previousCPM).abs();

      if (change >= minChange) {
        return true;
      }
    }

    return false;
  }

  // NmIds
  List<CampaignDataDay> daysFromAppsForNmId(
      int nmId, List<CampaignDataDay> days) {
    List<CampaignDataDay> updatedSelectedData = [];

    // print('days length: ${days.length}');
    // iterates through each day in the selected data
    for (var day in days) {
      // iterates through each app in the current day
      List<CampaignDataNm> nms = [];
      for (var app in day.apps) {
        List<CampaignDataNm> filteredNm =
            app.nm.where((nm) => nm.nmId == nmId).toList();

        nms.addAll(filteredNm);
      }

      if (nms.isNotEmpty) {
        int views = 0;
        int clicks = 0;
        double ctr = 0;
        double cpc = 0;
        double sum = 0;
        int atbs = 0;
        int orders = 0;
        int cr = 0;
        int shks = 0;
        double sumPrice = 0;
        for (var nm in nms) {
          views += nm.views;
          clicks += nm.clicks;
          ctr += nm.ctr;
          cpc += nm.cpc;
          sum += nm.sum;
          atbs += nm.atbs;
          orders += nm.orders;
          cr += nm.cr;
          shks += nm.shks;
          sumPrice += nm.sumPrice;
        }
        updatedSelectedData.add(CampaignDataDay(
          date: day.date,
          views: views,
          clicks: clicks,
          ctr: ctr,
          cpc: cpc,
          sum: sum,
          atbs: atbs,
          orders: orders,
          cr: cr,
          shks: shks,
          sumPrice: sumPrice,
          apps: [],
        ));
      }
    }

    // update the selected data

    return updatedSelectedData;
  }

  Future<void> goToCard(int nmId) async {
    await Navigator.of(context).pushNamed(
      MainNavigationRouteNames.singleCardScreen,
      arguments: nmId,
    );
    final totalCostOrNull = await fetch(
      () => totalCostService.getTotalCost(nmId),
    );
    if (totalCostOrNull == null) {
      return;
    }

    addTotalCost(nmId, totalCostOrNull);
    notify();
  }
}
