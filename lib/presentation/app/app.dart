import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

abstract class AppNavigation {
  Route<Object> onGenerateRoute(RouteSettings settings);
}

class App extends StatelessWidget {
  final AppNavigation navigation;

  const App({super.key, required this.navigation});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [
        Locale('en'), // английский
        Locale('ru'), // русский
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      onGenerateRoute: navigation.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
