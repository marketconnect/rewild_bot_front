import 'package:flutter/material.dart';

import 'package:rewild_bot_front/presentation/app/app.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

abstract class ScreenFactory {
  // Widget makeScreen1();
  // Widget makeScreen2();
  // Widget makeScreen3();
  // Widget makeHomeScreen();
  Widget makeMainNavigationScreen();
  Widget makeApiKeysScreen();
  // Widget makeAllCardsScreen();
  // Widget makePaymentScreen(List<int> cardNmIds);
  // Widget makePaymentWebView(PaymentInfo paymentInfo);
  // Widget makeMyWebViewScreen((List<int>, String?) nmIdsSearchString);
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

      // case MainNavigationRouteNames.allCardsScreen:
      //   return PageRouteBuilder(
      //       pageBuilder: (context, animation, secondaryAnimation) =>
      //           screenFactory.makeAllCardsScreen(),
      //       transitionsBuilder:
      //           (context, animation, secondaryAnimation, child) {
      //         return FadeTransition(
      //           opacity: animation,
      //           child: child,
      //         );
      //       },
      //       settings: settings);
      // case MainNavigationRouteNames.paymentScreen:
      //   final arguments = settings.arguments;
      //   final cardNmIds = arguments is List<int> ? arguments : <int>[];
      //   return MaterialPageRoute(
      //     builder: (_) => screenFactory.makePaymentScreen(cardNmIds),
      //   );

      // case MainNavigationRouteNames.paymentWebView:
      //   final arguments = settings.arguments;
      //   final args = arguments is PaymentInfo ? arguments : PaymentInfo.empty();

      //   return MaterialPageRoute(
      //     builder: (_) => screenFactory.makePaymentWebView(args),
      //   );
      // case MainNavigationRouteNames.myWebViewScreen:
      //   final arguments = settings.arguments;
      //   final nmIdsSearchQuery =
      //       arguments is (List<int>, String?) ? arguments : (<int>[], null);
      //   return PageRouteBuilder(
      //       pageBuilder: (context, animation, secondaryAnimation) =>
      //           screenFactory.makeMyWebViewScreen(nmIdsSearchQuery),
      //       transitionsBuilder:
      //           (context, animation, secondaryAnimation, child) {
      //         return FadeTransition(
      //           opacity: animation,
      //           child: child,
      //         );
      //       },
      //       settings: settings);

      // case MainNavigationRouteNames.screen2:
      //   return MaterialPageRoute(builder: (_) => screenFactory.makeScreen2());
      // case MainNavigationRouteNames.screen3:
      //   return MaterialPageRoute(builder: (_) => screenFactory.makeScreen3());
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
