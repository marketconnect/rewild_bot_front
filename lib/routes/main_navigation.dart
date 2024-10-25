import 'package:flutter/material.dart';
import 'package:rewild_bot_front/domain/entities/card_catalog.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';

import 'package:rewild_bot_front/domain/entities/question_model.dart';
import 'package:rewild_bot_front/domain/entities/review_model.dart';

import 'package:rewild_bot_front/presentation/app/app.dart';
import 'package:rewild_bot_front/presentation/products/cards/notification_card_screen/notification_card_view_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

abstract class ScreenFactory {
  Widget makeMainNavigationScreen();
  Widget makeApiKeysScreen();
  Widget makeAllCardsScreen();

  Widget makePaymentScreen(String chatId);
  // Widget makePaymentWebView(PaymentInfo paymentInfo);
  Widget makeSingleCardScreen(int id, bool fromBot);
  Widget makeCardNotificationsSettingsScreen(NotificationCardState state);

  Widget makeAllCardsSeoScreen();

  Widget makeCompetitorKwExpansionScreen(int? subjectId);

  Widget makeSubjectKeywordExpansionScreen(
      {required List<KwByLemma> addedKeywords, required int subjectId});
  Widget makeWordsKeywordExpansionScreen(
      {required List<KwByLemma> addedKeywords});

  Widget makeAutocompliteKwExpansionScreen(
      {required List<KwByLemma> addedKeywords});
// new

  Widget makeGeoSearchScreen(String? initQuery);

  Widget makeSeoToolScreen(
      (CardOfProductModel, CardItem)? cardOfProductCardItem);

  Widget makeSeoToolCategoryScreen({required int subjectId});

  Widget makeExpenseManagerScreen((int, int, double) nmIdPlusAverageLogistics);

  Widget makeRealizationReportScreen();

  Widget makeAllProductsQuestionsScreen();

  Widget makeAllQuestionsScreen(int nmId);

  Widget makeSingleQuestionScreen(QuestionModel question);

  Widget makeAllProductsReviewsScreen();

  Widget makeAllReviewsScreen(int nmId);

  Widget makeSingleReviewScreen(ReviewModel? review);

  // Widget makeFeedbackNotificationSettingsScreen();

  Widget makeCampaignManagementScreen(int campaignId);

  Widget makeAdvertsToolsScreen();

  Widget makeAutoStatsWordsScreen((int, int?, String) value);

  Widget makeAllAdvertsScreen();

  Widget makeAdvertAnaliticsScreen((int, DateTime, String) campaignInfo);

  Widget makeRootAdvertsScreen();

  Widget makeChatGptScreen(String questionText);

  Widget makeAddGroupsScreen(List<int> cardsIds);
  Widget makeAllCategoriesScreen();
  Widget makeAllSubjectsScreen(List<String> catNames);
  Widget makeFeedbackFormScreen();
  Widget makeUnitEconomicsAllCardsScreen();
  Widget makeFinanceNavScreen();
  Widget makeTopProductsScreen(int subjectId, String subjectName);

  Widget makeWhCoefficientsScreen();
}

class MainNavigation implements AppNavigation {
  final ScreenFactory screenFactory;

  const MainNavigation(this.screenFactory);

  @override
  Route<Object> onGenerateRoute(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '') ?? Uri();

