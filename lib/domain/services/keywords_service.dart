import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
import 'package:rewild_bot_front/domain/entities/auto_campaign_stat.dart';
import 'package:rewild_bot_front/domain/entities/keyword.dart';
import 'package:rewild_bot_front/domain/entities/search_campaign_stat.dart';
import 'package:rewild_bot_front/domain/entities/user_seller.dart';
import 'package:rewild_bot_front/domain/entities/wb_search_log.dart';
import 'package:rewild_bot_front/presentation/adverts/single_auto_words_screen/single_auto_words_view_model.dart';

// Api key
abstract class KeywordsServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getWBApiKey(
      {required String type, required String sellerId});
}

// advert api client
abstract class KeywordsServiceAdvertApiClient {
  Future<Either<RewildError, AutoCampaignStatWord>> autoStatWords(
      {required String token, required int campaignId});
  Future<Either<RewildError, SearchCampaignStat>> getSearchStat(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> setAutoSetExcluded(
      {required String token,
      required int campaignId,
      required List<String> excludedKw});
  Future<Either<RewildError, bool>> setSearchExcludedKeywords(
      {required String token,
      required int campaignId,
      required List<String> excludedKeywords});
}

// auto campaigns api client
abstract class KeywordsServiceAutoAdvertApiClient {
  Future<Either<RewildError, List<Keyword>>> fetchAutoCampaignDailyWordsStats(
      {required String token, required int campaignId});
  Future<Either<RewildError, List<Keyword>>> fetchAutoCampaignClusterStats(
      {required String token, required int campaignId});
}

// geo search
abstract class KeywordsServiceGeoSearchApiClient {
  Future<Either<RewildError, Map<int, WbSearchLog>>> getProductsNmIdAdv(
      {required String gNum, required String query, bool secondPage = false});
}

// data provider
abstract class KeywordsServiceKeywordsDataProvider {
  Future<Either<RewildError, List<Keyword>>> getAll(int campaignId);
  Future<Either<RewildError, bool>> save(Keyword keyword);
  Future<Either<RewildError, Keyword>> updateWithNormQuery(
      String keyword, String normQuery);
}

// active seller
abstract class KeywordServiceActiveSellerDataProvider {
  Future<Either<RewildError, List<UserSeller>>> getActive();
}

class KeywordsService implements SingleAutoWordsKeywordService
//  SingleSearchWordsKeywordService
{
  final KeywordsServiceApiKeyDataProvider apiKeysDataProvider;
  final KeywordsServiceAdvertApiClient advertApiClient;
  final KeywordsServiceGeoSearchApiClient geoSearchApiClient;
  final KeywordsServiceKeywordsDataProvider keywordsDataProvider;
  final KeywordsServiceAutoAdvertApiClient autoAdvertApiClient;
  final KeywordServiceActiveSellerDataProvider activeSellerDataProvider;
  KeywordsService({
    required this.apiKeysDataProvider,
    required this.advertApiClient,
    required this.activeSellerDataProvider,
    required this.keywordsDataProvider,
    required this.geoSearchApiClient,
    required this.autoAdvertApiClient,
  });

  static const numberOfAttempts = 5;

  @override
  Future<Either<RewildError, String?>> getToken() async {
    // Get active seller
    final activeSellerOrElse = await activeSellerDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);

    // Get Api key
    final tokenEither = await apiKeysDataProvider.getWBApiKey(
        type: 'Продвижение', sellerId: activeSeller.first.sellerId);

    return tokenEither.fold((l) => left(l), (apiKeyModel) async {
      if (apiKeyModel == null) {
        return right(null);
      }
      return right(apiKeyModel.token);
    });
  }

  @override
  Future<Either<RewildError, bool>> setAutoExcluded(
      {required String token,
      required int campaignId,
      required List<String> excluded}) async {
    final autoExcludedEither = await advertApiClient.setAutoSetExcluded(
        token: token, campaignId: campaignId, excludedKw: excluded);
    return autoExcludedEither.fold((l) => left(l), (r) => right(r));
  }

