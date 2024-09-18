import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/api_clients/advert_api_client.dart';
import 'package:rewild_bot_front/api_clients/auth_api_client.dart';
import 'package:rewild_bot_front/api_clients/commision_api_client.dart';
import 'package:rewild_bot_front/api_clients/details_api_client.dart';
import 'package:rewild_bot_front/api_clients/filter_api_client.dart';
import 'package:rewild_bot_front/api_clients/product_watch_subscription_api_client.dart';
import 'package:rewild_bot_front/api_clients/reviews_api_client.dart';
import 'package:rewild_bot_front/api_clients/search_api_client.dart';
import 'package:rewild_bot_front/api_clients/search_query_api_client.dart';
import 'package:rewild_bot_front/api_clients/initial_stocks_api_client.dart';
import 'package:rewild_bot_front/api_clients/orders_history_api_client.dart';
import 'package:rewild_bot_front/api_clients/price_api_client.dart';
import 'package:rewild_bot_front/api_clients/card_of_product_api_client.dart';
import 'package:rewild_bot_front/api_clients/product_keywords_api_client.dart';
import 'package:rewild_bot_front/api_clients/questions_api_client.dart';
import 'package:rewild_bot_front/api_clients/seller_api_client.dart';
import 'package:rewild_bot_front/api_clients/statistics_api_client.dart';
import 'package:rewild_bot_front/api_clients/subscription_api_client.dart';
import 'package:rewild_bot_front/api_clients/warehouse_api_client.dart';
import 'package:rewild_bot_front/api_clients/wb_auto_campaign_api_client.dart';
import 'package:rewild_bot_front/api_clients/wb_content_api_client.dart';
import 'package:rewild_bot_front/api_clients/wb_search_suggestion_api_client.dart';
import 'package:rewild_bot_front/api_clients/week_orders_api_client.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/data_providers/answer_data_provider/answer_data_provider.dart';
import 'package:rewild_bot_front/data_providers/average_logistics_data_provider.dart';
import 'package:rewild_bot_front/data_providers/cached_kw_by_lemma_by_word_data_provider/cached_kw_by_lemma_by_word_data_provider.dart';
import 'package:rewild_bot_front/data_providers/cached_lemma_data_provider/cached_lemma_data_provider.dart';
import 'package:rewild_bot_front/data_providers/cahced_kw_by_autocomplite_data_provider/cahced_kw_by_autocomplite_data_provider.dart';
import 'package:rewild_bot_front/data_providers/cahced_kw_by_lemma_data_provider/cahced_kw_by_lemma_data_provider.dart';

import 'package:rewild_bot_front/data_providers/card_keywords_data_provider/card_keywords_data_provider.dart';
import 'package:rewild_bot_front/data_providers/card_of_product_data_provider/card_of_product_data_provider.dart';
import 'package:rewild_bot_front/data_providers/commission_data_provider/commission_data_provider.dart';
import 'package:rewild_bot_front/data_providers/filter_data_provider/filter_data_provider.dart';
import 'package:rewild_bot_front/data_providers/filter_values_data_provider/filter_values_data_provider.dart';

import 'package:rewild_bot_front/data_providers/group_data_provider/group_data_provider.dart';
import 'package:rewild_bot_front/data_providers/initial_stocks_data_provider/initial_stocks_data_provider.dart';
import 'package:rewild_bot_front/data_providers/keyword_data_provider/keyword_data_provider.dart';
import 'package:rewild_bot_front/data_providers/last_update_day_data_provider/last_update_day_data_provider.dart';
import 'package:rewild_bot_front/data_providers/nm_id_data_provider/nm_id_data_provider.dart';
import 'package:rewild_bot_front/data_providers/notification_data_provider/notification_data_provider.dart';
import 'package:rewild_bot_front/data_providers/orders_data_provider/orders_data_provider.dart';
import 'package:rewild_bot_front/data_providers/orders_history_data_provider/orders_history_data_provider.dart';
import 'package:rewild_bot_front/data_providers/secure_storage_data_provider/secure_storage_data_provider.dart';
import 'package:rewild_bot_front/data_providers/seller_data_provider/seller_data_provider.dart';
import 'package:rewild_bot_front/data_providers/seo_kw_by_lemma_data_provider/seo_kw_by_lemma_data_provider.dart';
import 'package:rewild_bot_front/data_providers/stock_data_provider/stock_data_provider.dart';
import 'package:rewild_bot_front/data_providers/subscribed_cards_data_provider/subscribed_cards_data_provider.dart';
import 'package:rewild_bot_front/data_providers/subscription_data_provider/subscription_data_provider.dart';
import 'package:rewild_bot_front/data_providers/supply_data_provider/supply_data_provider.dart';
import 'package:rewild_bot_front/data_providers/tariff_data_provider/tariff_data_provider.dart';
import 'package:rewild_bot_front/data_providers/total_cost_data_provider/total_cost_data_provider.dart';
import 'package:rewild_bot_front/data_providers/tracking_query_provider/tracking_query_provider.dart';
import 'package:rewild_bot_front/data_providers/tracking_result_data_provider/tracking_result_data_provider.dart';
import 'package:rewild_bot_front/data_providers/user_sellers_data_provider/user_sellers_data_provider.dart';
import 'package:rewild_bot_front/data_providers/warehouse_data_provider/warehouse_data_provider.dart';
import 'package:rewild_bot_front/domain/entities/card_catalog.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';

import 'package:rewild_bot_front/domain/entities/payment_info.dart';
import 'package:rewild_bot_front/domain/entities/question_model.dart';
import 'package:rewild_bot_front/domain/entities/review_model.dart';

import 'package:rewild_bot_front/domain/entities/stream_advert_event.dart';
import 'package:rewild_bot_front/domain/entities/stream_notification_event.dart';
import 'package:rewild_bot_front/domain/services/advert_service.dart';
import 'package:rewild_bot_front/domain/services/adverts_analitics_service.dart';
import 'package:rewild_bot_front/domain/services/all_cards_filter_service.dart';
import 'package:rewild_bot_front/domain/services/answer_service.dart';

