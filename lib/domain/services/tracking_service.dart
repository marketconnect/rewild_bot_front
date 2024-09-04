import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/geo_search_model.dart';
import 'package:rewild_bot_front/domain/entities/subscription_api_models.dart';

import 'package:rewild_bot_front/domain/entities/tracking_query.dart';
import 'package:rewild_bot_front/domain/entities/tracking_result.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_kw_research_view_model.dart';

// subscription data provider
abstract class TrackingServiceSubscriptionDataProvider {
  Future<Either<RewildError, List<SubscriptionV2Response>>> get();
}

// geo search api client
abstract class TrackingServiceGeoSearchApiClient {
  Future<Either<RewildError, Map<int, GeoSearchModel>>>
      getProductsNmIdIndexMapIn(
          {required String query,
          required List<int> nmIds,
          bool secondPage = false});
  Future<Either<RewildError, Map<int, GeoSearchModel>>>
      getProductsNmIdIndexMapWithGeo(
          {required String gNum,
          required String query,
          bool secondPage = false,
          required List<int> nmIds});
}

// query data provider
abstract class TrackingServiceQueryDataProvider {
  Future<Either<RewildError, void>> addQuery(TrackingQuery query);
  Future<Either<RewildError, List<TrackingQuery>>> getAllQueries(int nmId);
  Future<Either<RewildError, void>> deleteAllQueryForNmId(int nmId);
}

// tracking data provider
abstract class TrackingServiceTrackingDataProvider {
  Future<Either<RewildError, void>> addTrackingResult(
      TrackingResult trackingResult);
  Future<Either<RewildError, List<TrackingResult>>> getAllTrackingResults();
  Future<Either<RewildError, List<TrackingQuery>>>
      getKeywordsWithoutTodayEntries(List<TrackingQuery> queries);
}

