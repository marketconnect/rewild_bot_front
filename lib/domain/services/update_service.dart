import 'dart:async';

import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/constants/settings.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/card_of_product.dart';
import 'package:rewild_bot_front/domain/entities/hive/initial_stock.dart';
import 'package:rewild_bot_front/domain/entities/prices.dart';
import 'package:rewild_bot_front/domain/entities/size_model.dart';
import 'package:rewild_bot_front/domain/entities/hive/stock.dart';
import 'package:rewild_bot_front/domain/entities/hive/supply.dart';
import 'package:rewild_bot_front/domain/entities/hive/tariff.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';

// Tariffs Api
abstract class UpdateServiceTariffApiClient {
  Future<Either<RewildError, List<Tariff>>> getTarrifs({required String token});
}

// Tariffs data provider
abstract class UpdateServiceTariffDataProvider {
  Future<Either<RewildError, void>> insertAll(List<Tariff> tariffs);
}

// Details
abstract class UpdateServiceDetailsApiClient {
  Future<Either<RewildError, List<CardOfProduct>>> get(
      {required List<int> ids});
}

// Supply
abstract class UpdateServiceSupplyDataProvider {
  Future<Either<RewildError, void>> deleteAll();
  Future<Either<RewildError, int>> insert({required Supply supply});
  Future<Either<RewildError, void>> delete({
    required int nmId,
    int? wh,
    int? sizeOptionId,
  });
  Future<Either<RewildError, Supply?>> getOne({
    required int nmId,
    required int wh,
    required int sizeOptionId,
  });
}

// Card of product data provider
abstract class UpdateServiceCardOfProductDataProvider {
  Future<Either<RewildError, List<CardOfProduct>>> getAll();
  Future<Either<RewildError, int>> insertOrUpdate(
      {required CardOfProduct card});
  Future<Either<RewildError, int>> delete({required int id});
}

// Card of product api client
abstract class UpdateServiceCardOfProductApiClient {
  Future<Either<RewildError, void>> save(
      {required String token, required List<CardOfProduct> productCards});
  Future<Either<RewildError, List<CardOfProduct>>> getAll(
      {required String token});
  Future<Either<RewildError, void>> delete(
      {required String token, required int id});
}

// initial stock api client
abstract class UpdateServiceInitialStockApiClient {
  Future<Either<RewildError, List<InitialStock>>> get(
      {required String token,
      required List<int> skus,
      required DateTime dateFrom,
      required DateTime dateTo});
}

// init stock data provider
abstract class UpdateServiceInitStockDataProvider {
  Future<Either<RewildError, int>> insert({required InitialStock initialStock});
  Future<Either<RewildError, List<InitialStock>>> get(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo});
  Future<Either<RewildError, InitialStock?>> getOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo,
      required int wh,
      required int sizeOptionId});

  Future<Either<RewildError, void>> deleteAll();
}

