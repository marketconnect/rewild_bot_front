import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/data_providers/secure_storage_data_provider/secure_storage_data_provider.dart';
import 'package:rewild_bot_front/data_providers/user_sellers_data_provider/user_sellers_data_provider.dart';
import 'package:rewild_bot_front/domain/entities/stream_advert_event.dart';
import 'package:rewild_bot_front/domain/services/api_keys_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

import 'package:rewild_bot_front/main.dart';
import 'package:rewild_bot_front/presentation/add_api_keys_screen/add_api_keys_screen.dart';
import 'package:rewild_bot_front/presentation/add_api_keys_screen/add_api_keys_view_model.dart';
import 'package:rewild_bot_front/presentation/all_cards_screen/all_cards_screen.dart';
import 'package:rewild_bot_front/presentation/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/app/app.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_screen.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild_bot_front/routes/main_navigation.dart';

AppFactory makeAppFactory() => _AppFactoryDefault();

class _AppFactoryDefault implements AppFactory {
  final _diContainer = _DIContainer();

  _AppFactoryDefault();

  @override
  Widget makeApp() {
    return App(
      navigation: _diContainer._makeAppNavigation(),
    );
  }
}

class _DIContainer {
  _DIContainer();

  // Factories
  ScreenFactory _makeScreenFactory() => ScreenFactoryDefault(this);
  AppNavigation _makeAppNavigation() => MainNavigation(_makeScreenFactory());

  // Streams
  // streams ===================================================================

  // Api Key Exist (AdvertService --> BottomNavigationViewModel)
  final apiKeyExistsStreamController =
      StreamController<Map<ApiKeyType, String>>.broadcast();
  Stream<Map<ApiKeyType, String>> get apiKeyExistsStream =>
      apiKeyExistsStreamController.stream;

  // cards number (CardOfProductService --> BottomNavigationViewModel)
  final subscriptionStreamController = StreamController<(int, int)>.broadcast();
  Stream<(int, int)> get cardsNumberStream =>
      subscriptionStreamController.stream;

  // Advert (AdvertService ---> MainNavigationViewModel) (AdvertService ---> AllAdvertsStatScreenViewModel)
  final updatedAdvertStreamController =
      StreamController<StreamAdvertEvent>.broadcast();
  Stream<StreamAdvertEvent> get updatedAdvertStream =>
      updatedAdvertStreamController.stream;

  // Data Providers ============================================================
  // secure storage
  SecureStorageProvider _makeSecureDataProvider() =>
      const SecureStorageProvider();
  UserSellersDataProvider _makeUserSellersDataProvider() =>
      const UserSellersDataProvider();

  // Services ==================================================================
  UpdateService _makeUpdateService() => UpdateService(
        cardOfProductApiClient: _makeCardOfProductApiClient(),
        detailsApiClient: _makeDetailsApiClient(),
        initialStockApiClient: _makeStocksApiClient(),
        averageLogisticsApiClient: _makePriceApiClient(),
        averageLogisticsDataProvider: _makeAverageLogisticsDataProvider(),
        supplyDataProvider: _makeSupplyDataProvider(),
        tariffApiClient: _makeCommissionApiClient(),
        tariffDataProvider: _makeTariffDataProvider(),
        weekOrdersDataProvider: _makeOrderDataProvider(),
        totalCostdataProvider: _makeTotalCostCalculatorDataProvider(),
        cardKeywordsDataProvider: _makeCardKeywordsDataProvider(),
        notificationDataProvider: _makeNotificationDataProvider(),
        cachedKwByAutocompliteDataProvider:
            _makeCachedKwByAutocompliteDataProvider(),
        lastUpdateDayDataProvider: _makeLastUpdateDayDataProvider(),
        filterDataProvider: _makeFilterValuesDataProvider(),
        trackingResultDataProvider: _makeTrackingResultDataProvider(),
        cardOfProductDataProvider: _makeCardOfProductDataProvider(),
        initialStockDataProvider: _makeInitialStockDataProvider(),
        stockDataProvider: _makeStockDataProvider(),
        lemmaDataProvider: _makeLemmaDataProvider(),
        cachedKwByLemmaByWordDataProvider: _makeCachedKwByWordDataProvider(),
        cachedKwByLemmaDataProvider: _makeCachedKwByLemmaDataProvider(),
      );

  ApiKeysService _makeApiKeysService() => ApiKeysService(
        apiKeysDataProvider: _makeSecureDataProvider(),
        activeSellerDataProvider: _makeUserSellersDataProvider(),
        apiKeyExistsStreamController: apiKeyExistsStreamController,
      );

  // View Models ===============================================================
  MainNavigationViewModel _makeBottomNavigationViewModel(
          BuildContext context) =>
      MainNavigationViewModel(
        context: context,

        updatedAdvertStream: updatedAdvertStream,
        cardsNumberStream: cardsNumberStream,
        apiKeyExistsStream: apiKeyExistsStream,
        // updateService: _makeUpdateService(),
        // subscriptionService: _makeSubscriptionService(),
        // tokenProvider: _makeAuthService(),
        // questionService: _makeQuestionService(),
        // advertService: _makeAdvertService(),
        // cardService: _makeCardOfProductService()
      );
  AddApiKeysScreenViewModel _makeApiKeysScreenViewModel(BuildContext context) =>
      AddApiKeysScreenViewModel(
          context: context, apiKeysService: _makeApiKeysService());

  AllCardsScreenViewModel _makeAllCardsScreenViewModel(context) =>
      AllCardsScreenViewModel(
          context: context,
          updateService: _makeUpdateService(),
          subscriptionsService: _makeSubscriptionService(),
          supplyService: _makeSupplyService(),
          groupsProvider: _makeAllGroupsService(),
          filterService: _makeAllCardsFilterService(),
          notificationsService: _makeNotificationService(),
          totalCostService: _makeTotalCostService(),
          averageLogisticsService: _makeTariffService(),
          cardsOfProductsService: _makeCardOfProductService(),
          tokenService: _makeAuthService());
}

class ScreenFactoryDefault implements ScreenFactory {
  final _DIContainer _diContainer;

  const ScreenFactoryDefault(this._diContainer);

  @override
  Widget makeMainNavigationScreen() {
    return ChangeNotifierProvider(
        create: (context) =>
            _diContainer._makeBottomNavigationViewModel(context),
        child: const MainNavigationScreen());
  }

  @override
  Widget makeApiKeysScreen() {
    return ChangeNotifierProvider(
        create: (context) => _diContainer._makeApiKeysScreenViewModel(context),
        child: const AddApiKeysScreen());
  }

  @override
  Widget makeAllCardsScreen() {
    return ChangeNotifierProvider(
        create: (context) => _diContainer._makeAllCardsScreenViewModel(context),
        child: const AllCardsScreen());
  }

  @override
  Widget makeScreen1() {
    return Screen1();
  }

  @override
  Widget makeScreen2() {
    return Screen2();
  }

  @override
  Widget makeScreen3() {
    return Screen3();
  }

  @override
  Widget makeHomeScreen() {
    return HomeScreen();
  }
}
