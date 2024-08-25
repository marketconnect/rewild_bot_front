import 'dart:async';

import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
// import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/initial_stock_model.dart';
import 'package:rewild_bot_front/domain/entities/nm_id.dart';
import 'package:rewild_bot_front/domain/entities/seller_model.dart';
import 'package:rewild_bot_front/domain/entities/size_model.dart';
import 'package:rewild_bot_front/domain/entities/stocks_model.dart';
import 'package:rewild_bot_front/domain/entities/supply_model.dart';
import 'package:rewild_bot_front/domain/entities/warehouse.dart';
import 'package:rewild_bot_front/presentation/add_api_keys_screen/add_api_keys_view_model.dart';

import 'package:rewild_bot_front/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/all_cards_seo_screen/all_cards_seo_view_model.dart';
import 'package:rewild_bot_front/presentation/expansion_competitor_keyword_screen/competitor_keyword_expansion_model.dart';
import 'package:rewild_bot_front/presentation/geo_search_screen/geo_search_view_model.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';

import 'package:rewild_bot_front/presentation/payment_screen/payment_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/single_card_screen/single_card_screen_view_model.dart';

// API clients
abstract class CardOfProductServiceSellerApiClient {
  Future<Either<RewildError, SellerModel>> fetchSeller({required int sellerID});
}

// Warehouse
abstract class CardOfProductServiceWarehouseApiCient {
  Future<Either<RewildError, List<Warehouse>>> getAll();
}

// Card
abstract class CardOfProductServiceCardOfProductApiClient {
  Future<Either<RewildError, void>> delete(
      {required String token, required int id});
}

// Data providers
// warehouse
abstract class CardOfProductServiceWarehouseDataProvider {
  Future<Either<RewildError, String?>> get({required int id});
  Future<Either<RewildError, bool>> update(
      {required List<Warehouse> warehouses});
}

// stock
abstract class CardOfProductServiceStockDataProvider {
  Future<Either<RewildError, List<StocksModel>>> getAll();
}

// init stock
abstract class CardOfProductServiceInitStockDataProvider {
  Future<Either<RewildError, List<InitialStockModel>>> getAll();
}

// supply
abstract class CardOfProductServiceSupplyDataProvider {
  Future<Either<RewildError, List<SupplyModel>>> get({required int nmId});
}

// card
abstract class CardOfProductServiceCardOfProductDataProvider {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]);
  Future<Either<RewildError, CardOfProductModel?>> get({required int nmId});
  // Future<Either<RewildError, int>> delete({required int id});
  Future<Either<RewildError, String>> getImage({required int id});
  Future<Either<RewildError, List<CardOfProductModel>>> getAllBySupplierId(
      {required int supplierId});
  Future<Either<RewildError, List<int>>> getAllNmIds();
}

// NmIds Data Provider
abstract class CardOfProductServiceNmIdDataProvider {
  Future<Either<RewildError, List<NmId>>> getNmIds();
}

