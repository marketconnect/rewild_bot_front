import 'package:flutter/material.dart';

abstract class AppNavigation {
  Route<Object> onGenerateRoute(RouteSettings settings);
}

class App extends StatelessWidget {
  final AppNavigation navigation;

  const App({super.key, required this.navigation});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: navigation.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