    if (uri.path == MainNavigationRouteNames.singleCardScreen) {
      // from url
      final cardIdParam = uri.queryParameters['cardId'];
      int cardId = cardIdParam != null ? int.tryParse(cardIdParam) ?? 0 : 0;
      // if called from bot
      bool fromBot = true;
      // from arguments
      if (cardId == 0) {
        fromBot = false;
        final arguments = settings.arguments;
        cardId = arguments is int ? arguments : 0;
      }

      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            screenFactory.makeSingleCardScreen(cardId, fromBot),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        settings: settings,
      );
    }

    if (uri.path == MainNavigationRouteNames.paymentScreen) {
      // from url
      final chatIdParam = uri.queryParameters['chatId'];
      String chatId = chatIdParam ?? "";

      // from arguments
      if (chatId.isEmpty) {
        final arguments = settings.arguments;
        chatId = arguments is String ? arguments : "";
      }

      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            screenFactory.makePaymentScreen(chatId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        settings: settings,
      );
    }

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => screenFactory.makeMainNavigationScreen());

      case MainNavigationRouteNames.whCofficientsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeWhCoefficientsScreen(),
        );

      case MainNavigationRouteNames.financeNavScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeFinanceNavScreen(),
        );

      case MainNavigationRouteNames.unitEconomicsAllCardsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeUnitEconomicsAllCardsScreen(),
        );

      case MainNavigationRouteNames.allCategoriesScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllCategoriesScreen(),
        );

      case MainNavigationRouteNames.allSubjectsScreen:
        final arguments = settings.arguments;
        final args = arguments is List<String> ? arguments : <String>[];
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllSubjectsScreen(args),
        );

      case MainNavigationRouteNames.apiKeysScreen:
        return MaterialPageRoute(
            builder: (_) => screenFactory.makeApiKeysScreen());

      case MainNavigationRouteNames.topProductsScreen:
        final arguments = settings.arguments;
        final subjectIdName = arguments is (int, String) ? arguments : (0, '');
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeTopProductsScreen(
              subjectIdName.$1, subjectIdName.$2),
        );

      case MainNavigationRouteNames.allCardsScreen:
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                screenFactory.makeAllCardsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            settings: settings);

      // case MainNavigationRouteNames.paymentWebView:
      //   final arguments = settings.arguments;
      //   final args = arguments is PaymentInfo ? arguments : PaymentInfo.empty();

      //   return MaterialPageRoute(
      //     builder: (_) => screenFactory.makePaymentWebView(args),
      //   );

      case MainNavigationRouteNames.cardNotificationsSettingsScreen:
        final arguments = settings.arguments;
        final state = arguments is NotificationCardState
            ? arguments
            : NotificationCardState.empty();

        return MaterialPageRoute(
          builder: (_) =>
              screenFactory.makeCardNotificationsSettingsScreen(state),
        );
      case MainNavigationRouteNames.allCardsSeoScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllCardsSeoScreen(),
        );
      case MainNavigationRouteNames.competitorKwExpansionScreen:
        final arguments = settings.arguments;
        final subjectId = arguments is int ? arguments : null;
        return MaterialPageRoute(
          builder: (_) =>
              screenFactory.makeCompetitorKwExpansionScreen(subjectId),
        );

      case MainNavigationRouteNames.allProductsQuestionsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllProductsQuestionsScreen(),
        );
      case MainNavigationRouteNames.campaignManagementScreen:
        final arguments = settings.arguments;
        final campaignId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: (_) =>
              screenFactory.makeCampaignManagementScreen(campaignId),
        );

      case MainNavigationRouteNames.subjectKeywordExpansionScreen:
        final arguments = settings.arguments;
        final addedKeywordsSubjectId = arguments is (List<KwByLemma>, int)
            ? arguments
            : (<KwByLemma>[], 0);
        return MaterialPageRoute(
            builder: (_) => screenFactory.makeSubjectKeywordExpansionScreen(
                addedKeywords: addedKeywordsSubjectId.$1,
                subjectId: addedKeywordsSubjectId.$2));

      case MainNavigationRouteNames.allProductsReviewsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllProductsReviewsScreen(),
        );

      case MainNavigationRouteNames.singleReviewScreen:
        final arguments = settings.arguments;
        final review = arguments is ReviewModel ? arguments : null;
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeSingleReviewScreen(review),
        );

      case MainNavigationRouteNames.wordsKeywordExpansionScreen:
        final arguments = settings.arguments;
        final addedKeywords =
            arguments is List<KwByLemma> ? arguments : <KwByLemma>[];

        return MaterialPageRoute(
            builder: (_) => screenFactory.makeWordsKeywordExpansionScreen(
                  addedKeywords: addedKeywords,
                ));
      case MainNavigationRouteNames.allAdvertsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllAdvertsScreen(),
        );

      case MainNavigationRouteNames.autocompliteKwExpansionScreen:
        final arguments = settings.arguments;
        final addedKeywords =
            arguments is List<KwByLemma> ? arguments : <KwByLemma>[];

        return MaterialPageRoute(
            builder: (_) => screenFactory.makeAutocompliteKwExpansionScreen(
                  addedKeywords: addedKeywords,
                ));

      case MainNavigationRouteNames.allReviewsScreen:
        final arguments = settings.arguments;
        final nmId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllReviewsScreen(nmId),
        );
      case MainNavigationRouteNames.autoStatWordsScreen:
        final arguments = settings.arguments;
        final campaignIdGNum =
            arguments is (int, int?, String) ? arguments : (0, null, "");
        return MaterialPageRoute(
          builder: (_) =>
              screenFactory.makeAutoStatsWordsScreen(campaignIdGNum),
        );

      case MainNavigationRouteNames.geoSearchScreen:
        final arguments = settings.arguments;
        final initQuery = arguments is String ? arguments : null;
        return MaterialPageRoute(
            builder: (_) => screenFactory.makeGeoSearchScreen(initQuery));

      case MainNavigationRouteNames.realizationReportScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeRealizationReportScreen(),
        );
      case MainNavigationRouteNames.editAdvertsKeywordsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAdvertsToolsScreen(),
        );

      case MainNavigationRouteNames.seoToolScreen:
        final arguments = settings.arguments;
        final cardOfProductCardItem =
            arguments is (CardOfProductModel, CardItem)
                ? arguments
                : (null, null) as (CardOfProductModel, CardItem);
        return MaterialPageRoute(
          builder: (_) =>
              screenFactory.makeSeoToolScreen(cardOfProductCardItem),
        );

      case MainNavigationRouteNames.seoToolCategoryScreen:
        final arguments = settings.arguments;
        final subjectId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: (_) =>
              screenFactory.makeSeoToolCategoryScreen(subjectId: subjectId),
        );

      case MainNavigationRouteNames.expenseManagerScreen:
        final arguments = settings.arguments;

        final nmIdAndAvgLog =
            arguments is (int, int, double) ? arguments : (0, 0, 0.0);
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeExpenseManagerScreen(nmIdAndAvgLog),
        );
      case MainNavigationRouteNames.allQuestionsScreen:
        final arguments = settings.arguments;
        final nmId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAllQuestionsScreen(nmId),
        );
      // case MainNavigationRouteNames.feedbackNotificationScreen:
      //   return MaterialPageRoute(
      //     builder: (_) =>
      //         screenFactory.makeFeedbackNotificationSettingsScreen(),
      //   );
      case MainNavigationRouteNames.advertAnaliticsScreen:
        final arguments = settings.arguments;
        final campaignInfo = arguments is (int, DateTime, String)
            ? arguments
            : (0, DateTime.now(), "");
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAdvertAnaliticsScreen(campaignInfo),
        );

      case MainNavigationRouteNames.singleQuestionScreen:
        final arguments = settings.arguments;
        final question =
            arguments is QuestionModel ? arguments : QuestionModel.empty();
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeSingleQuestionScreen(question),
        );

      case MainNavigationRouteNames.rootAdvertsScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeRootAdvertsScreen(),
        );

      case MainNavigationRouteNames.chatGptScreen:
        final arguments = settings.arguments;
        final question = arguments is String ? arguments : "";
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeChatGptScreen(question),
        );

      case MainNavigationRouteNames.addGroupsScreen:
        final arguments = settings.arguments;
        final productsCardsIds = arguments is List<int> ? arguments : <int>[];
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeAddGroupsScreen(productsCardsIds),
        );

      case MainNavigationRouteNames.feedbackFormScreen:
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeFeedbackFormScreen(),
        );

      // case MainNavigationRouteNames.addCardOptionScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => screenFactory.makeAddCardOptionScreen(),
      //   );

      // case MainNavigationRouteNames.wbWebViewScreen:
      //   final arguments = settings.arguments;
      //   final nmIdsSearchQuery =
      //       arguments is (List<int>, String?) ? arguments : (<int>[], null);
      //   return PageRouteBuilder(
      //       pageBuilder: (context, animation, secondaryAnimation) =>
      //           screenFactory.makeWbWebViewSceen(nmIdsSearchQuery),
      //       transitionsBuilder:
      //           (context, animation, secondaryAnimation, child) {
      //         return FadeTransition(
      //           opacity: animation,
      //           child: child,
      //         );
      //       },
      //       settings: settings);

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: Text('Unknown route: ${settings.name}'),
                  ),
                  body: Center(
                      child: Text('No screen found for ${settings.name}')),
                ));
    }
  }
}