class TrackingService
    implements
        // KeywordsTrackingTrackingService,
        SeoToolKwResearchTrackingService {
  final TrackingServiceTrackingDataProvider trackingDataProvider;
  final TrackingServiceQueryDataProvider queryDataProvider;
  final TrackingServiceSubscriptionDataProvider subscriptionsDataProvider;
  final TrackingServiceGeoSearchApiClient geoSearchApiClient;
  const TrackingService(
      {required this.trackingDataProvider,
      required this.subscriptionsDataProvider,
      required this.geoSearchApiClient,
      required this.queryDataProvider});

  @override
  Future<Either<RewildError, void>> deleteAllQueryForNmId(int nmId) async {
    return await queryDataProvider.deleteAllQueryForNmId(nmId);
  }

  Future<Either<RewildError, List<TrackingQuery>>> getAllQueries(
      int nmId) async {
    return await queryDataProvider.getAllQueries(nmId);
  }

  @override
  Future<Either<RewildError, void>> addAllForNmId(
      {required int nmId,
      required List<String> queries,
      String? geoNum}) async {
    // insert query to local  db
    for (final query in queries) {
      final addQueryRes = await queryDataProvider.addQuery(TrackingQuery(
        nmId: nmId,
        query: query,
        geo: geoNum ?? '',
      ));
      if (addQueryRes is Left) {
        return left(
            addQueryRes.fold((l) => l, (r) => throw UnimplementedError()));
      }
      // Get all cards nmids
      // final allCardsNmIdsEither =
      //     await subscriptionsDataProvider.getActiveSubscriptions();
      // if (allCardsNmIdsEither is Left) {
      //   return left(allCardsNmIdsEither.fold(
      //       (l) => l, (r) => throw UnimplementedError()));
      // }

      // final allCardsNmIds = allCardsNmIdsEither.fold(
      //     (l) => <int>[], (r) => r.map((e) => e.cardId).toList());
      // if (allCardsNmIds.isEmpty) {
      //   return left(RewildError('У Вас нет активных карточек',
      //       source: runtimeType.toString(),
      //       error: 'У Вас нет активных карточек',
      //       name: 'addNewTrackingQuery',
      //       sendToTg: true));
      // }

      final fetchedPositions = geoNum == null
          ? await geoSearchApiClient
              .getProductsNmIdIndexMapIn(query: query, nmIds: [nmId])
          : await geoSearchApiClient.getProductsNmIdIndexMapWithGeo(
              gNum: geoNum, query: query, nmIds: [nmId]);

      Map<int, GeoSearchModel> positions = {};

      // some queries are wrong
      if (fetchedPositions is Right) {
        positions =
            fetchedPositions.fold((l) => <int, GeoSearchModel>{}, (r) => r);
      }

      final trackingResults = positions
          .map((key, value) => MapEntry(
              key,
              TrackingResult(
                productId: key,
                keyword: query,
                geo: geoNum ?? '',
                position: value.position,
                date: DateTime.now(),
              )))
          .values
          .toList();

      for (var trackingResult in trackingResults) {
        final addTrackingResultRes =
            await trackingDataProvider.addTrackingResult(trackingResult);
        if (addTrackingResultRes is Left) {
          return left(addTrackingResultRes.fold(
              (l) => l, (r) => throw UnimplementedError()));
        }
      }
    }
    return right(null);
  }

  // Future<Either<RewildError, List<TrackingResult>>> getAllTrackingResults(
  //     int nmId) async {
  //   // get all cards nmIds
  //   final nmIdsEither =
  //       await subscriptionsDataProvider.getActiveSubscriptions();
  //   if (nmIdsEither is Left) {
  //     return left(
  //         nmIdsEither.fold((l) => l, (r) => throw UnimplementedError()));
  //   }
  //   final nmIds = nmIdsEither
  //       .fold((l) => <int>[], (r) => r.map((e) => e.cardId))
  //       .toList();

  //   // get all saved queries
  //   final trackingQueriesEither = await queryDataProvider.getAllQueries(nmId);
  //   if (trackingQueriesEither is Left) {
  //     return left(trackingQueriesEither.fold(
  //         (l) => l, (r) => throw UnimplementedError()));
  //   }

  //   final allTrackingQueries =
  //       trackingQueriesEither.fold((l) => <TrackingQuery>[], (r) => r);

  //   // get all tracking results without today entries
  //   final trackingResultsWithoutTodayEntriesEither = await trackingDataProvider
  //       .getKeywordsWithoutTodayEntries(allTrackingQueries);
  //   if (trackingResultsWithoutTodayEntriesEither is Left) {
  //     return left(trackingResultsWithoutTodayEntriesEither.fold(
  //         (l) => l, (r) => throw UnimplementedError()));
  //   }
  //   final trackingResultsWithoutTodayEntries =
  //       trackingResultsWithoutTodayEntriesEither.fold(
  //           (l) => throw UnimplementedError(), (r) => r);

  //   // fetch and save tracking results for each query without today entries
  //   final res = await _fetchAndSaveTrackingResults(
  //       trackingResultsWithoutTodayEntries, nmIds);

  //   if (res is Left) {
  //     return left(res.fold((l) => l, (r) => throw UnimplementedError()));
  //   }

  //   // get all tracking results from local db
  //   final allTrackingResults =
  //       await trackingDataProvider.getAllTrackingResults();
  //   if (allTrackingResults is Left) {
  //     return left(
  //         allTrackingResults.fold((l) => l, (r) => throw UnimplementedError()));
  //   }
  //   return right(
  //       allTrackingResults.fold((l) => throw UnimplementedError(), (r) => r));
  // }

  // Future<Either<RewildError, void>> _fetchAndSaveTrackingResults(
  //     List<TrackingQuery> trackingResultsWithoutTodayEntries,
  //     List<int> nmIds) async {
  //   for (final trackingQuery in trackingResultsWithoutTodayEntries) {
  //     // fetch tracking results
  //     for (final i in [1, 2]) {
  //       Either<RewildError, Map<int, GeoSearchModel>> trackingResultsEither;
  //       if (trackingQuery.geo.isNotEmpty) {
  //         // with geo

  //         trackingResultsEither =
  //             await geoSearchApiClient.getProductsNmIdIndexMapWithGeo(
  //                 gNum: trackingQuery.geo,
  //                 query: trackingQuery.query,
  //                 secondPage: i == 2,
  //                 nmIds: nmIds);
  //       } else {
  //         // without geo
  //         trackingResultsEither =
  //             await geoSearchApiClient.getProductsNmIdIndexMapIn(
  //                 query: trackingQuery.query, nmIds: nmIds, secondPage: i == 2);
  //       }

  //       if (trackingResultsEither is Left) {
  //         continue;
  //         // return right(null);
  //       }

  //       final trackingResult = trackingResultsEither.fold(
  //           (l) => throw UnimplementedError(), (r) => r);

  //       // add tracking results to local db
  //       for (final trackingResult in trackingResult.entries) {
  //         final resEither = await trackingDataProvider.addTrackingResult(
  //             TrackingResult(
  //                 keyword: trackingQuery.query,
  //                 productId: trackingResult.key,
  //                 geo: trackingQuery.geo,
  //                 position: trackingResult.value.position,
  //                 date: DateTime.now()));

  //         if (resEither is Left) {
  //           return left(
  //               resEither.fold((l) => l, (r) => throw UnimplementedError()));
  //         }
  //       }
  //     }
  //   }
  //   return right(null);
  // }
}
