import 'package:flutter/material.dart';
import 'package:rewild_bot_front/widgets/link_btn.dart';

class MainNavigationScreenCardsWidget extends StatelessWidget {
  const MainNavigationScreenCardsWidget(
      {super.key,
      required this.cardsNumber,
      required this.subsNum,
      required this.goToSubscriptionsScreen});

  final int cardsNumber;
  final int subsNum;
  final Function goToSubscriptionsScreen;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
                'Товары',
                style: TextStyle(
                    fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        _InfoRow(
          cardsNum: cardsNumber,
          subsNum: subsNum,
          goToSubscriptionsScreen: goToSubscriptionsScreen,
        ),
        SizedBox(
          height: screenHeight * 0.04,
        ),
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              LinkBtn(
                text: 'Аналитика',
                color: Colors.blueAccent,
                route: "MainNavigationRouteNames.analiticsNavScreen",
                // route: '',
                iconData: Icons.analytics,
              ),
              LinkBtn(
                text: 'СЕО',
                color: Colors.orangeAccent,
                route: "MainNavigationRouteNames.cardsNavigationScreen",
                iconData: Icons.dashboard,
              ),
              LinkBtn(
                text: 'Финансы',
                color: Colors.greenAccent,
                route: "MainNavigationRouteNames.realizationReportScreen",
                // route: '',
                iconData: Icons.currency_ruble,
              ),
              LinkBtn(
                text: 'Анализ спроса',
                color: Color(0xFFCDDC39),
                route: "MainNavigationRouteNames.allCategoriesScreen",
                // route: '',
                iconData: Icons.pie_chart,
              ),
              //               NavigationScreenCustomCard(
              //   icon: Icons.pie_chart,
              //   backgroundColor: Colors.purple.shade300,
              //   title: 'Анализ спроса',
              //   context: context,
              //   onTap: () => Navigator.of(context)
              //       .pushNamed(MainNavigationRouteNames.allCategoriesScreen),
              // ),

              // const LinkBtn(
              //   text: 'Позиции по регионам',
              //   color: Color(0xFFCDDC39),
              //   route: MainNavigationRouteNames.geoSearchScreen,
              //   // route: '',
              //   iconData: Icons.map_outlined,
              // ),
            ],
          ),
        )
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.cardsNum,
      required this.goToSubscriptionsScreen,
      required this.subsNum});
  final Function goToSubscriptionsScreen;
  final int cardsNum;
  final int subsNum;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: screenWidth * 0.3,
          child: Text('$cardsNum шт/$subsNum',
              maxLines: 1,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: screenWidth * 0.1,
                  fontWeight: FontWeight.bold)),
        ),
      ),
      TextButton(
          onPressed: () => goToSubscriptionsScreen(context),
          child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              width: screenWidth * 0.4,
              height: screenHeight * 0.08,
              child: Text(
                'Подписка',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ))),
    ]);
  }
}