import 'package:rewild_bot_front/domain/services/api_keys_service.dart';
import 'package:rewild_bot_front/domain/services/auth_service.dart';
import 'package:rewild_bot_front/domain/services/balance_service.dart';
import 'package:rewild_bot_front/domain/services/card_keywords_service.dart';

import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/commission_service.dart';
import 'package:rewild_bot_front/domain/services/content_service.dart';
import 'package:rewild_bot_front/domain/services/filter_values_service.dart';
import 'package:rewild_bot_front/domain/services/geo_search_service.dart';

import 'package:rewild_bot_front/domain/services/group_service.dart';
import 'package:rewild_bot_front/domain/services/init_stock_service.dart';
import 'package:rewild_bot_front/domain/services/keywords_service.dart';
import 'package:rewild_bot_front/domain/services/notification_service.dart';
import 'package:rewild_bot_front/domain/services/orders_history_service.dart';
import 'package:rewild_bot_front/domain/services/price_service.dart';
import 'package:rewild_bot_front/domain/services/question_service.dart';
import 'package:rewild_bot_front/domain/services/realization_report_service.dart';
import 'package:rewild_bot_front/domain/services/review_service.dart';
import 'package:rewild_bot_front/domain/services/seller_service.dart';
import 'package:rewild_bot_front/domain/services/seo_service.dart';
import 'package:rewild_bot_front/domain/services/stock_service.dart';
import 'package:rewild_bot_front/domain/services/subscription_service.dart';
import 'package:rewild_bot_front/domain/services/supply_service.dart';
import 'package:rewild_bot_front/domain/services/tariff_service.dart';
import 'package:rewild_bot_front/domain/services/total_cost_service.dart';
import 'package:rewild_bot_front/domain/services/tracking_service.dart';
import 'package:rewild_bot_front/domain/services/unanswered_feedback_qty_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';
import 'package:rewild_bot_front/domain/services/warehouse_service.dart';
import 'package:rewild_bot_front/domain/services/wb_search_suggestion_service.dart';
import 'package:rewild_bot_front/domain/services/week_orders_service.dart';
import 'package:rewild_bot_front/main.dart';

import 'package:rewild_bot_front/presentation/adverts/advert_analitics_screen/advert_analitics_screen.dart';
import 'package:rewild_bot_front/presentation/adverts/advert_analitics_screen/advert_analitics_view_model.dart';
import 'package:rewild_bot_front/presentation/adverts/all_adverts_stat_screen/all_adverts_stat_screen.dart';
import 'package:rewild_bot_front/presentation/adverts/all_adverts_stat_screen/all_adverts_stat_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/adverts/all_adverts_words_screen/all_adverts_words_screen.dart';
import 'package:rewild_bot_front/presentation/adverts/all_adverts_words_screen/all_adverts_words_view_model.dart';
import 'package:rewild_bot_front/presentation/adverts/campaign_managment_screen/campaign_managment_screen.dart';
import 'package:rewild_bot_front/presentation/adverts/campaign_managment_screen/campaign_managment_view_model.dart';
import 'package:rewild_bot_front/presentation/adverts/single_auto_words_screen/single_auto_words_screen.dart';
import 'package:rewild_bot_front/presentation/adverts/single_auto_words_screen/single_auto_words_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/notification_feedback_screen/notification_feedback_screen.dart';
import 'package:rewild_bot_front/presentation/feedback/notification_feedback_screen/notification_feedback_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/single_question_screen/single_question_screen.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/single_question_screen/single_question_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/all_products_reviews_screen/all_products_reviews_screen.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/all_products_reviews_screen/all_products_reviews_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/all_reviews_screen/all_reviews_screen.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/all_reviews_screen/all_reviews_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/single_review_screen/single_review_screen.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/single_review_screen/single_review_view_model.dart';

import 'package:rewild_bot_front/presentation/home/add_api_keys_screen/add_api_keys_screen.dart';
import 'package:rewild_bot_front/presentation/home/add_api_keys_screen/add_api_keys_view_model.dart';

