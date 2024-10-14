import 'package:flutter/material.dart';

import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

class FinanceNavScreenWidget extends StatelessWidget {
  const FinanceNavScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenHeight * 0.1,
                ),
                Text(
                  'Финансы',
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: screenHeight * 0.05,
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.3),
            ),
            child: const Column(
              children: [
                _Link(
                  text: 'Отчеты',
                  color: Colors.blueAccent,
                  route: MainNavigationRouteNames
                      .realizationReportScreen, // Укажите правильный маршрут для отчётов
                  iconData: Icons.insert_chart,
                ),
                _Link(
                  text: 'Юнит-экономика',
                  color: Colors.greenAccent,
                  route: MainNavigationRouteNames
                      .unitEconomicsAllCardsScreen, // Укажите правильный маршрут для юнит-экономики
                  iconData: Icons.show_chart,
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.text,
    required this.route,
    required this.iconData,
    required this.color,
  });

  final String text;

  final String route;
  final IconData iconData;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            color: Theme.of(context).colorScheme.surface),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  iconData,
                  color: Theme.of(context).colorScheme.surface,
                  size: screenWidth * 0.05,
                ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.05,
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: screenWidth * 0.05, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
