import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/api_clients/auth_api_client.dart';
import 'package:rewild_bot_front/api_clients/commision_api_client.dart';
import 'package:rewild_bot_front/api_clients/details_api_client.dart';
import 'package:rewild_bot_front/api_clients/initial_stocks_api_client.dart';
import 'package:rewild_bot_front/api_clients/price_api_client.dart';
import 'package:rewild_bot_front/api_clients/product_card_service_api_client.dart';
import 'package:rewild_bot_front/api_clients/subscription_api_client.dart';
import 'package:rewild_bot_front/api_clients/warehouse_api_client.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/data_providers/average_logistics_data_provider/average_logistics_data_provider.dart';
import 'package:rewild_bot_front/data_providers/cached_kw_by_lemma_by_word_data_provider/cached_kw_by_lemma_by_word_data_provider.dart';
import 'package:rewild_bot_front/data_providers/cached_kw_by_lemma_data_provider/cached_kw_by_lemma_data_provider.dart';
import 'package:rewild_bot_front/data_providers/cached_lemma_data_provider/cached_lemma_data_provider.dart';
import 'package:rewild_bot_front/data_providers/cahced_kw_by_autocomplite_data_provider/cahced_kw_by_autocomplite_data_provider.dart';
import 'package:rewild_bot_front/data_providers/card_keywords_data_provider/card_keywords_data_provider.dart';
import 'package:rewild_bot_front/data_providers/card_of_product_data_provider/card_of_product_data_provider.dart';
import 'package:rewild_bot_front/data_providers/filter_data_provider/filter_data_provider.dart';
import 'package:rewild_bot_front/data_providers/filter_value_data_provider/filter_value_data_provider.dart';
import 'package:rewild_bot_front/data_providers/group_data_provider/group_data_provider.dart';
import 'package:rewild_bot_front/data_providers/initial_stock_data_provider/initial_stock_data_provider.dart';
import 'package:rewild_bot_front/data_providers/last_update_day_data_provider/last_update_day_data_provider.dart';
import 'package:rewild_bot_front/data_providers/last_update_day_data_provider/last_update_day_data_provider.dart';
import 'package:rewild_bot_front/data_providers/last_update_day_data_provider/last_update_day_data_provider.dart';
import 'package:rewild_bot_front/data_providers/nm_id_data_provider/nm_id_data_provider.dart';
import 'package:rewild_bot_front/data_providers/notification_data_provider/notification_data_provider.dart';
import 'package:rewild_bot_front/data_providers/order_data_provider/order_data_provider.dart';
import 'package:rewild_bot_front/data_providers/rewild_notification_data_provider/rewild_notification_data_provider.dart';
import 'package:rewild_bot_front/data_providers/secure_storage_data_provider/secure_storage_data_provider.dart';
import 'package:rewild_bot_front/data_providers/seller_data_provider/seller_data_provider.dart';
import 'package:rewild_bot_front/data_providers/stock_data_provider/stock_data_provider.dart';
import 'package:rewild_bot_front/data_providers/subscription_data_provider/subscription_data_provider.dart';
import 'package:rewild_bot_front/data_providers/supply_data_provider/supply_data_provider.dart';
import 'package:rewild_bot_front/data_providers/tariff_data_provider/tariff_data_provider.dart';
import 'package:rewild_bot_front/data_providers/total_cost_data_provider.dart/total_cost_data_provider.dart';
import 'package:rewild_bot_front/data_providers/tracking_result_data_provider/tracking_result_data_provider.dart';
import 'package:rewild_bot_front/data_providers/user_sellers_data_provider/user_sellers_data_provider.dart';
import 'package:rewild_bot_front/data_providers/notification_data_provider/notification_data_provider.dart';
import 'package:rewild_bot_front/data_providers/warehouse_data_provider/warehouse_data_provider.dart';
import 'package:rewild_bot_front/domain/entities/hive/card_of_product.dart';
import 'package:rewild_bot_front/domain/entities/hive/total_cost_calculator.dart';
import 'package:rewild_bot_front/domain/entities/stream_advert_event.dart';
import 'package:rewild_bot_front/domain/entities/stream_notification_event.dart';
import 'package:rewild_bot_front/domain/services/all_cards_filter_service.dart';
import 'package:rewild_bot_front/domain/services/api_keys_service.dart';
import 'package:rewild_bot_front/domain/services/auth_service.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/group_service.dart';
import 'package:rewild_bot_front/domain/services/notification_service.dart';
import 'package:rewild_bot_front/domain/services/subscription_service.dart';
import 'package:rewild_bot_front/domain/services/supply_service.dart';
import 'package:rewild_bot_front/domain/services/tariff_service.dart';
import 'package:rewild_bot_front/domain/services/total_cost_service.dart';
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
  // Notification (NotificationService ---> ???)
  final updatedNotificationStreamController =
      StreamController<StreamNotificationEvent>.broadcast();
  Stream<StreamNotificationEvent> get updatedNotificationStream =>
      updatedNotificationStreamController.stream;

  // Api Clients ===============================================================
  CardOfProductApiClient _makeCardOfProductApiClient() =>
      const CardOfProductApiClient();
  DetailsApiClient _makeDetailsApiClient() => const DetailsApiClient();
  CommissionApiClient _makeCommissionApiClient() => const CommissionApiClient();
  InitialStocksApiClient _makeStocksApiClient() =>
      const InitialStocksApiClient();

  SubscriptionApiClient _makeSubscriptionApiClient() =>
      const SubscriptionApiClient();

  PriceApiClient _makePriceApiClient() => const PriceApiClient();

  WarehouseApiClient _makeWarehouseApiClient() => const WarehouseApiClient();

  AuthApiClient _makeAuthApiClient() => const AuthApiClient();
  // Data Providers ============================================================
  // secure storage
  SecureStorageProvider _makeSecureDataProvider() =>
      const SecureStorageProvider();
  UserSellersDataProvider _makeUserSellersDataProvider() =>
      const UserSellersDataProvider();
  AverageLogisticsDataProvider _makeAverageLogisticsDataProvider() =>
      const AverageLogisticsDataProvider();
  SupplyDataProvider _makeSupplyDataProvider() => const SupplyDataProvider();

  TariffDataProvider _makeTariffDataProvider() => const TariffDataProvider();

  CardOfProductDataProvider _makeCardOfProductDataProvider() =>
      const CardOfProductDataProvider();

  InitialStockDataProvider _makeInitialStockDataProvider() =>
      const InitialStockDataProvider();

  StockDataProvider _makeStockDataProvider() => const StockDataProvider();

  OrderDataProvider _makeOrderDataProvider() => const OrderDataProvider();

  CardKeywordsDataProvider _makeCardKeywordsDataProvider() =>
      const CardKeywordsDataProvider();

  CachedKwByAutocompliteDataProvider
      _makeCachedKwByAutocompliteDataProvider() =>
          const CachedKwByAutocompliteDataProvider();

  CachedKwByLemmaDataProvider _makeCachedKwByLemmaDataProvider() =>
      const CachedKwByLemmaDataProvider();

  CachedKwByWordDataProvider _makeCachedKwByWordDataProvider() =>
      const CachedKwByWordDataProvider();

  LastUpdateDayDataProvider _makeLastUpdateDayDataProvider() =>
      const LastUpdateDayDataProvider();

  FilterDataProvider _makeFilterDataProvider() => const FilterDataProvider();

  FilterValuesDataProvider _makeFilterValuesDataProvider() =>
      const FilterValuesDataProvider();
  TrackingResultDataProvider _makeTrackingResultDataProvider() =>
      const TrackingResultDataProvider();

  CachedLemmaDataProvider _makeLemmaDataProvider() =>
      const CachedLemmaDataProvider();

  SubscriptionDataProvider _makeSubscriptionDataProvider() =>
      const SubscriptionDataProvider();

  GroupDataProvider _makeGroupDataProvider() => const GroupDataProvider();

  SellerDataProvider _makeSellerDataProvider() => const SellerDataProvider();

  NotificationDataProvider _makeNotificationDataProvider() =>
      const NotificationDataProvider();

  TotalCostCalculatorDataProvider _makeTotalCostCalculatorDataProvider() =>
      const TotalCostCalculatorDataProvider();

  NmIdDataProvider _makeNmIdDataProvider() => const NmIdDataProvider();

  WarehouseDataProvider _makeWarehouseDataProvider() =>
      const WarehouseDataProvider();
  // Services ==================================================================
  AuthService _makeAuthService() => AuthService(
      secureDataProvider: _makeSecureDataProvider(),
      authApiClient: _makeAuthApiClient());
  UpdateService _makeUpdateService() => UpdateService(
        averageLogisticsDataProvider: _makeAverageLogisticsDataProvider(),
        supplyDataProvider: _makeSupplyDataProvider(),
        tariffDataProvider: _makeTariffDataProvider(),
        notificationDataProvider: _makeNotificationDataProvider(),
        cardOfProductDataProvider: _makeCardOfProductDataProvider(),
        initialStockDataProvider: _makeInitialStockDataProvider(),
        stockDataProvider: _makeStockDataProvider(),
        weekOrdersDataProvider: _makeOrderDataProvider(),
        totalCostdataProvider: _makeTotalCostCalculatorDataProvider(),
        cardKeywordsDataProvider: _makeCardKeywordsDataProvider(),
        cachedKwByAutocompliteDataProvider:
            _makeCachedKwByAutocompliteDataProvider(),
        cachedKwByLemmaDataProvider: _makeCachedKwByLemmaDataProvider(),
        cachedKwByLemmaByWordDataProvider: _makeCachedKwByWordDataProvider(),
        lastUpdateDayDataProvider: _makeLastUpdateDayDataProvider(),
        filterDataProvider: _makeFilterValuesDataProvider(),
        trackingResultDataProvider: _makeTrackingResultDataProvider(),
        lemmaDataProvider: _makeLemmaDataProvider(),
        tariffApiClient: _makeCommissionApiClient(),
        detailsApiClient: _makeDetailsApiClient(),
        averageLogisticsApiClient: _makePriceApiClient(),
        initialStockApiClient: _makeStocksApiClient(),
        cardOfProductApiClient: _makeCardOfProductApiClient(),
      );

  ApiKeysService _makeApiKeysService() => ApiKeysService(
        apiKeysDataProvider: _makeSecureDataProvider(),
        activeSellerDataProvider: _makeUserSellersDataProvider(),
        apiKeyExistsStreamController: apiKeyExistsStreamController,
      );

  SubscriptionService _makeSubscriptionService() => SubscriptionService(
        apiClient: _makeSubscriptionApiClient(),
        dataProvider: _makeSubscriptionDataProvider(),
        // subsToDeleteDataProvider: _makeSubsToDeleteDataProvider(),
        cardsNumberStreamController: subscriptionStreamController,
      );

  SupplyService _makeSupplyService() => SupplyService(
        supplyDataProvider: _makeSupplyDataProvider(),
      );

  GroupService _makeAllGroupsService() => GroupService(
        groupDataProvider: _makeGroupDataProvider(),
      );
  AllCardsFilterService _makeAllCardsFilterService() => AllCardsFilterService(
        cardsOfProductsDataProvider: _makeCardOfProductDataProvider(),
        filterDataProvider: _makeFilterDataProvider(),
        sellerDataProvider: _makeSellerDataProvider(),
      );

  NotificationService _makeNotificationService() => NotificationService(
      notificationDataProvider: _makeNotificationDataProvider(),
      updatedNotificationStreamController: updatedNotificationStreamController);

  TotalCostService _makeTotalCostService() => TotalCostService(
        totalCostDataProvider: _makeTotalCostCalculatorDataProvider(),
      );

  TariffService _makeTariffService() => TariffService(
        averageLogisticsApiClient: _makePriceApiClient(),
        averageLogisticsDataProvider: _makeAverageLogisticsDataProvider(),
        tariffDataProvider: _makeTariffDataProvider(),
      );

  CardOfProductService _makeCardOfProductService() => CardOfProductService(
      cardOfProductApiClient: _makeCardOfProductApiClient(),
      cardOfProductDataProvider: _makeCardOfProductDataProvider(),
      initStockDataProvider: _makeInitialStockDataProvider(),
      nmIdDataProvider: _makeNmIdDataProvider(),
      stockDataprovider: _makeStockDataProvider(),
      supplyDataProvider: _makeSupplyDataProvider(),
      warehouseApiClient: _makeWarehouseApiClient(),
      warehouseDataprovider: _makeWarehouseDataProvider());
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