import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/all_cards_screen.dart';
import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/all_cards_seo_screen/all_cards_seo_screen.dart';
import 'package:rewild_bot_front/presentation/products/seo/all_cards_seo_screen/all_cards_seo_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/all_products_questions_screen/all_products_questions_screen.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/all_products_questions_screen/all_products_questions_view_model.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/all_questions_screen/all_questions_screen.dart';
import 'package:rewild_bot_front/presentation/feedback/questions/all_questions_screen/all_questions_view_model.dart';
import 'package:rewild_bot_front/presentation/app/app.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_autocomplite_keyword_screen/autocomplite_keyword_expansion_screen.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_autocomplite_keyword_screen/autocomplite_keyword_expansion_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_competitor_keyword_screen/competitor_keyword_expansion_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_competitor_keyword_screen/competitor_keyword_expansion_screen.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_subject_keyword_screen/subject_keyword_expansion_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_subject_keyword_screen/subject_keyword_expansion_screen.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_words_keyword_screen/words_keyword_expansion_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_words_keyword_screen/words_keyword_expansion_screen.dart';
import 'package:rewild_bot_front/presentation/products/cards/expense_manager_screen/expense_manager_screen.dart';
import 'package:rewild_bot_front/presentation/products/cards/expense_manager_screen/expense_manager_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/geo_search_screen/geo_search_screen.dart';
import 'package:rewild_bot_front/presentation/products/seo/geo_search_screen/geo_search_view_model.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_screen.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/notification_card_screen/notification_card_screen.dart';
import 'package:rewild_bot_front/presentation/products/cards/notification_card_screen/notification_card_view_model.dart';
import 'package:rewild_bot_front/presentation/payment/payment_screen/payment_screen.dart';
import 'package:rewild_bot_front/presentation/payment/payment_screen/payment_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/payment/payment_web_view/payment_web_view.dart';
import 'package:rewild_bot_front/presentation/payment/payment_web_view/payment_webview_model.dart';
import 'package:rewild_bot_front/presentation/home/report_screen/report_screen.dart';
import 'package:rewild_bot_front/presentation/home/report_screen/report_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_desc_generator_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_kw_research_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_screen.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_title_generator_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen/seo_tool_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen_category/seo_tool_category_desc_generator_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen_category/seo_tool_category_kw_research_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen_category/seo_tool_category_screen.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen_category/seo_tool_category_title_generator_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/seo_tool_screen_category/seo_tool_category_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/single_card_screen/single_card_screen.dart';
import 'package:rewild_bot_front/presentation/products/cards/single_card_screen/single_card_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/root_adverts_screen/root_adverts_screen.dart';
import 'package:rewild_bot_front/presentation/root_adverts_screen/root_adverts_screen_view_model.dart';

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

  AdvertApiClient _makeAdvertApiClient() => const AdvertApiClient();

  QuestionsApiClient _makeQuestionsApiClient() => const QuestionsApiClient();

  WbContentApiClient _makeWbContentApiClient() => const WbContentApiClient();

  WeekOrdersApiClient _makeWeekOrdersApiClient() => const WeekOrdersApiClient();

  OrdersHistoryApiClient _makeOrdersHistoryApiClient() =>
      const OrdersHistoryApiClient();

  SellerApiClient _makeSellerApiClient() => const SellerApiClient();

  ProductKeywordsApiClient _makeProductKeywordsApiClient() =>
      const ProductKeywordsApiClient();

  FilterApiClient _makeFilterApiClient() => const FilterApiClient();

  WBSearchSuggestionApiClient _makeWBSearchSuggestionApiClient() =>
      const WBSearchSuggestionApiClient();

  SearchQueryApiClient _makeSearchQueryApiClient() =>
      const SearchQueryApiClient();

  GeoSearchApiClient _makeGeoSearchApiClient() => const GeoSearchApiClient();

  StatisticsApiClient _makeStatisticsApiClient() => const StatisticsApiClient();
  ReviewApiClient _makeReviewApiClient() => const ReviewApiClient();

  AutoCampaignApiClient _makeAutoCampaignApiClient() =>
      const AutoCampaignApiClient();

  ProductWatchSubscriptionApiClient _makeProductWatchSubscriptionApiClient() =>
      const ProductWatchSubscriptionApiClient();

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

  // SubscriptionDataProvider _makeSubscriptionDataProvider() =>
  //     const SubscriptionDataProvider();

  // GroupDataProvider _makeGroupDataProvider() => const GroupDataProvider();

  SellerDataProvider _makeSellerDataProvider() => const SellerDataProvider();

  NotificationDataProvider _makeNotificationDataProvider() =>
      const NotificationDataProvider();

  TotalCostCalculatorDataProvider _makeTotalCostCalculatorDataProvider() =>
      const TotalCostCalculatorDataProvider();

  SubscriptionDataProvider _makeSubscriptionDataProvider() =>
      const SubscriptionDataProvider();
  NmIdDataProvider _makeNmIdDataProvider() => const NmIdDataProvider();

  WarehouseDataProvider _makeWarehouseDataProvider() =>
      const WarehouseDataProvider();

  GroupDataProvider _makeGroupDataProvider() => const GroupDataProvider();

  CommissionDataProvider _makeCommissionDataProvider() =>
      const CommissionDataProvider();

  OrdersHistoryDataProvider _makeOrdersHistoryDataProvider() =>
      const OrdersHistoryDataProvider();
  TrackingQueryDataProvider _makeTrackingQueryDataProvider() =>
      const TrackingQueryDataProvider();

  SeoKwByLemmaDataProvider _makeSeoKwByLemmaDataProvider() =>
      const SeoKwByLemmaDataProvider();

  AnswerDataProvider _makeAnswerDataProvider() => const AnswerDataProvider();

  KeywordDataProvider _makeKeywordsDataProvider() =>
      const KeywordDataProvider();

  SubscribedCardsDataProvider _makeSubscribedCardsDataProvider() =>
      const SubscribedCardsDataProvider();
  // Services ==================================================================
  FilterValuesService _makeFilterValuesService() => FilterValuesService(
      lemmaDataProvider: _makeLemmaDataProvider(),
      cachedKwByWordDataProvider: _makeCachedKwByWordDataProvider(),
      kwByLemmaDataProvider: _makeCachedKwByLemmaDataProvider(),
      filterDataProvider: _makeFilterValuesDataProvider(),
      filterApiClient: _makeFilterApiClient());
  AuthService _makeAuthService() => AuthService(
      secureDataProvider: _makeSecureDataProvider(),
      authApiClient: _makeAuthApiClient());
  UpdateService _makeUpdateService() => UpdateService(
        lemmaDataProvider: _makeLemmaDataProvider(),
        notificationDataProvider: _makeNotificationDataProvider(),
        trackingResultDataProvider: _makeTrackingResultDataProvider(),
        totalCostdataProvider: _makeTotalCostCalculatorDataProvider(),
        averageLogisticsDataProvider: _makeAverageLogisticsDataProvider(),
        supplyDataProvider: _makeSupplyDataProvider(),
        tariffDataProvider: _makeTariffDataProvider(),
        cardOfProductDataProvider: _makeCardOfProductDataProvider(),
        initialStockModelDataProvider: _makeInitialStockDataProvider(),
        stockDataProvider: _makeStockDataProvider(),
        weekOrdersDataProvider: _makeOrderDataProvider(),
        cardKeywordsDataProvider: _makeCardKeywordsDataProvider(),
        cachedKwByAutocompliteDataProvider:
            _makeCachedKwByAutocompliteDataProvider(),
        cachedKwByLemmaDataProvider: _makeCachedKwByLemmaDataProvider(),
        cachedKwByLemmaByWordDataProvider: _makeCachedKwByWordDataProvider(),
        lastUpdateDayDataProvider: _makeLastUpdateDayDataProvider(),
        tariffApiClient: _makeCommissionApiClient(),
        detailsApiClient: _makeDetailsApiClient(),
        averageLogisticsApiClient: _makePriceApiClient(),
        initialStockModelApiClient: _makeStocksApiClient(),
        cardOfProductApiClient: _makeCardOfProductApiClient(),
      );

  ApiKeysService _makeApiKeysService() => ApiKeysService(
        apiKeysDataProvider: _makeSecureDataProvider(),
        activeSellerDataProvider: _makeUserSellersDataProvider(),
        apiKeyExistsStreamController: apiKeyExistsStreamController,
      );
  AdvertService _makeAdvertService() => AdvertService(
      advertApiClient: _makeAdvertApiClient(),
      activeSellersDataProvider: _makeUserSellersDataProvider(),
      apiKeysDataProvider: _makeSecureDataProvider(),
      updatedAdvertStreamController: updatedAdvertStreamController);

  SubscriptionService _makeSubscriptionService() => SubscriptionService(
        cardsDataProvider: _makeSubscribedCardsDataProvider(),
        apiClient: _makeSubscriptionApiClient(),
        cardsApiClient: _makeCardOfProductApiClient(),
        cardsNumberStreamController: subscriptionStreamController,
        subsDataProvider: _makeSubscriptionDataProvider(),
      );

  AllCardsFilterService _makeAllCardsFilterService() => AllCardsFilterService(
        cardsOfProductsDataProvider: _makeCardOfProductDataProvider(),
        filterDataProvider: _makeFilterDataProvider(),
        sellerDataProvider: _makeSellerDataProvider(),
      );

  SupplyService _makeSupplyService() => SupplyService(
        supplyDataProvider: _makeSupplyDataProvider(),
      );

  GroupService _makeAllGroupsService() => GroupService(
        groupDataProvider: _makeGroupDataProvider(),
      );
  // AllCardsFilterService _makeAllCardsFilterService() => AllCardsFilterService(
  //       cardsOfProductsDataProvider: _makeCardOfProductDataProvider(),
  //       filterDataProvider: _makeFilterDataProvider(),
  //       sellerDataProvider: _makeSellerDataProvider(),
  //     );

  NotificationService _makeNotificationService() => NotificationService(
      notificationDataProvider: _makeNotificationDataProvider(),
      secureDataProvider: _makeSecureDataProvider(),
      productWatchSubscriptionApiClient:
          _makeProductWatchSubscriptionApiClient(),
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
      // cardOfProductApiClient: _makeCardOfProductApiClient(),
      cardOfProductDataProvider: _makeCardOfProductDataProvider(),
      initStockDataProvider: _makeInitialStockDataProvider(),
      stockDataprovider: _makeStockDataProvider(),
      supplyDataProvider: _makeSupplyDataProvider(),
      warehouseApiClient: _makeWarehouseApiClient(),
      nmIdDataProvider: _makeNmIdDataProvider(),
      warehouseDataprovider: _makeWarehouseDataProvider());

  PriceService _makePriceService() => PriceService(
        apiClient: _makePriceApiClient(),
      );

  BalanceService _makeBalanceService() =>
      BalanceService(balanceDataProvider: _makeSecureDataProvider());

  ContentService _makeContentService() => ContentService(
      activeSellerDataProvider: _makeUserSellersDataProvider(),
      apiKeyDataProvider: _makeSecureDataProvider(),
      nmIdDataProvider: _makeNmIdDataProvider(),
      wbContentApiClient: _makeWbContentApiClient());

  StockService _makeStockService() => StockService(
        stocksDataProvider: _makeStockDataProvider(),
      );

  OrdersHistoryService _makeOrdersHistoryService() => OrdersHistoryService(
        ordersHistoryApiClient: _makeOrdersHistoryApiClient(),
        ordersHistoryDataProvider: _makeOrdersHistoryDataProvider(),
      );

  WeekOrdersService _makeWeekOrdersService() => WeekOrdersService(
        ordersDataProvider: _makeOrderDataProvider(),
        ordersApiClient: _makeWeekOrdersApiClient(),
      );

  CommissionService _makeCommissionService() => CommissionService(
        commissionApiClient: _makeCommissionApiClient(),
        commissionDataProvider: _makeCommissionDataProvider(),
      );

  SellerService _makeSellerService() => SellerService(
        sellerApiClient: _makeSellerApiClient(),
        sellerDataProvider: _makeSellerDataProvider(),
      );

  InitialStockService _makeInitialStockService() => InitialStockService(
        initStockDataProvider: _makeInitialStockDataProvider(),
      );

  WarehouseService _makeWarehouseService() => WarehouseService(
        warehouseApiClient: _makeWarehouseApiClient(),
        warehouseProvider: _makeWarehouseDataProvider(),
      );

  CardKeywordsService _makeProductKeywordsService() => CardKeywordsService(
        apiClient: _makeProductKeywordsApiClient(),
        cardKeywordsDataProvider: _makeCardKeywordsDataProvider(),
      );

  WBSearchSuggestionService _makeWBSearchSuggestionService() =>
      WBSearchSuggestionService(
          apiClient: _makeWBSearchSuggestionApiClient(),
          kwByAutocompliteDataProvider:
              _makeCachedKwByAutocompliteDataProvider(),
          searchQueryApiClient: _makeSearchQueryApiClient());

  GeoSearchService _makeGeoSearchService() => GeoSearchService(
        geoSearchApiClient: _makeGeoSearchApiClient(),
      );
  TrackingService _makeTrackingService() => TrackingService(
        geoSearchApiClient: _makeGeoSearchApiClient(),
        queryDataProvider: _makeTrackingQueryDataProvider(),
        subscriptionsDataProvider: _makeSubscriptionDataProvider(),
        trackingDataProvider: _makeTrackingResultDataProvider(),
      );
  SeoService _makeSeoService() => SeoService(
        seoServiceSeoKwByLemmaDataProvider: _makeSeoKwByLemmaDataProvider(),
      );

  RealizationReportService _makeRealizationReportService() =>
      RealizationReportService(
        activeSellerDataProvider: _makeUserSellersDataProvider(),
        apiKeyDataProvider: _makeSecureDataProvider(),
        statisticsApiClient: _makeStatisticsApiClient(),
      );

  QuestionService _makeQuestionService() => QuestionService(
        activeSellerDataProvider: _makeUserSellersDataProvider(),
        apiKeysDataProvider: _makeSecureDataProvider(),
        questionApiClient: _makeQuestionsApiClient(),
      );

  UnansweredFeedbackQtyService _makeUnansweredFeedbackQtyService() =>
      UnansweredFeedbackQtyService(
          reviewsApiClient: _makeReviewApiClient(),
          questionsApiClient: _makeQuestionsApiClient());
  AnswerService _makeAnswerService() => AnswerService(
        answerDataProvider: _makeAnswerDataProvider(),
      );

  ReviewService _makeReviewService() => ReviewService(
        activeSellerDataProvider: _makeUserSellersDataProvider(),
        apiKeysDataProvider: _makeSecureDataProvider(),
        reviewApiClient: _makeReviewApiClient(),
      );
  // Keyword
  KeywordsService _makeKeywordsService() => KeywordsService(
        advertApiClient: _makeAdvertApiClient(),
        apiKeysDataProvider: _makeSecureDataProvider(),
        geoSearchApiClient: _makeGeoSearchApiClient(),
        activeSellerDataProvider: _makeUserSellersDataProvider(),
        autoAdvertApiClient: _makeAutoCampaignApiClient(),
        keywordsDataProvider: _makeKeywordsDataProvider(),
      );
  AdvertsAnaliticsService _makeAdvertsAnaliticsService() =>
      AdvertsAnaliticsService(
        activeSellerDataProvider: _makeUserSellersDataProvider(),
        apiClient: _makeAdvertApiClient(),
        apiKeyDataProvider: _makeSecureDataProvider(),
      );
  // View Models ===============================================================
  MainNavigationViewModel _makeBottomNavigationViewModel(
          BuildContext context) =>
      MainNavigationViewModel(
          context: context,
          advertService: _makeAdvertService(),
          updatedAdvertStream: updatedAdvertStream,
          cardsNumberStream: cardsNumberStream,
          apiKeyExistsStream: apiKeyExistsStream,
          updateService: _makeUpdateService(),
          subscriptionService: _makeSubscriptionService(),
          tokenProvider: _makeAuthService(),
          questionService: _makeQuestionService(),
          cardService: _makeCardOfProductService());
  AddApiKeysScreenViewModel _makeApiKeysScreenViewModel(BuildContext context) =>
      AddApiKeysScreenViewModel(
          context: context,
          apiKeysService: _makeApiKeysService(),
          contentService: _makeContentService(),
          updateService: _makeUpdateService(),
          cardOfProductService: _makeCardOfProductService(),
          authService: _makeAuthService());

  AllCardsScreenViewModel _makeAllCardsScreenViewModel(context) =>
      AllCardsScreenViewModel(
          context: context,
          updateService: _makeUpdateService(),
          subscriptionsService: _makeSubscriptionService(),
          supplyService: _makeSupplyService(),
          streamNotification: updatedNotificationStream,
          groupsProvider: _makeAllGroupsService(),
          filterService: _makeAllCardsFilterService(),
          notificationsService: _makeNotificationService(),
          totalCostService: _makeTotalCostService(),
          averageLogisticsService: _makeTariffService(),
          cardsOfProductsService: _makeCardOfProductService(),
          tokenService: _makeAuthService());

  PaymentScreenViewModel _makePaymentScreenViewModel(
    BuildContext context,
  ) =>
      PaymentScreenViewModel(
        context: context,
        subService: _makeSubscriptionService(),
        tokenService: _makeAuthService(),
        paymentStoreService: _makePriceService(),
      );

  PaymentWebViewModel _makePaymentWebViewModel(
    BuildContext context,
  ) =>
      PaymentWebViewModel(
        context: context,
        subService: _makeSubscriptionService(),
        tokenService: _makeAuthService(),
        // updateService: _makeUpdateService(),
        balanceService: _makeBalanceService(),
      );
  // WbWebViewScreenViewModel _makeWbWebViewScreenViewModel(context) =>
  //     WbWebViewScreenViewModel(
  //         context: context,
  //         updateService: _makeUpdateService(),
  //         tokenProvider: _makeAuthService());

  AllCardsSeoViewModel _makeAllCardsSeoViewModel(context) =>
      AllCardsSeoViewModel(
        context: context,
        cardOfProductService: _makeCardOfProductService(),
        contentService: _makeContentService(),
        authService: _makeAuthService(),
        updateService: _makeUpdateService(),
      );
  CardNotificationViewModel _makeCardNotificationSettingsViewModel(
          BuildContext context, NotificationCardState state) =>
      CardNotificationViewModel(state,
          tokenService: _makeAuthService(),
          notificationService: _makeNotificationService(),
          context: context);

  SingleCardScreenViewModel _makeSingleCardViewModel(
          BuildContext context, int id) =>
      SingleCardScreenViewModel(
          context: context,
          stockService: _makeStockService(),
          id: id,
          ordersHistoryService: _makeOrdersHistoryService(),
          weekOrdersService: _makeWeekOrdersService(),
          tariffService: _makeTariffService(),
          // subscriptionsService: _makeSubscriptionService(),
          tokenProvider: _makeAuthService(),
          commissionService: _makeCommissionService(),
          sellerService: _makeSellerService(),
          notificationService: _makeNotificationService(),
          cardOfProductService: _makeCardOfProductService(),
          supplyService: _makeSupplyService(),
          priceService: _makePriceService(),
          initialStocksService: _makeInitialStockService(),
          streamNotification: updatedNotificationStream,
          warehouseService: _makeWarehouseService());

  CompetitorKeywordExpansionViewModel _makeCompetitorKwExpansionViewModel(
      BuildContext context) {
    return CompetitorKeywordExpansionViewModel(
      context: context,
      tokenService: _makeAuthService(),
      keywordsService: _makeProductKeywordsService(),
      cardsService: _makeCardOfProductService(),
    );
  }

  SubjectKeywordExpansionViewModel _makeSubjectKeywordExpansionViewModel(
      BuildContext context, int subjectId, List<KwByLemma> addedPhrases) {
    return SubjectKeywordExpansionViewModel(
      context: context,
      subjectId: subjectId,
      addedPhrases: addedPhrases,
      seoCoreFilterValuesService: _makeFilterValuesService(),
      seoCoreTokenService: _makeAuthService(),
    );
  }

  WordsKeywordExpansionViewModel _makeWordsKeywordExpansionViewModel(
      BuildContext context, List<KwByLemma> addedPhrases) {
    return WordsKeywordExpansionViewModel(
      context: context,
      filterValuesService: _makeFilterValuesService(),
      seoCoreTokenService: _makeAuthService(),
      addedPhrases: addedPhrases,
    );
  }

  AutocompliteKeywordExpansionViewModel _makeAutocompliteKwExpansionViewModel(
      BuildContext context, List<KwByLemma> addedKeywords) {
    return AutocompliteKeywordExpansionViewModel(
      alreadyAddedPhrases: addedKeywords,
      context: context,
      tokenService: _makeAuthService(),
      suggestionService: _makeWBSearchSuggestionService(),
    );
  }

  GeoSearchViewModel _makeGeoSearchViewModel(
    BuildContext context,
  ) =>
      GeoSearchViewModel(
          context: context,
          cardOfProductService: _makeCardOfProductService(),
          geoSearchService: _makeGeoSearchService());

  SeoToolViewModel _makeSeoToolViewModel(
      BuildContext context, int productId, String imageUrl, CardItem cardItem) {
    return SeoToolViewModel(
        context: context,
        imageUrl: imageUrl,
        productId: productId,
        cardItem: cardItem,
        tokenService: _makeAuthService(),
        contentService: _makeContentService());
  }

  SeoToolKwResearchViewModel _makeSeoToolKwResearchViewModel(
      BuildContext context, int productId, int subjectId) {
    return SeoToolKwResearchViewModel(
        context: context,
        productId: productId,
        subjectId: subjectId,
        tokenService: _makeAuthService(),
        trackingService: _makeTrackingService(),
        seoService: _makeSeoService());
  }

  SeoToolTitleGeneratorViewModel _makeSeoToolTitleGeneratorViewModel(
    BuildContext context,
  ) {
    return SeoToolTitleGeneratorViewModel(
      context: context,
      balanceService: _makeBalanceService(),
      priceService: _makePriceService(),
      tokenService: _makeAuthService(),
      contentService: _makeContentService(),
    );
  }

  SeoToolDescriptionGeneratorViewModel
      _makeSeoToolDescriptionGeneratorViewModel(
    BuildContext context,
  ) {
    return SeoToolDescriptionGeneratorViewModel(
      context: context,
      balanceService: _makeBalanceService(),
      priceService: _makePriceService(),
      tokenService: _makeAuthService(),
      contentService: _makeContentService(),
      // promptService: _makePromptService(),
      // gigachatService: _makeGigachatService(),
    );
  }

  SeoToolCategoryViewModel _makeSeoToolCategoryViewModel(
    BuildContext context,
  ) {
    return SeoToolCategoryViewModel(
      context: context,
      tokenService: _makeAuthService(),
    );
  }

  SeoToolCategoryKwResearchViewModel _makeSeoToolCategoryKwResearchViewModel(
      BuildContext context, int subjectId) {
    return SeoToolCategoryKwResearchViewModel(
        context: context,
        subjectId: subjectId,
        tokenService: _makeAuthService(),
        seoService: _makeSeoService());
  }

  SeoToolCategoryTitleGeneratorViewModel
      _makeSeoToolCategoryTitleGeneratorViewModel(
    BuildContext context,
  ) {
    return SeoToolCategoryTitleGeneratorViewModel(
      context: context,
      balanceService: _makeBalanceService(),
      priceService: _makePriceService(),
      tokenService: _makeAuthService(),
    );
  }

  SeoToolCategoryDescriptionGeneratorViewModel
      _makeSeoToolCategoryDescriptionGeneratorViewModel(
    BuildContext context,
  ) {
    return SeoToolCategoryDescriptionGeneratorViewModel(
      context: context,
      balanceService: _makeBalanceService(),
      priceService: _makePriceService(),
      tokenService: _makeAuthService(),
    );
  }

  ExpenseManagerViewModel _makeExpenseManagerViewModel(
          BuildContext context, (int, int, double) nmIdPlusAverageLogistics) =>
      ExpenseManagerViewModel(
          nmIdPlusAverageLogisticsCom: nmIdPlusAverageLogistics,
          context: context,
          averageLogisticsService: _makeTariffService(),
          tokenService: _makeAuthService(),
          cardOfProductService: _makeCardOfProductService(),
          totalCostService: _makeTotalCostService());

  ReportViewModel _makeRealizationReportViewModel(BuildContext context) =>
      ReportViewModel(
        context: context,
        cardOfProductService: _makeCardOfProductService(),
        totalCostService: _makeTotalCostService(),
        advertService: _makeAdvertService(),
        realizationReportService: _makeRealizationReportService(),
      );

  AllProductsQuestionsViewModel _makeAllProductsQuestionsViewModel(
          BuildContext context) =>
      AllProductsQuestionsViewModel(
          context: context,
          unansweredFeedbackQtyService: _makeUnansweredFeedbackQtyService(),
          cardOfProductService: _makeCardOfProductService(),
          questionService: _makeQuestionService());

  AllQuestionsViewModel _makeAllQuestionsViewModel(
          BuildContext context, int nmId) =>
      AllQuestionsViewModel(nmId,
          context: context,
          answerService: _makeAnswerService(),
          questionService: _makeQuestionService());
  SingleQuestionViewModel _makeSingleQuestionViewModel(
          BuildContext context, QuestionModel question) =>
      SingleQuestionViewModel(
        question,
        context: context,
        answerService: _makeAnswerService(),
        questionService: _makeQuestionService(),
        cardOfProductService: _makeCardOfProductService(),
        balanceService: _makeBalanceService(),
        priceService: _makePriceService(),
      );

  AllProductsReviewsViewModel _makeAllProductsReviewsViewModel(
          BuildContext context) =>
      AllProductsReviewsViewModel(
          context: context,
          cardOfProductService: _makeCardOfProductService(),
          reviewService: _makeReviewService(),
          unansweredFeedbackQtyService: _makeUnansweredFeedbackQtyService());

  AllReviewsViewModel _makeAllReviewsViewModel(
          BuildContext context, int nmId) =>
      AllReviewsViewModel(nmId,
          context: context,
          reviewService: _makeReviewService(),
          answerService: _makeAnswerService());

  SingleReviewViewModel _makeSingleReviewViewModel(
          BuildContext context, ReviewModel? review) =>
      SingleReviewViewModel(
        review,
        context: context,
        answerService: _makeAnswerService(),
        priceService: _makePriceService(),
        tokenService: _makeAuthService(),
        singleReviewCardOfProductService: _makeCardOfProductService(),
        balanceService: _makeBalanceService(),
        reviewService: _makeReviewService(),
      );

  NotificationFeedbackViewModel _makeFeedbackNotificationViewModel(
    BuildContext context,
  ) =>
      NotificationFeedbackViewModel(
        notificationService: _makeNotificationService(),
        tokenService: _makeAuthService(),
        context: context,
      );

  CampaignManagementViewModel _makeCampaignManagementViewModel(
          BuildContext context, int campaignId) =>
      CampaignManagementViewModel(
        campaignId: campaignId,
        authService: _makeAuthService(),
        advertService: _makeAdvertService(),
        notificationService: _makeNotificationService(),
        context: context,
      );
  AllAdvertsWordsViewModel _makeAdvertsToolsViewModel(BuildContext context) =>
      AllAdvertsWordsViewModel(
          context: context,
          cardOfProductService: _makeCardOfProductService(),
          advertService: _makeAdvertService());

  SingleAutoWordsViewModel _makeAutoStatWordsViewModel(
          BuildContext context, (int, int?, String) campaignIdGnum) =>
      SingleAutoWordsViewModel(campaignIdGnum,
          context: context,
          advertService: _makeAdvertService(),
          cardOfProductService: _makeCardOfProductService(),
          keywordService: _makeKeywordsService());

  AllAdvertsStatScreenViewModel _makeAllAdvertsScreenViewModel(
          BuildContext context) =>
      AllAdvertsStatScreenViewModel(
        context: context,
        cardOfProductService: _makeCardOfProductService(),
        updatedAdvertStream: updatedAdvertStream,
        advertService: _makeAdvertService(),
      );

  AdvertAnaliticsViewModel _makeAdvertAnaliticsViewModel(
          BuildContext context, (int, DateTime, String) campaignInfo) =>
      AdvertAnaliticsViewModel(
        campaignInfo: campaignInfo,
        context: context,
        cardOfProductService: _makeCardOfProductService(),
        authService: _makeAuthService(),
        tariffService: _makeTariffService(),
        totalCostService: _makeTotalCostService(),
        advAnaliticsService: _makeAdvertsAnaliticsService(),
      );

  RootAdvertsScreenViewModel _makeRootAdvertsScreenViewModel(
          BuildContext context) =>
      RootAdvertsScreenViewModel(
          context: context,
          advertService: _makeAdvertService(),
          apiKeyExistsStream: apiKeyExistsStream,
          updatedAdvertStream: updatedAdvertStream);

  // AddCardOptionViewModel _makeAddCardOptionViewModel(BuildContext context) =>
  //     AddCardOptionViewModel(context: context);
}

