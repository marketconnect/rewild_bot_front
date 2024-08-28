import 'package:flutter/material.dart';
import 'package:rewild_bot_front/core/constants/icon_constant.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/widgets/empty_api_key.dart';

class MainNavigationScreenFeedBackWidget extends StatelessWidget {
  const MainNavigationScreenFeedBackWidget(
      {super.key, required this.apiKeyExists});
  final bool apiKeyExists;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return !apiKeyExists
        ? const EmptyApiKey(
            text:
                'Для работы с отзывами и вопросами WB вам необходимо добавить токен "Вопросы и отзывы"',
            route: MainNavigationRouteNames.apiKeysScreen,
          )
        : SingleChildScrollView(
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
                      'Обратная связь',
                      style: TextStyle(
                          fontSize: screenWidth * 0.08,
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
                child: Column(
                  children: [
                    _Link(
                      text: 'Вопросы',
                      color: const Color(0xFFd2a941),
                      imageSrc: IconConstant.iconQuestions,
                      route:
                          MainNavigationRouteNames.allProductsQuestionsScreen,
                    ),
                    _Link(
                      text: 'Отзывы',
                      color: const Color(0xFF8c56ce),
                      imageSrc: IconConstant.iconRatingStars,
                      route: MainNavigationRouteNames.allProductsReviewsScreen,
                    ),
                    _Link(
                      text: 'Настройка уведомлений',
                      route:
                          MainNavigationRouteNames.feedbackNotificationScreen,
                      color: const Color(0xFF4aa6db),
                      imageSrc: IconConstant.iconNotificationSettings,
                    ),
                  ],
                ),
              ),
            ]),
          );
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.text,
    required this.route,
    required this.imageSrc,
    required this.color,
  });

  final String text;

  final String route;
  final String imageSrc;
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
                padding: const EdgeInsets.all(7.0),
                child: SizedBox(
                  width: screenWidth * 0.08,
                  child: Image.asset(
                    imageSrc,
                    color: Theme.of(context).colorScheme.surface,
                  ),
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