class CardOfProductService
    implements
        MainNavigationCardService,
        GeoSearchViewModelCardOfProductService,
        AddApiKeysCardOfProductService,
        CompetitorKeywordExpansionCardOfProductService,
        AllCardsSeoScreenCardOfProductService,
        SingleCardScreenCardOfProductService,
        AllCardsScreenCardOfProductService,
        PaymentScreenCardsService {
  final CardOfProductServiceWarehouseDataProvider warehouseDataprovider;
  final CardOfProductServiceStockDataProvider stockDataprovider;
  final CardOfProductServiceWarehouseApiCient warehouseApiClient;
  final CardOfProductServiceCardOfProductApiClient cardOfProductApiClient;
  final CardOfProductServiceCardOfProductDataProvider cardOfProductDataProvider;
  final CardOfProductServiceInitStockDataProvider initStockDataProvider;
  final CardOfProductServiceSupplyDataProvider supplyDataProvider;
  final CardOfProductServiceNmIdDataProvider nmIdDataProvider;
  CardOfProductService({
    required this.warehouseDataprovider,
    required this.warehouseApiClient,
    required this.cardOfProductApiClient,
    required this.cardOfProductDataProvider,
    required this.nmIdDataProvider,
    required this.stockDataprovider,
    required this.initStockDataProvider,
    required this.supplyDataProvider,
  });

  @override
  Future<Either<RewildError, int>> count() async {
    final allCardsEither = await cardOfProductDataProvider.getAll();
    return allCardsEither.fold(
        (l) => left(l), (allCards) => right(allCards.length));
  }

  @override
  Future<Either<RewildError, List<NmId>>> getAllUserNmIds() async {
    return nmIdDataProvider.getNmIds();
  }

  @override
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]) async {
    List<CardOfProductModel> resultCards = [];
    // Cards
    final allCardsEither = await cardOfProductDataProvider.getAll(nmIds);

    if (allCardsEither.isLeft()) {
      return allCardsEither;
    }

    final allCards =
        allCardsEither.fold((l) => <CardOfProductModel>[], (r) => r);

    // get stocks
    final stocksEither = await stockDataprovider.getAll();

    if (stocksEither.isLeft()) {
      return left(RewildError(
        "Failed to get stocks",
        sendToTg: true,
        source: "CardOfProductService",
        name: "getAll",
        args: [],
      ));
    }

    final stocks = stocksEither.fold((l) => <StocksModel>[], (r) => r);

    // get init stocks
    final initStocksEither = await initStockDataProvider.getAll(
        // dateFrom: dateFrom,
        // dateTo: dateTo,
        );

    if (initStocksEither.isLeft()) {
      return left(RewildError(
        "Failed to get init stocks",
        sendToTg: true,
        source: "CardOfProductService",
        name: "getAll",
        args: [],
      ));
    }

    final initialStocks =
        initStocksEither.fold((l) => <InitialStockModel>[], (r) => r);
    // final dateFrom = yesterdayEndOfTheDay();
    // final dateTo = DateTime.now();
    // append stocks and init stocks to cards

    for (final card in allCards) {
      // append stocks
      final cardStocks =
          stocks.where((stock) => stock.nmId == card.nmId).toList();

      final sizes = [SizeModel(stocks: cardStocks)];
      final cardWithStocks = card.copyWith(sizes: sizes);

      // append init stocks
      final initStocks = initialStocks
          .where((initStock) => initStock.nmId == card.nmId)
          .toList();

      final newCard = cardWithStocks.copyWith(initialStocks: initStocks);

      // append supplies
      final suppliesResource = await supplyDataProvider.get(nmId: newCard.nmId);
      if (suppliesResource.isLeft()) {
        return left(RewildError(
          "Failed to get supplies",
          sendToTg: true,
          source: "CardOfProductService",
          name: "getAll",
          args: [],
        ));
      }
      final supplies = suppliesResource.fold((l) => <SupplyModel>[], (r) => r);

      newCard.setSupplies(supplies);
      resultCards.add(newCard);
    }

    return right(resultCards);
  }

  @override
  Future<Either<RewildError, CardOfProductModel?>> getOne(int nmId) async {
    return await cardOfProductDataProvider.get(nmId: nmId);
  }

  @override
  Future<Either<RewildError, List<CardOfProductModel>>>
      getNotUserCards() async {
    // get user nmIds
    final userNmIdsEither = await nmIdDataProvider.getNmIds();
    if (userNmIdsEither.isLeft()) {
      return left(RewildError("Could not get user nmIds",
          name: 'getNotUserCards', sendToTg: false));
    }
    final userNmIds = userNmIdsEither.fold((l) => <NmId>[], (r) => r);
    final userCardOfProductsIds = userNmIds.map((nmId) => nmId.nmId).toList();

    // get all nmIds
    final allNmIdsEither = await cardOfProductDataProvider.getAllNmIds();
    if (allNmIdsEither.isLeft()) {
      return left(RewildError("Could not get all nmIds",
          name: 'getNotUserCards', sendToTg: false));
    }
    final allNmIds = allNmIdsEither.fold((l) => <int>[], (r) => r);
    // get nmIds that are not user cards
    final notUserNmIds = allNmIds
        .where((nmId) => !userCardOfProductsIds.contains(nmId))
        .toList();

    // get cards
    return await cardOfProductDataProvider.getAll(notUserNmIds);
  }

  @override
  Future<Either<RewildError, String>> getImageForNmId(
      {required int nmId}) async {
    return await cardOfProductDataProvider.getImage(id: nmId);
  }

  @override
  Future<Either<RewildError, List<int>>> getAllNmIds() async {
    final nmIdsEither = await cardOfProductDataProvider.getAllNmIds();

    return nmIdsEither;
  }
}
