import 'dart:async';

import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/constants/settings.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';

import 'package:rewild_bot_front/domain/entities/initial_stock_model.dart';
import 'package:rewild_bot_front/domain/entities/prices.dart';
import 'package:rewild_bot_front/domain/entities/size_model.dart';

import 'package:rewild_bot_front/domain/entities/stocks_model.dart';
import 'package:rewild_bot_front/domain/entities/supply_model.dart';
import 'package:rewild_bot_front/domain/entities/tariff_model.dart';
import 'package:rewild_bot_front/presentation/home/add_api_keys_screen/add_api_keys_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/all_cards_seo_screen/all_cards_seo_view_model.dart';

import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';

import 'package:rewild_bot_front/presentation/products/cards/wb_web_view/wb_web_view_screen_view_model.dart';

// Tariffs Api
abstract class UpdateServiceTariffApiClient {
  Future<Either<RewildError, List<TariffModel>>> getTarrifs(
      {required String token});
}

// Tariffs data provider
abstract class UpdateServiceTariffDataProvider {
  Future<Either<RewildError, void>> insertAll(List<TariffModel> tariffs);
}

// Details
abstract class UpdateServiceDetailsApiClient {
  Future<Either<RewildError, List<CardOfProductModel>>> get(
      {required List<int> ids});
}

// Supply
abstract class UpdateServiceSupplyDataProvider {
  Future<Either<RewildError, void>> deleteAll();
  Future<Either<RewildError, int>> insert({required SupplyModel supply});
  Future<Either<RewildError, void>> delete({
    required int nmId,
    int? wh,
    int? sizeOptionId,
  });
  Future<Either<RewildError, SupplyModel?>> getOne({
    required int nmId,
    required int wh,
    required int sizeOptionId,
  });
}

// Card of product data provider
abstract class UpdateServiceCardOfProductDataProvider {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll();
  Future<Either<RewildError, int>> insertOrUpdate(
      {required CardOfProductModel card});
  Future<Either<RewildError, int>> delete({required int id});
}

// Card of product api client
abstract class UpdateServiceCardOfProductApiClient {
  // Future<Either<RewildError, void>> save(
  //     {required String token, required List<CardOfProductModel> productCards});
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      {required String token});
  // Future<Either<RewildError, void>> delete(
  //     {required String token, required int id});
}

// initial stock api client
abstract class UpdateServiceInitialStockModelApiClient {
  Future<Either<RewildError, List<InitialStockModel>>> get(
      {required String token,
      required List<int> skus,
      required DateTime dateFrom,
      required DateTime dateTo});
}

// init stock data provider
abstract class UpdateServiceInitStockDataProvider {
  Future<Either<RewildError, int>> insert(
      {required InitialStockModel initialStockModel});
  Future<Either<RewildError, List<InitialStockModel>>> get(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo});
  Future<Either<RewildError, InitialStockModel?>> getOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo,
      required int wh,
      required int sizeOptionId});

  Future<Either<RewildError, void>> deleteAll();
}

// stock data provider
abstract class UpdateServiceStockDataProvider {
  Future<Either<RewildError, int>> insert({required StocksModel stock});
  Future<Either<RewildError, List<StocksModel>>> get({required int nmId});
  Future<Either<RewildError, StocksModel>> getOne(
      {required int nmId, required int wh, required int sizeOptionId});
  Future<Either<RewildError, void>> delete(int nmId);
}

// average logistics api client
abstract class UpdateServiceAverageLogisticsApiClient {
  Future<Either<RewildError, Prices>> getCurrentPrice({required String token});
}

// average logistics data provider
abstract class UpdateServiceAverageLogisticsDataProvider {
  Future<Either<RewildError, void>> update(int price);
}

// last update day data provider
abstract class UpdateServiceLastUpdateDayDataProvider {
  Future<Either<RewildError, void>> update();
  Future<Either<RewildError, bool>> todayUpdated();
}

// notification data provider
abstract class UpdateServiceNotificationDataProvider {
  Future<Either<RewildError, int>> deleteAll({required int parentId});
}

