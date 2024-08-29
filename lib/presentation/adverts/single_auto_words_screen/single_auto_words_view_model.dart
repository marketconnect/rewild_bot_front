// ignore_for_file: prefer_final_fields

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/constants/advertising_constants.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/advert_auto_model.dart';
import 'package:rewild_bot_front/domain/entities/advert_base.dart';
import 'package:rewild_bot_front/domain/entities/auto_campaign_stat.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/keyword.dart';
import 'package:rewild_bot_front/domain/entities/wb_search_log.dart';

// Card of product
abstract class SingleAutoWordsCardOfProductService {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]);
}

//  Keyword
abstract class SingleAutoWordsKeywordService {
  Future<Either<RewildError, AutoCampaignStatWord>> getAutoStatWords(
      {required String token, required int campaignId});
  Future<Either<RewildError, String?>> getToken();
  Future<Either<RewildError, bool>> setAutoExcluded(
      {required String token,
      required int campaignId,
      required List<String> excluded});
  Future<Either<RewildError, Map<int, WbSearchLog>>> fetchAdvInfoForKw(
      {required String keyword, required String gNum, bool secondPage = false});
}

// Advert
abstract class SingleAutoWordsAdvertService {
  Future<Either<RewildError, Advert>> getAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> setCpm(
      {required int campaignId,
      required int type,
      required int cpm,
      required int param,
      int? instrument});
}

// ignore: duplicate_ignore
class SingleAutoWordsViewModel extends ResourceChangeNotifier {
  final SingleAutoWordsKeywordService keywordService;
  final SingleAutoWordsAdvertService advertService;
  final SingleAutoWordsCardOfProductService cardOfProductService;
  final (int, int?, String) campaignIdSubjIdGnum;
  //   subject;

  SingleAutoWordsViewModel(this.campaignIdSubjIdGnum,
      {required super.context,
      required this.cardOfProductService,
      required this.advertService,
      required this.keywordService}) {
    _asyncInit();
  }

  void _asyncInit() async {
    // SqfliteService.printTableContent("keywords");
    await update();
  }

