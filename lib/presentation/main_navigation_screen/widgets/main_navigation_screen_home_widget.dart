import 'package:flutter/material.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

class MainNavigationScreenHomeWidget extends StatefulWidget {
  const MainNavigationScreenHomeWidget({super.key, required this.userName});
  final Future<String> Function() userName;
  @override
  State<MainNavigationScreenHomeWidget> createState() =>
      _MainNavigationScreenHomeWidgetState();
}

class _MainNavigationScreenHomeWidgetState
    extends State<MainNavigationScreenHomeWidget> {
  // late bool feedBackExpanded;
  // late bool showThankYouMessage;
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    // feedBackExpanded = false;
    // showThankYouMessage = false;
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
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
                'Главная',
                style: TextStyle(
                    fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold),
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
                text: 'API токены',
                color: Color(0xFF41434e),
                route: MainNavigationRouteNames.apiKeysScreen,
                iconData: Icons.key,
              ),
              _Link(
                text: 'СЕО',
                color: Colors.orangeAccent,
                route: MainNavigationRouteNames.allCardsSeoScreen,
                iconData: Icons.dashboard,
              ),
            ],
          ),
        )
      ]),
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