class ScreenFactoryDefault implements ScreenFactory {
  final _DIContainer _diContainer;

  // ignore: library_private_types_in_public_api
  const ScreenFactoryDefault(this._diContainer);

  @override
  Widget makeSeoToolScreen(
      (CardOfProductModel, CardItem)? cardOfProductCardItem) {
    if (cardOfProductCardItem == null ||
        cardOfProductCardItem.$1.subjectId == null) {
      return const SeoToolScreen();
    }
    final nmId = cardOfProductCardItem.$1.nmId;
    final subjectId = cardOfProductCardItem.$1.subjectId;
    final img = cardOfProductCardItem.$1.img;
    final cardItem = cardOfProductCardItem.$2;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SeoToolViewModel>(
          create: (context) =>
              _diContainer._makeSeoToolViewModel(context, nmId, img, cardItem),
        ),
        ChangeNotifierProvider<SeoToolKwResearchViewModel>(
            create: (context) => _diContainer._makeSeoToolKwResearchViewModel(
                  context,
                  nmId,
                  subjectId!,
                )),
        ChangeNotifierProvider<SeoToolTitleGeneratorViewModel>(
            create: (context) =>
                _diContainer._makeSeoToolTitleGeneratorViewModel(
                  context,
                )),
        ChangeNotifierProvider<SeoToolDescriptionGeneratorViewModel>(
            create: (context) =>
                _diContainer._makeSeoToolDescriptionGeneratorViewModel(
                  context,
                )),
      ],
      // create: (context) =>
      //     _diContainer._makeSeoToolViewModel(context, productId),
      child: const SeoToolScreen(),
    );
  }

  @override
  Widget makeSeoToolCategoryScreen({required int subjectId}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SeoToolCategoryViewModel>(
          create: (context) => _diContainer._makeSeoToolCategoryViewModel(
            context,
          ),
        ),
        ChangeNotifierProvider<SeoToolCategoryKwResearchViewModel>(
            create: (context) =>
                _diContainer._makeSeoToolCategoryKwResearchViewModel(
                  context,
                  subjectId,
                )),
        ChangeNotifierProvider<SeoToolCategoryTitleGeneratorViewModel>(
            create: (context) =>
                _diContainer._makeSeoToolCategoryTitleGeneratorViewModel(
                  context,
                )),
        ChangeNotifierProvider<SeoToolCategoryDescriptionGeneratorViewModel>(
            create: (context) =>
                _diContainer._makeSeoToolCategoryDescriptionGeneratorViewModel(
                  context,
                )),
      ],
      // create: (context) =>
      //     _diContainer._makeSeoToolViewModel(context, productId),
      child: const SeoToolCategoryScreen(),
    );
  }

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
  Widget makeSingleQuestionScreen(QuestionModel question) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeSingleQuestionViewModel(context, question),
      child: const SingleQuestionScreen(),
    );
  }

  @override
  Widget makePaymentWebView(PaymentInfo paymentInfo) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makePaymentWebViewModel(
        context,
      ),
      child: PaymentWebView(
        paymentInfo: paymentInfo,
      ),
    );
  }

  @override
  Widget makeAllProductsReviewsScreen() {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAllProductsReviewsViewModel(context),
      child: const AllProductsReviewsScreen(),
    );
  }

  @override
  Widget makePaymentScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makePaymentScreenViewModel(context),
      child: const PaymentScreen(),
    );
  }

  // @override
  // Widget makeWbWebViewSceen((List<int>, String?) nmIdsSearchString) {
  //   return ChangeNotifierProvider(
  //     create: (context) => _diContainer._makeWbWebViewScreenViewModel(context),
  //     child: WbWebViewScreen(
  //         nmIds: nmIdsSearchString.$1, searchString: nmIdsSearchString.$2),
  //   );
  // }

  @override
  Widget makeAllCardsSeoScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeAllCardsSeoViewModel(context),
      child: const AllCardsSeoScreen(),
    );
  }

  @override
  Widget makeCardNotificationsSettingsScreen(NotificationCardState state) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeCardNotificationSettingsViewModel(context, state),
      child: const NotificationCardSettingsScreen(),
    );
  }

  @override
  Widget makeAllReviewsScreen(int nmId) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeAllReviewsViewModel(context, nmId),
      child: const AllReviewsScreen(),
    );
  }

  @override
  Widget makeSingleCardScreen(int id) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSingleCardViewModel(context, id),
      child: const SingleCardScreen(),
    );
  }

  @override
  Widget makeCompetitorKwExpansionScreen() {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeCompetitorKwExpansionViewModel(context),
      child: const CompetitorKeywordExpansionScreen(),
    );
  }

  @override
  Widget makeSubjectKeywordExpansionScreen(
      {required List<KwByLemma> addedKeywords, required int subjectId}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSubjectKeywordExpansionViewModel(
          context, subjectId, addedKeywords),
      child: const SubjectKeywordExpansionScreen(),
    );
  }

  @override
  Widget makeWordsKeywordExpansionScreen(
      {required List<KwByLemma> addedKeywords}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeWordsKeywordExpansionViewModel(
          context, addedKeywords),
      child: const WordsKeywordExpansionScreen(),
    );
  }

  @override
  Widget makeAllAdvertsScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeAllAdvertsScreenViewModel(context),
      child: const AllAdvertsStatScreen(),
    );
  }

  @override
  Widget makeAutocompliteKwExpansionScreen({
    required List<KwByLemma> addedKeywords,
  }) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeAutocompliteKwExpansionViewModel(
          context, addedKeywords),
      child: const AutocompliteKwExpansionScreen(),
    );
  }

  @override
  Widget makeGeoSearchScreen(String? initQuery) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeGeoSearchViewModel(context),
      child: GeoSearchScreen(
        initQuery: initQuery,
      ),
    );
  }

  @override
  Widget makeExpenseManagerScreen((int, int, double) nmIdPlusAvgLLog) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeExpenseManagerViewModel(context, nmIdPlusAvgLLog),
      child: const ExpenseManagerScreen(),
    );
  }

  @override
  Widget makeRealizationReportScreen() {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeRealizationReportViewModel(context),
      child: const ReportScreen(),
    );
  }

  @override
  Widget makeAllProductsQuestionsScreen() {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAllProductsQuestionsViewModel(context),
      child: const AllProductsQuestionsScreen(),
    );
  }

  @override
  Widget makeAllQuestionsScreen(int nmId) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAllQuestionsViewModel(context, nmId),
      child: const AllQuestionsScreen(),
    );
  }

  @override
  Widget makeSingleReviewScreen(ReviewModel? review) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeSingleReviewViewModel(context, review),
      child: const SingleReviewScreen(),
    );
  }

  @override
  Widget makeFeedbackNotificationSettingsScreen() {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeFeedbackNotificationViewModel(context),
      child: const NotificationFeedbackSettingsScreen(),
    );
  }

  @override
  Widget makeCampaignManagementScreen(int campaignId) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeCampaignManagementViewModel(context, campaignId),
      child: const CampaignManagementScreen(),
    );
  }

  @override
  Widget makeAdvertsToolsScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeAdvertsToolsViewModel(context),
      child: const AllAdvertsWordsScreen(),
    );
  }

  @override
  Widget makeAutoStatsWordsScreen((int, int?, String) idGnum) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAutoStatWordsViewModel(context, idGnum),
      child: const SingleAutoWordsScreen(),
    );
  }

  @override
  Widget makeAdvertAnaliticsScreen((int, DateTime, String) campaignInfo) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeAdvertAnaliticsViewModel(context, campaignInfo),
      child: const AdvertAnaliticsScreen(),
    );
  }

  @override
  Widget makeRootAdvertsScreen() {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeRootAdvertsScreenViewModel(context),
      child: const RootAdvertsScreen(),
    );
  }

  // @override
  // Widget makeAddCardOptionScreen() {
  //   return ChangeNotifierProvider(
  //     create: (context) => _diContainer._makeAddCardOptionViewModel(context),
  //     child: const AddCardOptionScreen(),
  //   );
  // }
}