//  tracking result
abstract class UpdateServiceTrackingResultDataProvider {
  Future<Either<RewildError, void>> deleteOldTrackingResults();
}

// total cost
abstract class UpdateServiceTotalCostdataProvider {
  Future<Either<RewildError, void>> deleteAll(int nmId);
}

abstract class UpdateServiceWeekOrdersDataProvider {
  Future<Either<RewildError, void>> deleteOldOrders();
}

abstract class UpdateServiceCardKeywordsDataProvider {
  Future<Either<RewildError, void>> deleteKeywordsOlderThanOneDay();
}

// Cached lemmas
abstract class UpdateServiceLemmaDataProvider {
  Future<Either<RewildError, void>> deleteAll();
}

// Cached keywords by lemma
abstract class UpdateServiceKwByLemmaDataProvider {
  Future<Either<RewildError, void>> deleteAll();
}

// Cached keywords by lemma
abstract class UpdateServiceKwByLemmaByWordDataProvider {
  Future<Either<RewildError, void>> deleteAll();
}

// Cached keywords by Autocomplite
abstract class UpdateServiceKwByAutocompliteDataProvider {
  Future<Either<RewildError, void>> deleteAll();
}

class UpdateService
    implements
        AllCardsScreenUpdateService,
        WbWebViewScreenViewModelUpdateService,
        // PaymentWebViewUpdateService,
        AllCardsSeoUpdateService,
        AddApiKeysUpdateService,
        MainNavigationUpdateService {
  final UpdateServiceDetailsApiClient detailsApiClient;
  final UpdateServiceSupplyDataProvider supplyDataProvider;
  final UpdateServiceCardOfProductDataProvider cardOfProductDataProvider;
  final UpdateServiceCardOfProductApiClient cardOfProductApiClient;
  final UpdateServiceInitialStockModelApiClient initialStockModelApiClient;
  final UpdateServiceInitStockDataProvider initialStockModelDataProvider;
  final UpdateServiceStockDataProvider stockDataProvider;
  final UpdateServiceLastUpdateDayDataProvider lastUpdateDayDataProvider;
  final UpdateServiceNotificationDataProvider notificationDataProvider;

  // final StreamController<int> cardsNumberStreamController;
  final UpdateServiceWeekOrdersDataProvider weekOrdersDataProvider;
  final UpdateServiceTrackingResultDataProvider trackingResultDataProvider;
  final UpdateServiceTariffApiClient tariffApiClient;
  final UpdateServiceTariffDataProvider tariffDataProvider;
  final UpdateServiceTotalCostdataProvider totalCostdataProvider;
  final UpdateServiceAverageLogisticsApiClient averageLogisticsApiClient;
  final UpdateServiceAverageLogisticsDataProvider averageLogisticsDataProvider;
  final UpdateServiceCardKeywordsDataProvider cardKeywordsDataProvider;
  final UpdateServiceLemmaDataProvider lemmaDataProvider;
  final UpdateServiceKwByLemmaDataProvider cachedKwByLemmaDataProvider;
  final UpdateServiceKwByLemmaByWordDataProvider
      cachedKwByLemmaByWordDataProvider;
  final UpdateServiceKwByAutocompliteDataProvider
      cachedKwByAutocompliteDataProvider;
  UpdateService(
      {required this.stockDataProvider,
      required this.detailsApiClient,
      required this.weekOrdersDataProvider,
      required this.initialStockModelDataProvider,
      required this.tariffApiClient,
      required this.averageLogisticsApiClient,
      required this.totalCostdataProvider,
      required this.lemmaDataProvider,
      required this.cachedKwByLemmaDataProvider,
      required this.tariffDataProvider,
      required this.averageLogisticsDataProvider,
      required this.cardOfProductDataProvider,
      required this.notificationDataProvider,
      required this.initialStockModelApiClient,
      required this.trackingResultDataProvider,
      required this.supplyDataProvider,
      required this.lastUpdateDayDataProvider,
      required this.cardKeywordsDataProvider,
      required this.cachedKwByLemmaByWordDataProvider,
      required this.cachedKwByAutocompliteDataProvider,
      required this.cardOfProductApiClient});

  // used to avoid updating uses cards twice in one session
  bool _wasUserCardsUpdatedInTheSession = false;

  bool get wasUserCardsUpdatedInTheSession => _wasUserCardsUpdatedInTheSession;

  // Time to update? used to avoid updating too often
  DateTime? updatedAt;
  void setUpdatedAt() {
    updatedAt = DateTime.now();
  }

  bool timeToUpdated() => updatedAt == null
      ? true
      : DateTime.now().difference(updatedAt!) > SettingsConstants.updatePeriod;

  @override
  Future<Either<RewildError, void>> fetchAllUserCardsFromServer(
      String token) async {
    final cardsFromServerEither =
        await cardOfProductApiClient.getAll(token: token);
    if (cardsFromServerEither.isLeft()) {
      return left(cardsFromServerEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }

    final cards = cardsFromServerEither.getOrElse((l) => []);
    // there are cards on server - save
    if (cards.isNotEmpty) {
      final insertOrUpdateEither =
          await insert(token: token, cardOfProductsToInsert: cards);
      if (insertOrUpdateEither.isLeft()) {
        return left(insertOrUpdateEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
    }
    _wasUserCardsUpdatedInTheSession = true;
    return right(null);
  }

  // returns quantity of inserted cards ========================================================================
  @override
  Future<Either<RewildError, int>> insert(
      {required String token,
      required List<CardOfProductModel> cardOfProductsToInsert}) async {
    // get all cards from local db

    final cardsInDBEither = await cardOfProductDataProvider.getAll();

    if (cardsInDBEither.isLeft()) {
      return left(
          cardsInDBEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final cardsInDB = cardsInDBEither.fold(
      (l) => throw UnimplementedError(),
      (r) => r,
    );
    final cardsInDBIds = cardsInDB.map((e) => e.nmId).toList();

    List<CardOfProductModel> newCards = [];
    for (final c in cardOfProductsToInsert) {
      if (cardsInDBIds.contains(c.nmId)) {
        continue;
      }
      newCards.add(c);
    }

    // if there are no new cards - return 0

    if (newCards.isEmpty) {
      return right(0);
    }

    List<InitialStockModel> initStocksFromServer = [];

    // ids of cards that initial stocks do not exist on server yet
    List<int> abscentOnServerNewCardsIds = newCards.map((e) => e.nmId).toList();

    // initial stocks from server

    final initialStockModelsEither = await initialStockModelApiClient.get(
      token: token,
      skus: newCards.map((e) => e.nmId).toList(),
      dateFrom: yesterdayEndOfTheDay(),
      dateTo: DateTime.now(),
    );

    initStocksFromServer = initialStockModelsEither.getOrElse((l) => []);

    // save fetched from server initial stocks to local db
    for (final stock in initStocksFromServer) {
      final insertStockEither =
          await initialStockModelDataProvider.insert(initialStockModel: stock);

      if (insertStockEither.isLeft()) {
        return left(insertStockEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      // remove nmId that initial stock exists on server and in local db
      abscentOnServerNewCardsIds.remove(stock.nmId);
    }

    // fetch details for all new cards from wb

    final fetchedCardsOfProductsEither =
        await detailsApiClient.get(ids: newCards.map((e) => e.nmId).toList());
    if (fetchedCardsOfProductsEither.isLeft()) {
      return left(fetchedCardsOfProductsEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }
    final fetchedCardsOfProducts =
        fetchedCardsOfProductsEither.getOrElse((l) => []);

    // add to db cards
    for (final card in fetchedCardsOfProducts) {
      // append img
      final img = newCards.firstWhere((e) => e.nmId == card.nmId).img;
      card.img = img;
      // insert

      final insertEither =
          await cardOfProductDataProvider.insertOrUpdate(card: card);
      if (insertEither.isLeft()) {
        return left(
            insertEither.fold((l) => l, (r) => throw UnimplementedError()));
      }

      // add stocks
      for (final size in card.sizes) {
        for (final stock in size.stocks) {
          final insertStockEither =
              await stockDataProvider.insert(stock: stock);
          if (insertStockEither.isLeft()) {
            return left(insertStockEither.fold(
                (l) => l, (r) => throw UnimplementedError()));
          }

          // if the miracle does not happen
          // and initial stocks do not exist on server yet
          if (abscentOnServerNewCardsIds.contains(stock.nmId)) {
            final insertInitialStockModelEither =
                await initialStockModelDataProvider.insert(
                    initialStockModel: InitialStockModel(
              nmId: stock.nmId,
              sizeOptionId: stock.sizeOptionId,
              date: DateTime.now(),
              wh: stock.wh,
              qty: stock.qty,
            ));
            if (insertInitialStockModelEither.isLeft()) {
              return left(insertInitialStockModelEither.fold(
                  (l) => l, (r) => throw UnimplementedError()));
            }
          }
        }
      }
    }

    return right(newCards.length);
  }

  // @override
  // Future<Either<RewildError, void>> putOnServerNewCards(
  //     {required String token,
  //     required List<CardOfProductModel> cardOfProductsToPutOnServer}) async {
  //   // get rid of duplicates
  //   final uniqueNewCards = cardOfProductsToPutOnServer.toSet().toList();
  //   final saveOnServerEither = await cardOfProductApiClient.save(
  //       token: token, productCards: uniqueNewCards);

  //   if (saveOnServerEither.isLeft()) {
  //     return left(
  //         saveOnServerEither.fold((l) => l, (r) => throw UnimplementedError()));
  //   }
  //   return right(null);
  // }

  // update cards ==============================================================
  @override
  Future<Either<RewildError, void>> update(String token) async {
    // if earlier than update period - do nothing
    if (!timeToUpdated()) {
      return right(null);
    }

    // get cards from the local storage
    final cardsOfProductsEither = await cardOfProductDataProvider.getAll();
    if (cardsOfProductsEither is Left) {
      return left(cardsOfProductsEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }

    final allSavedCardsOfProducts =
        cardsOfProductsEither.fold((l) => throw UnimplementedError(), (r) => r);

    // if there are no cards - do nothing
    if (allSavedCardsOfProducts.isEmpty) {
      return right(null);
    }

    // if it is Today`s first time update - update initial stocks
    // were today updated?
    final isUpdatedEither = await lastUpdateDayDataProvider.todayUpdated();
    if (isUpdatedEither.isLeft()) {
      return left(
          isUpdatedEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    // final isUpdated =
    //     isUpdatedEither.fold((l) => throw UnimplementedError(), (r) => r);

    // TODO: Delete me
    bool isUpdated = false;

    // were not updated - update
    // Update initial stocks!
    if (!isUpdated) {
      // Delete keywords by autocomplite

      final deleteKeywordsByAutocompliteEither =
          await cachedKwByAutocompliteDataProvider.deleteAll();
      if (deleteKeywordsByAutocompliteEither.isLeft()) {
        return left(deleteKeywordsByAutocompliteEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      // Delete keywords by word
      final deleteKeywordsByWordEither =
          await cachedKwByLemmaByWordDataProvider.deleteAll();
      if (deleteKeywordsByWordEither.isLeft()) {
        return left(deleteKeywordsByWordEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      // Delete keywords by lemmas
      final deleteKeywordsEither =
          await cachedKwByLemmaDataProvider.deleteAll();
      if (deleteKeywordsEither.isLeft()) {
        return left(deleteKeywordsEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      // Delete lemmas

      final deleteLemmasEither = await lemmaDataProvider.deleteAll();
      if (deleteLemmasEither.isLeft()) {
        return left(deleteLemmasEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      final deleteOldOrdersEither =
          await weekOrdersDataProvider.deleteOldOrders();
      if (deleteOldOrdersEither.isLeft()) {
        return left(deleteOldOrdersEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      final deleteCardKeywordsEither =
          await cardKeywordsDataProvider.deleteKeywordsOlderThanOneDay();
      if (deleteCardKeywordsEither.isLeft()) {
        return left(deleteCardKeywordsEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      // update old orders
      // update averageLogistic
      final pricesEither =
          await averageLogisticsApiClient.getCurrentPrice(token: token);
      if (pricesEither.isRight()) {
        final prices =
            pricesEither.fold((l) => throw UnimplementedError(), (r) => r);
        await averageLogisticsDataProvider.update(prices.averageLogistics);
      }

      // since there is today first time update - delete supplies and initial stocks
      final deleteSuppliesEither = await supplyDataProvider.deleteAll();
      if (deleteSuppliesEither.isLeft()) {
        return left(deleteSuppliesEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      final deleteInitialStockModelsEither =
          await initialStockModelDataProvider.deleteAll();
      if (deleteInitialStockModelsEither.isLeft()) {
        return left(deleteInitialStockModelsEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      // delete old tracking results since it stores only last 30 days
      await trackingResultDataProvider.deleteOldTrackingResults();

      // update tariffs
      final fetchedTariffsEither =
          await tariffApiClient.getTarrifs(token: token);
      if (fetchedTariffsEither.isLeft()) {
        return left(fetchedTariffsEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      final fetchedTariffs = fetchedTariffsEither.fold(
          (l) => throw UnimplementedError(), (r) => r);

      final updateTariffsEither =
          await tariffDataProvider.insertAll(fetchedTariffs);
      if (updateTariffsEither.isLeft()) {
        return left(updateTariffsEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      // try to fetch today`s initial stocks from server
      final todayInitialStockModelsFromServerEither =
          await _fetchTodayInitialStockModelsFromServer(
              token, allSavedCardsOfProducts.map((e) => e.nmId).toList());
      if (todayInitialStockModelsFromServerEither is Left) {
        return left(todayInitialStockModelsFromServerEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      final todayInitialStockModelsFromServer =
          todayInitialStockModelsFromServerEither.fold(
              (l) => throw UnimplementedError(), (r) => r);

      // save today`s initial stocks to local db
      for (final stock in todayInitialStockModelsFromServer) {
        final insertInitialStockModelEither =
            await initialStockModelDataProvider.insert(
                initialStockModel: InitialStockModel(
          nmId: stock.nmId,
          sizeOptionId: stock.sizeOptionId,
          date: DateTime.now(),
          wh: stock.wh,
          qty: stock.qty,
        ));

        if (insertInitialStockModelEither is Left) {
          return left(insertInitialStockModelEither.fold(
              (l) => l, (r) => throw UnimplementedError()));
        }
      }

      // set that today was updated already
      await lastUpdateDayDataProvider.update();
    } // day first time update

    // regular part of update
    // fetch details for all saved cards from WB

    final fetchedCardsOfProductsEither = await detailsApiClient.get(
        ids: allSavedCardsOfProducts.map((e) => e.nmId).toList());

    if (fetchedCardsOfProductsEither is Left) {
      return left(fetchedCardsOfProductsEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }

    final fetchedCardsOfProducts = fetchedCardsOfProductsEither.fold(
        (l) => throw UnimplementedError(), (r) => r);

    // ADD OTHER INFORMATION FOR EVERY FETCHED CARD
    for (final card in fetchedCardsOfProducts) {
      // add the card to db
      final insertEither =
          await cardOfProductDataProvider.insertOrUpdate(card: card);

      if (insertEither is Left) {
        return left(
            insertEither.fold((l) => l, (r) => throw UnimplementedError()));
      }

      // get stocks for the card before deleting since if there are supplies
      // they will be used for last stock calculation
      final stocksEither = await stockDataProvider.get(nmId: card.nmId);
      List<StocksModel> stocks = [];
      if (stocksEither.isRight()) {
        stocks = stocksEither.fold((l) => throw UnimplementedError(), (r) => r);
      }

      // delete stocks

      final deleteEither = await stockDataProvider.delete(card.nmId);
      if (deleteEither.isLeft()) {
        return left(
            deleteEither.fold((l) => l, (r) => throw UnimplementedError()));
      }

      // add stocks
      final addStocksEither = await _addStocks(card.sizes, stocks);
      if (addStocksEither.isLeft()) {
        return left(
            addStocksEither.fold((l) => l, (r) => throw UnimplementedError()));
      }
    }
    setUpdatedAt();

    return right(null);
  }

  Future<Either<RewildError, void>> _addStocks(
      List<SizeModel> sizes, List<StocksModel> stocks) async {
    final dateFrom = yesterdayEndOfTheDay();
    final dateTo = DateTime.now();

    // for each size
    for (final size in sizes) {
      // for each stock
      for (final stock in size.stocks) {
        // get saved init stock
        final initStockEither = await initialStockModelDataProvider.getOne(
            nmId: stock.nmId,
            dateFrom: dateFrom,
            dateTo: dateTo,
            wh: stock.wh,
            sizeOptionId: stock.sizeOptionId);
        if (initStockEither.isLeft()) {
          return left(initStockEither.fold(
              (l) => l, (r) => throw UnimplementedError()));
        }
        final initStock = initStockEither.getOrElse((l) => null);

        // if init stock does not exists
        if (initStock == null) {
          // insert init stock
          final insertInitStockEither =
              await initialStockModelDataProvider.insert(
                  initialStockModel: InitialStockModel(
                      date: dateFrom,
                      nmId: stock.nmId,
                      wh: stock.wh,
                      sizeOptionId: stock.sizeOptionId,
                      qty: 0));
          if (insertInitStockEither.isLeft()) {
            return left(insertInitStockEither.fold(
                (l) => l, (r) => throw UnimplementedError()));
          }

          // if init stock does not exist and stocks more than threshold insert supply
          if (stock.qty > SettingsConstants.supplyThreshold) {
            // insert supply
            final insertSupplyEither = await supplyDataProvider.insert(
                supply: SupplyModel(
                    wh: stock.wh,
                    nmId: stock.nmId,
                    sizeOptionId: stock.sizeOptionId,
                    lastStocks: 0,
                    qty: stock.qty));
            if (insertSupplyEither.isLeft()) {
              return left(insertSupplyEither.fold(
                  (l) => l, (r) => throw UnimplementedError()));
            }
          }
        } else {
          // if init stock exists

          // if stocks difference more than threshold insert supply
          if ((stock.qty - initStock.qty) > SettingsConstants.supplyThreshold) {
            final supplyEither = await supplyDataProvider.getOne(
              nmId: stock.nmId,
              wh: stock.wh,
              sizeOptionId: stock.sizeOptionId,
            );

            if (supplyEither.isLeft()) {
              return left(supplyEither.fold(
                  (l) => l, (r) => throw UnimplementedError()));
            }
            // init stock exists and supply does not exists
            // first time insert supply

            final supply = supplyEither.getOrElse((l) => null);
            if (supply == null) {
              final stockForSup = stocks.where((e) => e.nmId == stock.nmId);
              if (stockForSup.isNotEmpty) {
                final savedStockData = stockForSup.first;

                final insertSupplyEither = await supplyDataProvider.insert(
                    supply: SupplyModel(
                  wh: stock.wh,
                  nmId: stock.nmId,
                  sizeOptionId: stock.sizeOptionId,
                  lastStocks: savedStockData.qty,
                  qty: stock.qty - initStock.qty,
                ));
                if (insertSupplyEither.isLeft()) {
                  return left(insertSupplyEither.fold(
                      (l) => l, (r) => throw UnimplementedError()));
                }
              }
            } else {
              // supply exists
              // check if stocks more than in the supply

              if (stock.qty - initStock.qty > supply.qty) {
                final insertSupplyEither = await supplyDataProvider.insert(
                    supply: SupplyModel(
                  wh: supply.wh,
                  nmId: supply.nmId,
                  sizeOptionId: supply.sizeOptionId,
                  lastStocks: supply.lastStocks,
                  qty: stock.qty - initStock.qty,
                ));
                if (insertSupplyEither.isLeft()) {
                  return left(insertSupplyEither.fold(
                      (l) => l, (r) => throw UnimplementedError()));
                }
              }
            }
          }
        }

        final insertStockEither = await stockDataProvider.insert(stock: stock);
        if (insertStockEither.isLeft()) {
          return left(insertStockEither.fold(
              (l) => l, (r) => throw UnimplementedError()));
        }
      } // for stock
    } // for size
    return right(null);
  }

  Future<Either<RewildError, List<InitialStockModel>>>
      _fetchTodayInitialStockModelsFromServer(
          String token, List<int> cardsWithoutTodayInitStocksIds) async {
    List<InitialStockModel> initialStockModelsFromServer = [];
    if (cardsWithoutTodayInitStocksIds.isNotEmpty) {
      final initialStockModelsEither = await initialStockModelApiClient.get(
        token: token,
        skus: cardsWithoutTodayInitStocksIds,
        dateFrom: yesterdayEndOfTheDay(),
        dateTo: DateTime.now(),
      );
      if (initialStockModelsEither.isLeft()) {
        return left(initialStockModelsEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      initialStockModelsFromServer =
          initialStockModelsEither.getOrElse((l) => throw UnimplementedError());

      // save initial stocks to local db
      for (final stock in initialStockModelsFromServer) {
        final insertStockEither = await initialStockModelDataProvider.insert(
            initialStockModel: stock);

        if (insertStockEither.isLeft()) {
          return left(insertStockEither.fold(
              (l) => l, (r) => throw UnimplementedError()));
        }
      }
    }
    return right(initialStockModelsFromServer);
  }

  // @override
  // Future<Either<RewildError, int>> delete(
  //     {required String token, required List<int> nmIds}) async {
  //   for (final id in nmIds) {
  //     // delete card from the server

  //     final deleteFromServerEither =
  //         await cardOfProductApiClient.delete(token: token, id: id);
  //     if (deleteFromServerEither.isLeft()) {
  //       return left(deleteFromServerEither.fold(
  //           (l) => l, (r) => throw UnimplementedError()));
  //     }

  //     // delete card from the local storage
  //     final deleteEither = await cardOfProductDataProvider.delete(id: id);
  //     if (deleteEither.isLeft()) {
  //       return left(
  //           deleteEither.fold((l) => l, (r) => throw UnimplementedError()));
  //     }

  //     // delete notifications for this card
  //     final deleteNotificationsEither =
  //         await notificationDataProvider.deleteAll(parentId: id);
  //     if (deleteNotificationsEither.isLeft()) {
  //       return left(deleteNotificationsEither.fold(
  //           (l) => l, (r) => throw UnimplementedError()));
  //     }
  //   }
  //   // get all cards from local db

  //   final cardsInDBEither = await cardOfProductDataProvider.getAll();
  //   if (cardsInDBEither.isLeft()) {
  //     return left(
  //         cardsInDBEither.fold((l) => l, (r) => throw UnimplementedError()));
  //   }
  //   // final cardsInDB =
  //   // cardsInDBEither.getOrElse((l) => throw UnimplementedError());
  //   // cardsNumberStreamController.add(cardsInDB.length);
  //   return right(nmIds.length);
  // }

  @override
  Future<Either<RewildError, int>> deleteLocal(
      {required List<int> nmIds}) async {
    for (final id in nmIds) {
      // delete card from the server

      // delete card from the local storage
      final deleteEither = await cardOfProductDataProvider.delete(id: id);
      if (deleteEither.isLeft()) {
        return left(
            deleteEither.fold((l) => l, (r) => throw UnimplementedError()));
      }

      // delete notifications for this card
      final deleteNotificationsEither =
          await notificationDataProvider.deleteAll(parentId: id);
      if (deleteNotificationsEither.isLeft()) {
        return left(deleteNotificationsEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
    }

    // get all cards from local db
    final cardsInDBEither = await cardOfProductDataProvider.getAll();
    if (cardsInDBEither.isLeft()) {
      return left(
          cardsInDBEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    // final cardsInDB =
    //     cardsInDBEither.fold((l) => throw UnimplementedError(), (r) => r);
    // cardsNumberStreamController.add(cardsInDB.length);
    return right(nmIds.length);
  }
}