  @override
  Future<Either<RewildError, AutoCampaignStatWord>> getAutoStatWords(
      {required String token, required int campaignId}) async {
    final values = await Future.wait([
      advertApiClient.autoStatWords(token: token, campaignId: campaignId), // 1
      keywordsDataProvider.getAll(campaignId), // 2
      autoAdvertApiClient.fetchAutoCampaignClusterStats(
          token: token, campaignId: campaignId), // 3
      autoAdvertApiClient.fetchAutoCampaignDailyWordsStats(
          token: token, campaignId: campaignId) // 4
    ]);

    // get current auto stat from API (incl. excluded keywords) and DB     // 1
    final currentAutoStatEither =
        values[0] as Either<RewildError, AutoCampaignStatWord>;

    if (currentAutoStatEither.isLeft()) {
      return currentAutoStatEither;
    }
    final autoStat =
        currentAutoStatEither.fold((l) => throw UnimplementedError(), (r) => r);

    // final keywordsFromApi = autoStat.keywords
    //     .map((e) => Keyword(
    //           keyword: e.keyword,
    //           count: e.count,
    //           campaignId: campaignId,
    //         ))
    //     .toList();

    final excludedFromApi = autoStat.excluded.toList();

    // get saved auto stat from DB                                         // 2
    final savedKeywordsEither = values[1] as Either<RewildError, List<Keyword>>;
    if (savedKeywordsEither.isLeft()) {
      return left(savedKeywordsEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }
    final savedKeywords =
        savedKeywordsEither.fold((l) => throw UnimplementedError(), (r) => r);

    // get clusters from API                                               // 3
    final clustersEither = values[2] as Either<RewildError, List<Keyword>>;
    if (clustersEither.isLeft()) {
      return left(
          clustersEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final clusters =
        clustersEither.fold((l) => throw UnimplementedError(), (r) => r);

    // get daily words from API                                            // 4
    final dailyWordsEither = values[3] as Either<RewildError, List<Keyword>>;
    if (dailyWordsEither.isLeft()) {
      return left(
          dailyWordsEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final dailyWords =
        dailyWordsEither.fold((l) => throw UnimplementedError(), (r) => r);

    List<Keyword> newKeywords = [];
    for (var cl in clusters) {
      // final kwFromApi = keywordsFromApi.where((c) => c.keyword == cl.keyword);

      if (!savedKeywords.any((e) => e.keyword == cl.keyword)) {
        newKeywords.add(cl);
        // save in database
        final saveEither = await keywordsDataProvider.save(cl);
        if (saveEither.isLeft()) {
          return Left(
              saveEither.fold((err) => err, (r) => throw UnimplementedError()));
        }
        continue;
      }

      // keyword exists in DB
      cl.setNotNew();
      final savedKeyword =
          savedKeywords.firstWhere((e) => e.keyword == cl.keyword);

      // saved keyword count is different
      if (savedKeyword.count != cl.count) {
        // set diff property
        cl.setDiff(savedKeyword.count);
        // update in database
        final saveEither = await keywordsDataProvider.save(cl);
        if (saveEither.isLeft()) {
          return Left(
              saveEither.fold((err) => err, (r) => throw UnimplementedError()));
        }
        continue;
      }
      // Saved keyword normquery is not empty and new keyword normquery is empty
      if (cl.normquery.isEmpty && savedKeyword.normquery.isNotEmpty) {
        cl.normquery = savedKeyword.normquery;
        // update in database
      } else if (savedKeyword.normquery != cl.normquery) {
        // update in database
        final saveEither = await keywordsDataProvider.save(cl);
        if (saveEither.isLeft()) {
          return Left(
              saveEither.fold((err) => err, (r) => throw UnimplementedError()));
        }
        continue;
      }
      final dailyWord = dailyWords.where((e) => e.keyword == cl.keyword);
      if (dailyWord.isNotEmpty) {
        cl.todayClicks = dailyWord.first.todayClicks;
        cl.todayCtr = dailyWord.first.todayCtr;
        cl.todaySum = dailyWord.first.todaySum;
        cl.todayViews = dailyWord.first.todayViews;
      }
      final kwAlreadyexist = newKeywords.where((element) => element == cl);
      if (kwAlreadyexist.isEmpty) {
        newKeywords.add(cl);
      }
    }
    final newAutoStat = autoStat.copyWith(keywords: newKeywords);

    List<Keyword> newExcluded = [];
    for (var excluded in excludedFromApi) {
      // the keyword does not exist in DB
      if (!savedKeywords.any((e) => e.keyword == excluded.keyword)) {
        newKeywords.add(excluded);
        // save in database
        final saveEither = await keywordsDataProvider.save(excluded);
        if (saveEither.isLeft()) {
          return Left(
              saveEither.fold((err) => err, (r) => throw UnimplementedError()));
        }
        continue;
      } else {
        // if exists add normquery
        final savedKeyword =
            savedKeywords.firstWhere((e) => e.keyword == excluded.keyword);
        excluded.normquery = savedKeyword.normquery;
      }
      final todayWord = dailyWords.where((e) => e.keyword == excluded.keyword);
      if (todayWord.isNotEmpty) {
        excluded.todayClicks = todayWord.first.todayClicks;
        excluded.todayCtr = todayWord.first.todayCtr;
        excluded.todaySum = todayWord.first.todaySum;
        excluded.todayViews = todayWord.first.todayViews;
      }
      newExcluded.add(excluded);
    }
    final newAutoStatWithExcluded = newAutoStat.copyWith(excluded: newExcluded);

    return right(newAutoStatWithExcluded);
  }

  @override
  Future<Either<RewildError, Map<int, WbSearchLog>>> fetchAdvInfoForKw(
      {required String keyword,
      required String gNum,
      bool secondPage = false}) async {
    if (keyword.isEmpty) {
      return left(RewildError(
        sendToTg: true,
        "Empty keyword",
        name: "fetchAndSaveNormQueries",
        source: "KeywordsService",
      ));
    }

    Either<RewildError, Map<int, WbSearchLog>> advInfoEither =
        await geoSearchApiClient.getProductsNmIdAdv(
      query: keyword,
      gNum: gNum,
    );
    if (advInfoEither is Left) {
      for (int n = 0; n < numberOfAttempts; n++) {
        advInfoEither = await geoSearchApiClient.getProductsNmIdAdv(
          query: keyword,
          gNum: gNum,
        );
        if (advInfoEither is Right) {
          break;
        }
      }
      // return Left(
      //     advInfoEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    Map<int, WbSearchLog>? advInfo = advInfoEither.fold((l) => null, (r) => r);
    if (advInfo == null || advInfo.keys.length <= 1) {
      for (int n = 0; n < numberOfAttempts; n++) {
        advInfoEither = await geoSearchApiClient.getProductsNmIdAdv(
          query: keyword,
          gNum: gNum,
        );
        if (advInfoEither is Right) {
          break;
        }
        advInfo = advInfoEither.fold((l) => null, (r) => r);
      }
      // return Left(
      //     advInfoEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    if (advInfo == null) {
      return left(RewildError(
        sendToTg: false,
        "No ad found",
        name: "fetchAdvInfoForKw",
        source: "KeywordsService",
      ));
    }
    return right(advInfo);
  }
}
