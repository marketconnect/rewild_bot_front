import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/icon_constant.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/widgets/main_navigation_screen_advert_widget.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/widgets/main_navigation_screen_cards_widget.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/widgets/main_navigation_screen_feedback_widget.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/widgets/main_navigation_screen_home_widget.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  int _widgetIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void setIndex(int index) {
    setState(() {
      _widgetIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MainNavigationViewModel>();
    // final adverts = model.adverts;
    final advertApiKeyExists = model.advertApiKeyExists;
    final feedbackApiKeyExists = model.feedbackApiKeyExists;
    final cardsNumber = model.trackedCardsNumber;
    final budget = model.budget;
    final callback = model.updateAdverts;
    final subsNum = model.subscriptionsNum;
    final balance = model.balance;
    final userName = model.userName;
    final isLoading = model.isLoading;
    final goToSubscriptionsScreen = model.goToSubscriptionsScreeen;

    List<Widget> widgets = [
      MainNavigationScreenHomeWidget(
        userName: userName,
      ),
      MainNavigationScreenCardsWidget(
        cardsNumber: cardsNumber,
        subsNum: subsNum ?? 0,
        goToSubscriptionsScreen: goToSubscriptionsScreen,
      ),
      MainNavigationScreenFeedBackWidget(
        apiKeyExists: feedbackApiKeyExists,
      ),
      MainNavigationScreenAdvertWidget(
        adverts: const [],
        balance: balance,
        apiKeyExists: advertApiKeyExists,
        callbackForUpdate: callback,
        budget: budget,
        isLoading: isLoading,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: SizedBox(height: double.infinity, child: widgets[_widgetIndex]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _widgetIndex,
          backgroundColor: Theme.of(context).colorScheme.surface,
          type: BottomNavigationBarType.fixed,
          onTap: (value) async {
            setIndex(value);
            if (value == 3) {
              await model.updateAdverts();
            }
          },
          selectedLabelStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: constraints.maxWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: constraints.maxWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
          items: _buildItems,
        ),
      );
    });
  }

  List<BottomNavigationBarItem> get _buildItems {
    return [
      buildBottomNavigationBarItem(
          IconConstant.iconHome, 'Главная', _widgetIndex == 0),
      buildBottomNavigationBarItem(
          IconConstant.iconProduct, 'Карточки', _widgetIndex == 1),
      buildBottomNavigationBarItem(
          IconConstant.iconTestimonial, 'Вопросы', _widgetIndex == 2),
      buildBottomNavigationBarItem(
          IconConstant.iconRocket, 'Реклама', _widgetIndex == 3),
    ];
  }

  BottomNavigationBarItem buildBottomNavigationBarItem(
      String imageSrc, String label, bool isActive) {
    return BottomNavigationBarItem(
      icon: SizedBox(
        width: MediaQuery.of(context).size.width * 0.07,
        height: MediaQuery.of(context).size.width * 0.07,
        child: Image.asset(
          imageSrc,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
      ),
      label: label,
    );
  }
}
