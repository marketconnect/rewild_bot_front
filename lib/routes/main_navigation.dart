import 'package:flutter/material.dart';
import 'package:rewild_bot_front/domain/entities/card_catalog.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';

import 'package:rewild_bot_front/domain/entities/payment_info.dart';

import 'package:rewild_bot_front/presentation/app/app.dart';
import 'package:rewild_bot_front/presentation/notification_card_screen/notification_card_view_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

abstract class ScreenFactory {
  Widget makeMainNavigationScreen();
  Widget makeApiKeysScreen();
  Widget makeAllCardsScreen();
  Widget makeMyWebViewScreen((List<int>, String?) nmIdsSearchString);
  Widget makePaymentScreen(List<int> cardNmIds);
  Widget makePaymentWebView(PaymentInfo paymentInfo);
  Widget makeSingleCardScreen(int id);
  Widget makeCardNotificationsSettingsScreen(NotificationCardState state);

  Widget makeAllCardsSeoScreen();

  Widget makeCompetitorKwExpansionScreen();

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
}

class MainNavigation implements AppNavigation {
  final ScreenFactory screenFactory;

  const MainNavigation(this.screenFactory);

  @override
  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            builder: (_) => screenFactory.makeMainNavigationScreen());
      case MainNavigationRouteNames.apiKeysScreen:
        return MaterialPageRoute(
            builder: (_) => screenFactory.makeApiKeysScreen());

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
      case MainNavigationRouteNames.paymentScreen:
        final arguments = settings.arguments;
        final cardNmIds = arguments is List<int> ? arguments : <int>[];
        return MaterialPageRoute(
          builder: (_) => screenFactory.makePaymentScreen(cardNmIds),
        );

      case MainNavigationRouteNames.paymentWebView:
        final arguments = settings.arguments;
        final args = arguments is PaymentInfo ? arguments : PaymentInfo.empty();

        return MaterialPageRoute(
          builder: (_) => screenFactory.makePaymentWebView(args),
        );
      case MainNavigationRouteNames.myWebViewScreen:
        final arguments = settings.arguments;
        final nmIdsSearchQuery =
            arguments is (List<int>, String?) ? arguments : (<int>[], null);
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                screenFactory.makeMyWebViewScreen(nmIdsSearchQuery),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            settings: settings);

      case MainNavigationRouteNames.singleCardScreen:
        final arguments = settings.arguments;
        final cardId = arguments is int ? arguments : 0;
        return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                screenFactory.makeSingleCardScreen(cardId),
            // transitionDuration: const Duration(seconds: 2),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            settings: settings);
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
        return MaterialPageRoute(
          builder: (_) => screenFactory.makeCompetitorKwExpansionScreen(),
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

      case MainNavigationRouteNames.wordsKeywordExpansionScreen:
        final arguments = settings.arguments;
        final addedKeywords =
            arguments is List<KwByLemma> ? arguments : <KwByLemma>[];

        return MaterialPageRoute(
            builder: (_) => screenFactory.makeWordsKeywordExpansionScreen(
                  addedKeywords: addedKeywords,
                ));

      case MainNavigationRouteNames.autocompliteKwExpansionScreen:
        final arguments = settings.arguments;
        final addedKeywords =
            arguments is List<KwByLemma> ? arguments : <KwByLemma>[];

        return MaterialPageRoute(
            builder: (_) => screenFactory.makeAutocompliteKwExpansionScreen(
                  addedKeywords: addedKeywords,
                ));

      case MainNavigationRouteNames.geoSearchScreen:
        final arguments = settings.arguments;
        final initQuery = arguments is String ? arguments : null;
        return MaterialPageRoute(
            builder: (_) => screenFactory.makeGeoSearchScreen(initQuery));

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