// stock data provider
abstract class UpdateServiceStockDataProvider {
  Future<Either<RewildError, int>> insert({required Stock stock});
  Future<Either<RewildError, List<Stock>>> get({required int nmId});
  Future<Either<RewildError, Stock>> getOne(
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

abstract class UpdateServiceFilterDataProvider {
  Future<Either<RewildError, void>> deleteOld();
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

        // PaymentScreenUpdateService,
        MainNavigationUpdateService {
  final UpdateServiceDetailsApiClient detailsApiClient;
  final UpdateServiceSupplyDataProvider supplyDataProvider;
  final UpdateServiceCardOfProductDataProvider cardOfProductDataProvider;
  final UpdateServiceCardOfProductApiClient cardOfProductApiClient;
  final UpdateServiceInitialStockApiClient initialStockApiClient;
  final UpdateServiceInitStockDataProvider initialStockDataProvider;
  final UpdateServiceStockDataProvider stockDataProvider;
  final UpdateServiceLastUpdateDayDataProvider lastUpdateDayDataProvider;
  final UpdateServiceNotificationDataProvider notificationDataProvider;
  final UpdateServiceFilterDataProvider filterDataProvider;
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
      // required this.cardsNumberStreamController,
      required this.weekOrdersDataProvider,
      required this.initialStockDataProvider,
      required this.tariffApiClient,
      required this.averageLogisticsApiClient,
      required this.totalCostdataProvider,
      required this.lemmaDataProvider,
      required this.cachedKwByLemmaDataProvider,
      required this.tariffDataProvider,
      required this.averageLogisticsDataProvider,
      required this.cardOfProductDataProvider,
      required this.notificationDataProvider,
      required this.initialStockApiClient,
      required this.filterDataProvider,
      required this.trackingResultDataProvider,
      required this.supplyDataProvider,
      required this.lastUpdateDayDataProvider,
      required this.cardKeywordsDataProvider,
      required this.cachedKwByLemmaByWordDataProvider,
      required this.cachedKwByAutocompliteDataProvider,
      required this.cardOfProductApiClient});

  // Time to update?
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
    // check db is empty when app starts

    final cardsInDbEither = await cardOfProductDataProvider.getAll();
    if (cardsInDbEither.isLeft()) {
      return left(
          cardsInDbEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final cardsInDB = cardsInDbEither.getOrElse((l) => []);

    // Empty - try to fetch cards from server
    if (cardsInDB.isEmpty) {
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
    }
    return right(null);
  }

  // returns quantity of inserted cards ========================================================================
  @override
  Future<Either<RewildError, int>> insert(
      {required String token,
      required List<CardOfProduct> cardOfProductsToInsert}) async {
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

    List<CardOfProduct> newCards = [];
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

    List<InitialStock> initStocksFromServer = [];

    // ids of cards that initial stocks do not exist on server yet
    List<int> abscentOnServerNewCardsIds = newCards.map((e) => e.nmId).toList();

    // initial stocks from server

    final initialStocksEither = await initialStockApiClient.get(
      token: token,
      skus: newCards.map((e) => e.nmId).toList(),
      dateFrom: yesterdayEndOfTheDay(),
      dateTo: DateTime.now(),
    );

    initStocksFromServer = initialStocksEither.getOrElse((l) => []);

    // save fetched from server initial stocks to local db
    for (final stock in initStocksFromServer) {
      final insertStockEither =
          await initialStockDataProvider.insert(initialStock: stock);

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
            final insertInitialStockEither =
                await initialStockDataProvider.insert(
                    initialStock: InitialStock(
              nmId: stock.nmId,
              sizeOptionId: stock.sizeOptionId,
              date: DateTime.now(),
              wh: stock.wh,
              qty: stock.qty,
            ));
            if (insertInitialStockEither.isLeft()) {
              return left(insertInitialStockEither.fold(
                  (l) => l, (r) => throw UnimplementedError()));
            }
          }
        }
      }
    }
    // cardsNumberStreamController.add(newCards.length + cardsInDB.length);
    return right(newCards.length);
  }

  @override
  Future<Either<RewildError, void>> putOnServerNewCards(
      {required String token,
      required List<CardOfProduct> cardOfProductsToPutOnServer}) async {
    // get rid of duplicates
    final uniqueNewCards = cardOfProductsToPutOnServer.toSet().toList();
    final saveOnServerEither = await cardOfProductApiClient.save(
        token: token, productCards: uniqueNewCards);

    if (saveOnServerEither.isLeft()) {
      return left(
          saveOnServerEither.fold((l) => l, (r) => throw UnimplementedError()));
    }
    return right(null);
  }

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
    final isUpdated =
        isUpdatedEither.fold((l) => throw UnimplementedError(), (r) => r);

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

      // delete all saved filter values
      final deleteFilterValuesEither = await filterDataProvider.deleteOld();
      if (deleteFilterValuesEither.isLeft()) {
        return left(deleteFilterValuesEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      // since there is today first time update - delete supplies and initial stocks
      final deleteSuppliesEither = await supplyDataProvider.deleteAll();
      if (deleteSuppliesEither.isLeft()) {
        return left(deleteSuppliesEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

      final deleteInitialStocksEither =
          await initialStockDataProvider.deleteAll();
      if (deleteInitialStocksEither.isLeft()) {
        return left(deleteInitialStocksEither.fold(
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
      final todayInitialStocksFromServerEither =
          await _fetchTodayInitialStocksFromServer(
              token, allSavedCardsOfProducts.map((e) => e.nmId).toList());
      if (todayInitialStocksFromServerEither is Left) {
        return left(todayInitialStocksFromServerEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      final todayInitialStocksFromServer = todayInitialStocksFromServerEither
          .fold((l) => throw UnimplementedError(), (r) => r);

      // save today`s initial stocks to local db
      for (final stock in todayInitialStocksFromServer) {
        final insertInitialStockEither = await initialStockDataProvider.insert(
            initialStock: InitialStock(
          nmId: stock.nmId,
          sizeOptionId: stock.sizeOptionId,
          date: DateTime.now(),
          wh: stock.wh,
          qty: stock.qty,
        ));

        if (insertInitialStockEither is Left) {
          return left(insertInitialStockEither.fold(
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
      List<Stock> stocks = [];
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
      List<SizeModel> sizes, List<Stock> stocks) async {
    final dateFrom = yesterdayEndOfTheDay();
    final dateTo = DateTime.now();

    // for each size
    for (final size in sizes) {
      // for each stock
      for (final stock in size.stocks) {
        // get saved init stock
        final initStockEither = await initialStockDataProvider.getOne(
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
          final insertInitStockEither = await initialStockDataProvider.insert(
              initialStock: InitialStock(
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
                supply: Supply(
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
              // final savedStockEither = await stockDataProvider.getOne(
              //   nmId: stock.nmId,
              //   wh: stock.wh,
              //   sizeOptionId: stock.sizeOptionId,
              // );
              // if (savedStockEither.isLeft()) {
              //   print(
              //       'savedStockEither ${stock.qty} - ${initStock.qty}  nmId: ${stock.nmId}, wh: ${stock.wh}, sizeOptionId: ${stock.sizeOptionId},');
              //   return left(savedStockEither.fold(
              //       (l) => l, (r) => throw UnimplementedError()));
              // }
              // final savedStockData =
              //     savedStockEither.getOrElse((l) => throw UnimplementedError());

              final stockForSup = stocks.where((e) => e.nmId == stock.nmId);
              if (stockForSup.isNotEmpty) {
                final savedStockData = stockForSup.first;

                final insertSupplyEither = await supplyDataProvider.insert(
                    supply: Supply(
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
                    supply: Supply(
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

          final insertStockEither =
              await stockDataProvider.insert(stock: stock);
          if (insertStockEither.isLeft()) {
            return left(insertStockEither.fold(
                (l) => l, (r) => throw UnimplementedError()));
          }
        }
      }
    }
    return right(null);
  }

  Future<Either<RewildError, List<InitialStock>>>
      _fetchTodayInitialStocksFromServer(
          String token, List<int> cardsWithoutTodayInitStocksIds) async {
    List<InitialStock> initialStocksFromServer = [];
    if (cardsWithoutTodayInitStocksIds.isNotEmpty) {
      final initialStocksEither = await initialStockApiClient.get(
        token: token,
        skus: cardsWithoutTodayInitStocksIds,
        dateFrom: yesterdayEndOfTheDay(),
        dateTo: DateTime.now(),
      );
      if (initialStocksEither.isLeft()) {
        return left(initialStocksEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      initialStocksFromServer =
          initialStocksEither.getOrElse((l) => throw UnimplementedError());

      // save initial stocks to local db
      for (final stock in initialStocksFromServer) {
        final insertStockEither =
            await initialStockDataProvider.insert(initialStock: stock);
        if (insertStockEither.isLeft()) {
          return left(insertStockEither.fold(
              (l) => l, (r) => throw UnimplementedError()));
        }
      }
    }
    return right(initialStocksFromServer);
  }

  @override
  Future<Either<RewildError, int>> delete(
      {required String token, required List<int> nmIds}) async {
    for (final id in nmIds) {
      // delete card from the server

      final deleteFromServerEither =
          await cardOfProductApiClient.delete(token: token, id: id);
      if (deleteFromServerEither.isLeft()) {
        return left(deleteFromServerEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }

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
    // cardsInDBEither.getOrElse((l) => throw UnimplementedError());
    // cardsNumberStreamController.add(cardsInDB.length);
    return right(nmIds.length);
  }

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