  Future<void> update() async {
    if (_lastUpdate != null) {
      final timeDiff = DateTime.now().difference(_lastUpdate!).inMinutes;
      if (timeDiff < 3) {
        // Do not allow update if the last update was less than a minute ago

        if (ScaffoldMessenger.of(context).mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Нет смысла обновлять данные слишком часто, ${timeDiff < 1 ? "прошло меньше 1 минуты" : timeDiff == 1 ? "прошла всего 1 минута" : "прошло всего $timeDiff минуты"}"),
            ),
          );
        }
        return;
      }
    }

    if (_keywords.isEmpty) {
      await _update();
    } else {
      await _updateOnlyCardsPositions();
    }
    _lastUpdate = DateTime.now();
  }

  Future<void> _update() async {
    setIsLoading(true);

    // Get apiKey first

    final apiKey = await fetch(() => keywordService.getToken(),
        showError: true, message: "Некорректный API-ключ");
    if (apiKey == null) {
      setIsLoading(false);
      return;
    }
    setApiKey(apiKey);

    // Get keywords and advert stats
    final values = await Future.wait([
      fetch(
          () => keywordService.getAutoStatWords(
              token: apiKey, campaignId: campaignIdSubjIdGnum.$1),
          showError: true,
          message:
              "Не удалось получить статистику автоматической кампании по кластерам фраз"),
      fetch(
          () => advertService.getAdvert(
              token: apiKey, campaignId: campaignIdSubjIdGnum.$1),
          showError: true,
          message: "Не удалось получить информацию о кампании"),
    ]);

    // Advert Info
    final autoStatsWordRes = values[0] as AutoCampaignStatWord?;
    final advertInfo = values[1] as Advert?;
    if (autoStatsWordRes == null) {
      setIsLoading(false);
      return;
    }

    autoStatsWordRes.keywords.sort((a, b) => b.count.compareTo(a.count));

    final tempKeywords = autoStatsWordRes.keywords;
    // Merge keywords
    _keywords = [
      ...tempKeywords.where((element) => element.isNew),
      ...tempKeywords.where((element) => !element.isNew),
    ];
    // excluded
    _excludedKeywords = autoStatsWordRes.excluded;

    if (advertInfo == null) {
      setIsLoading(false);
      return;
    }

    // Cluster keywords
    for (final kw in _keywords) {
      if (_keywordClusters[kw.normquery] == null) {
        _keywordClusters[kw.normquery] = [];
      }
      _keywordClusters[kw.normquery]?.add(kw);
    }

    // Excluded keywords
    for (final kw in _excludedKeywords) {
      if (_excludedClusters[kw.normquery] == null) {
        _excludedClusters[kw.normquery] = [];
      }
      _excludedClusters[kw.normquery]?.add(kw);
    }

    // get all cards of user
    final cardsOrNull = await fetch(() => cardOfProductService.getAll());
    if (cardsOrNull == null) {
      setIsLoading(false);
      return;
    }

    // set subject

    // setSubjectId(cardsOrNull.first.subjectId);

    // add nmIds and images urls
    for (final c in cardsOrNull) {
      _allNmIds.add(c.nmId);
      _allNmIdsImages[c.nmId] = c.img;
    }

    _name = advertInfo.name;
    if (advertInfo is AdvertAutoModel &&
        advertInfo.autoParams != null &&
        advertInfo.autoParams!.cpm != null) {
      _cpm = advertInfo.autoParams!.cpm;
      _subjectName = advertInfo.autoParams!.subject!.name!;
    }

    // current advert positions stats
    final clustersWithPositiveSum = _keywordClusters.entries.where((element) {
      return sumTodaySum(element.value) > 0;
    }).toList();
    final clustersForInitFill = clustersWithPositiveSum.length > 100
        ? clustersWithPositiveSum.sublist(0, 100)
        : clustersWithPositiveSum;
    _totalExpense = clustersWithPositiveSum.fold<double>(
      0,
      (previousValue, element) => previousValue + sumTodaySum(element.value),
    );
    int counter = 0;
    for (final clusterName in clustersForInitFill) {
      counter++;
      setLoadingText('Обрабатываю "${clusterName.key}" $counter% ...');
      // filter clusters with no views
      final todaySum = sumTodaySum(clusterName.value);
      if (todaySum == 0) {
        continue;
      }

      final wbLogs = await fetch(
        () => keywordService.fetchAdvInfoForKw(
            keyword: clusterName.key, gNum: campaignIdSubjIdGnum.$3),
      );
      if (wbLogs == null) {
        continue;
      }
      // check if users nmIds contain at least one of the nmIds in adv positions participants
      Map<int, WbSearchLog> wbLog = {};
      List<(int, int, int)> cpmPositions = [];
      for (final id in wbLogs.keys) {
        final cpm = wbLogs[id]!.cpm;
        final position = wbLogs[id]!.position;
        final promo = wbLogs[id]!.promoPosition;

        cpmPositions.add((cpm + 1, position + 1, promo + 1));
        if (_allNmIds.contains(id)) {
          wbLog[id] = wbLogs[id]!;
        }
      }

      _addClasterNameCpmPositions(clusterName.key, cpmPositions);

      _onlineGeneralKWPositionsInfo[clusterName.key] = wbLog;
    }

    setIsLoading(false);
  } // _update

  Future<void> _updateOnlyCardsPositions() async {
    setIsLoading(true);

    setLoadingText('Собираю текущую информацию о позициях карточек...');
    // get all cards of user

    // add nmIds and images urls

    // current advert positions stats
    final clustersWithPositiveSum = _keywordClusters.entries.where((element) {
      return sumTodaySum(element.value) > 0;
    }).toList();
    final clustersForInitFill = clustersWithPositiveSum.length > 100
        ? clustersWithPositiveSum.sublist(0, 100)
        : clustersWithPositiveSum;
    _totalExpense = clustersWithPositiveSum.fold<double>(
      0,
      (previousValue, element) => previousValue + sumTodaySum(element.value),
    );
    int counter = 0;
    for (final clusterName in clustersForInitFill) {
      counter++;
      setLoadingText('Обрабатываю "${clusterName.key}" $counter% ...');
      // filter clusters with no views
      final todaySum = sumTodaySum(clusterName.value);
      if (todaySum == 0) {
        continue;
      }

      final wbLogs = await fetch(
        () => keywordService.fetchAdvInfoForKw(
            keyword: clusterName.key, gNum: campaignIdSubjIdGnum.$3),
      );
      if (wbLogs == null) {
        continue;
      }
      // check if users nmIds contain at least one of the nmIds in adv positions participants
      Map<int, WbSearchLog> wbLog = {};
      List<(int, int, int)> cpmPositions = [];
      for (final id in wbLogs.keys) {
        final cpm = wbLogs[id]!.cpm;
        final position = wbLogs[id]!.position;
        final promo = wbLogs[id]!.promoPosition;

        cpmPositions.add((cpm + 1, position + 1, promo + 1));
        if (_allNmIds.contains(id)) {
          wbLog[id] = wbLogs[id]!;
        }
      }
      _addClasterNameCpmPositions(clusterName.key, cpmPositions);

      _onlineGeneralKWPositionsInfo[clusterName.key] = wbLog;
    }

    setIsLoading(false);
  } // _update

  // loading
  bool _loading = true;
  bool get isLoading => _loading;
  void setIsLoading(bool loading) {
    _loading = loading;
    notify();
  }

  DateTime? _lastUpdate;

  // total expense
  double? _totalExpense;
  double? get totalExpense => _totalExpense;
  void setTotalExpense(double? totalExpense) {
    _totalExpense = totalExpense;
    notify();
  }

  // loading text
  String? _loadingText;
  String? get loadingText => _loadingText;
  void setLoadingText(String? loadingText) {
    _loadingText = loadingText;
    notify();
  }

  // Api Key
  String? _apiKey;
  String? get apiKey => _apiKey;
  void setApiKey(String? apiKey) {
    _apiKey = apiKey;
    notify();
  }

  // void setSubjectId(int? subjectId) {
  //   _subjectId = subjectId;
  // }

  // all saved nmIds
  List<int> _allNmIds = [];
  Map<int, String> _allNmIdsImages = {};
  String allNmIdsImages(int nmId) {
    final e = _allNmIdsImages[nmId];
    if (e == null) {
      return "";
    }

    return e;
  }

  Map<String, List<(int, int, int)>> _clasterNameCpmPositions = {};
  void _addClasterNameCpmPositions(
      String clusterName, List<(int, int, int)> value) {
    value.sort((a, b) => b.$1.compareTo(a.$1));
    final len = value.length;
    final cpms = value.map((e) => e.$1);
    final uniqueCpms = cpms.toSet();
    if (uniqueCpms.length == 1) {
      return;
    }
    _clasterNameCpmPositions[clusterName] = value.sublist(0, len > 5 ? 5 : len);
  }

  Map<String, List<(int, int, int)>> get clasterNameCpmPositions =>
      _clasterNameCpmPositions;

  // Clusters
  // kw
  Map<String, List<Keyword>> _keywordClusters = {};
  // Map<String, List<Keyword>> get keywordClusters => _keywordClusters;
  Map<String, List<Keyword>> get keywordClusters {
    // Create a new map with sorted keywords
    return _keywordClusters.map((clusterKey, keywordsList) {
      // Sort the list by todaySum
      List<Keyword> sortedKeywordsList = List.from(keywordsList)
        ..sort((a, b) => b.todaySum.compareTo(a.todaySum));
      return MapEntry(clusterKey, sortedKeywordsList);
    });
  }

  Map<String, int> _clusterKeywordCounts = {}; // New map to store the counts
  Map<String, int> get clusterKeywordCounts => _clusterKeywordCounts; // Getter
  // excluded
  Map<String, List<Keyword>> _excludedClusters = {};
  Map<String, List<Keyword>> get excludedClusters => _excludedClusters;

  // Online Cluster (genertal word )Positions Info
  Map<String, Map<int, WbSearchLog>> _onlineGeneralKWPositionsInfo = {};
  Map<String, Map<int, WbSearchLog>> get onlineGeneralKWPositionsInfo =>
      _onlineGeneralKWPositionsInfo;
  Map<int, WbSearchLog> onlineGeneralKWPositionsInfoForCluster(
      String clusterName) {
    return _onlineGeneralKWPositionsInfo[clusterName] ?? {};
  }

  // Online rest kw positions
  Map<String, Map<int, WbSearchLog>> _onlineRestKWPositionsInfo = {};
  Map<String, Map<int, WbSearchLog>> get onlineRestKWPositionsInfo =>
      _onlineRestKWPositionsInfo;
  Map<int, WbSearchLog> onlineRestKWPositionsInfoForCluster(String kw) {
    return _onlineRestKWPositionsInfo[kw] ?? {};
  }

  Future<void> addToOnlineRestKWPositionsInfoForCluster(
      List<Keyword> keywords) async {
    if (keywords.isEmpty) {
      return;
    }
    for (final keyword in keywords) {
      if (keyword.todaySum == 0) {
        continue;
      }
      // already in _onlineRestKWPositionsInfo
      if (_onlineRestKWPositionsInfo.containsKey(keyword.keyword)) {
        continue;
      }
      // aleady in _onlineGeneralKWPositionsInfo
      if (_onlineGeneralKWPositionsInfo.containsKey(keyword.keyword)) {
        _onlineRestKWPositionsInfo[keyword.keyword] =
            _onlineGeneralKWPositionsInfo[keyword.keyword]!;
      }
      // fetch
      final wbLogs = await fetch(
        () => keywordService.fetchAdvInfoForKw(
            keyword: keyword.keyword, gNum: campaignIdSubjIdGnum.$3),
      );
      if (wbLogs == null) {
        continue;
      }
      // check if users nmIds contain at least one of the nmIds in adv positions participants
      Map<int, WbSearchLog> wbLog = {};
      for (final id in wbLogs.keys) {
        if (_allNmIds.contains(id)) {
          wbLog[id] = wbLogs[id]!;
        }
      }
      _onlineRestKWPositionsInfo[keyword.keyword] = wbLog;
    }
    notify();
  }

  // Name
  String? _name;
  String? get name => _name ?? '';

  // Subject name
  String? _subjectName;
  String get subjectName => _subjectName ?? '';

  // CPM
  int? _cpm;
  int? get cpm => _cpm;

  List<Keyword> _keywords = [];

  List<Keyword> get keywords => _keywords;

  List<Keyword> _excludedKeywords = [];

  List<Keyword> get excludedKeywords => _excludedKeywords;

  List<String> _changes = [];
  void setChanges(List<String> changes) {
    _changes = changes;
  }

  void change(String word) {
    if (_changes.contains(word)) {
      _changes.remove(word);
    } else {
      _changes.add(word);
    }
  }

  bool get hasChanges => _changes.isNotEmpty;

  Future<void> moveToExcluded(String word, String clusterName) async {
    final kw = keywords.where((element) => element.keyword == word);

    if (kw.isNotEmpty) {
      final kwToSwap = kw.first;
      _keywords.remove(kwToSwap);
      _excludedKeywords.add(kwToSwap);
      change(word);

      // Update the specific cluster
      _excludedClusters.putIfAbsent(clusterName, () => []).add(kwToSwap);
      _keywordClusters[clusterName]?.remove(kwToSwap);

      notify();
    }
  }

  Future<void> moveToKeywords(String word, String clusterName) async {
    final kw = excludedKeywords.where((element) => element.keyword == word);

    if (kw.isNotEmpty) {
      final kwToSwap = kw.first;
      _excludedKeywords.remove(kwToSwap);
      _keywords.add(kwToSwap);
      change(word);

      // Update the specific cluster
      _keywordClusters.putIfAbsent(clusterName, () => []).add(kwToSwap);
      _excludedClusters[clusterName]?.remove(kwToSwap);
    }
    notify();
  }

  Future<void> changeCpm({required String value, required int option}) async {
    final cpm = int.tryParse(value) ?? 0;
    if (_apiKey == null || campaignIdSubjIdGnum.$2 == null) {
      return;
    }

    // if (_searchCpm == null || _advType == null) {
    //   return;
    // }
    if (_apiKey == null) {
      return;
    }
    await fetch(() => advertService.setCpm(
          campaignId: campaignIdSubjIdGnum.$1,
          cpm: cpm,
          type: AdvertTypeConstants.auto,
          param: campaignIdSubjIdGnum.$2!,
        ));
    final advertInfo = await fetch(
        () => advertService.getAdvert(
            token: _apiKey!, campaignId: campaignIdSubjIdGnum.$1),
        showError: true,
        message: "Не удалось получить информацию о кампании");
    if (advertInfo is AdvertAutoModel &&
        advertInfo.autoParams != null &&
        advertInfo.autoParams!.cpm != null) {
      _cpm = advertInfo.autoParams!.cpm;
      notify();
    }
    // _wasCpmOrBudgetChanged = true;
    // _asyncInit();
  }

  Future<void> save() async {
    if (_apiKey == null) {
      return;
    }

    final excludedToAdd = _excludedKeywords.map((e) => e.keyword).toList();
    await fetch(() => keywordService.setAutoExcluded(
        token: _apiKey!,
        campaignId: campaignIdSubjIdGnum.$1,
        excluded: excludedToAdd));

    // Re-cluster keywords after saving
    // _clusterKeywordsByNormQuery(_keywords, _excludedKeywords);
  }

  // Search functionality
  bool _searchInputOpen = false;
  bool get searchInputOpen => _searchInputOpen;
  void toggleSearchInput() {
    _searchInputOpen = !_searchInputOpen;
    _searchQuery = "";
    notify();
  }

  String _searchQuery = '';
  Timer? _debounce;

  String get searchQuery => _searchQuery;
  // void setSearchQuery(String query) {
  //   _searchQuery = query;

  //   notify();
  // }
  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 2000), () {
      _searchQuery = query;
      // Perform the search operation or notify listeners here
      notify();
    });
  }

  double sumTodaySum(List<Keyword> keywords) {
    return keywords.fold(0.0, (sum, item) => sum + item.todaySum);
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
  }
}
