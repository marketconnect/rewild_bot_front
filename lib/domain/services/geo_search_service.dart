import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/geo_search_model.dart';
import 'package:rewild_bot_front/domain/entities/wb_search_log.dart';
import 'package:rewild_bot_front/presentation/geo_search_screen/geo_search_view_model.dart';

// Api client
abstract class GeoSearchServiceGeoSearchApiClient {
  Future<Either<RewildError, (Map<int, GeoSearchModel>, List<WbSearchLog>)>>
      getProductsNmIdIndexMapWithGeoAndAdv(
          {required String gNum,
          required String query,
          required List<int> nmIds});
}

class GeoSearchService implements GeoSearchViewModelGeoSearchService {
  final GeoSearchServiceGeoSearchApiClient geoSearchApiClient;
  // final GeoSearchServiceCardOfProductDataProvider cardsDataProvider;
  GeoSearchService({
    required this.geoSearchApiClient,
  });

  @override
  Future<
          Either<RewildError,
              (Map<int, Map<String, GeoSearchModel>>, List<WbSearchLog>)>>
      getProductsNmIdsGeoIndex(
          List<String> gNums, String query, List<int> nmIds) async {
    Map<int, Map<String, GeoSearchModel>> nmIdGeoIndex = {};
    // Save an auto adverts position-cpm
    List<WbSearchLog> geoPromoPosPosCpm = [];
    for (var gNum in gNums) {
      // go through all gNums
      // fetch geo positions
      var nmIdIndexEither =
          await geoSearchApiClient.getProductsNmIdIndexMapWithGeoAndAdv(
              gNum: gNum, query: query, nmIds: nmIds);
      if (nmIdIndexEither.isRight()) {
        final nmIdsIndexesAndAdvs =
            nmIdIndexEither.fold((l) => throw UnimplementedError(), (r) => r);
        final nmIdsIndexes = nmIdsIndexesAndAdvs.$1;
        for (var nmId in nmIdsIndexes.keys) {
          if (!nmIdGeoIndex.containsKey(nmId)) {
            nmIdGeoIndex[nmId] = {};
          }
          nmIdGeoIndex[nmId]![gNum] = nmIdsIndexes[nmId]!;
        }

        geoPromoPosPosCpm.addAll(nmIdsIndexesAndAdvs.$2);
      }
    }
    return Right((nmIdGeoIndex, geoPromoPosPosCpm));
  }
}
