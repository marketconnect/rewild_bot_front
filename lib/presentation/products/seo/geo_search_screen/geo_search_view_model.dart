import 'package:fpdart/fpdart.dart';

import 'package:flutter/material.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/geo_search_model.dart';
import 'package:rewild_bot_front/domain/entities/wb_search_log.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// Geo search
abstract class GeoSearchViewModelGeoSearchService {
  Future<
          Either<RewildError,
              (Map<int, Map<String, GeoSearchModel>>, List<WbSearchLog>)>>
      getProductsNmIdsGeoIndex(
          List<String> gNums, String query, List<int> nmIds);
}

// Card of product
abstract class GeoSearchViewModelCardOfProductService {
  Future<Either<RewildError, String>> getImageForNmId({required int nmId});
  Future<Either<RewildError, List<int>>> getAllNmIds();
}

class GeoSearchViewModel extends ResourceChangeNotifier {
  final GeoSearchViewModelGeoSearchService geoSearchService;
  final GeoSearchViewModelCardOfProductService cardOfProductService;

  GeoSearchViewModel({
    required this.geoSearchService,
    required super.context,
    required this.cardOfProductService,
  });

  // Method now takes List<String> gNums
  Future<void> searchProducts(List<String> gNums, String query) async {
    resetPositionCpm();
    _isLoading = true;
    notify();
    // NmIds
    final nmIdsEither = await cardOfProductService.getAllNmIds();
    if (nmIdsEither.isLeft()) {
      return;
    }
    final nmIds = nmIdsEither.fold((l) => throw UnimplementedError(), (r) => r);
    // Search results
    final productsEither =
        await geoSearchService.getProductsNmIdsGeoIndex(gNums, query, nmIds);
    if (productsEither.isRight()) {
      final productsAndAdvertsByGeo =
          productsEither.fold((l) => throw UnimplementedError(), (r) => r);

      _productsByGeo = productsAndAdvertsByGeo.$1;
      setPositionCpm(productsAndAdvertsByGeo.$2);
      notify();
    }

    _isLoading = false;
    setSearchPerformed(true);
    notify();
    await _loadImages();
  }

  Future<void> _loadImages() async {
    // get all unique nmIds from _productsByGeo and _searchAdvData
    final nmIds = [
      ..._productsByGeo.keys,
      // ..._searchAdvData.map((e) => e.id),
    ];
    final uniqueNmIds = nmIds.toSet();
    // Iterate through all nmIds
    for (var nmId in uniqueNmIds) {
      final imageEither =
          await cardOfProductService.getImageForNmId(nmId: nmId);
      imageEither.match(
        (l) => {/* handle error */},
        (imageUrl) {
          _images[nmId] = imageUrl;
          notify();
        },
      );
    }
  }

  // loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // to display different empty search results screens
  bool _searchPerformed = false;
  bool get searchPerformed => _searchPerformed;
  void setSearchPerformed(bool searchPerformed) {
    _searchPerformed = searchPerformed;
  }

  // products
  Map<int, Map<String, GeoSearchModel>> get productsByGeo => _productsByGeo;
  Map<int, Map<String, GeoSearchModel>> _productsByGeo = {};

  // images
  Map<int, String> _images = {};
  void setImages(Map<int, String> images) {
    _images = images;
  }

  String imageForProduct(int nmId) => _images[nmId] ?? '';

  // auto adverts positions and cpms
  List<WbSearchLog> _adverts = [];
  List<WbSearchLog> get adverts => _adverts;
  void setPositionCpm(List<WbSearchLog> advertsForSet) {
    advertsForSet.sort((a, b) => b.cpm.compareTo(a.cpm));
    _adverts = advertsForSet.where((element) => element.cpm > 0).toList();
  }

  void resetPositionCpm() {
    _adverts = [];
  }

  void onCardTap(int nmId) {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.singleCardScreen,
      arguments: nmId,
    );
  }
}
