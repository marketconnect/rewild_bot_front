import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/domain/entities/stream_advert_event.dart';
import 'package:rewild_bot_front/main.dart';
import 'package:rewild_bot_front/presentation/app/app.dart';
import 'package:rewild_bot_front/routes/main_navigation.dart';

AppFactory makeAppFactory() => _AppFactoryDefault();

class _AppFactoryDefault implements AppFactory {
  final _diContainer = _DIContainer();

  _AppFactoryDefault();

  @override
  Widget makeApp() {
    return App(
      navigation: _diContainer._makeAppNavigation(),
    );
  }
}

class _DIContainer {
  _DIContainer();

  // Factories
  ScreenFactory _makeScreenFactory() => ScreenFactoryDefault(this);
  AppNavigation _makeAppNavigation() => MainNavigation(_makeScreenFactory());

  // Streams
  // streams ===================================================================

  // Api Key Exist (AdvertService --> BottomNavigationViewModel)
  final apiKeyExistsStreamController =
      StreamController<Map<ApiKeyType, String>>.broadcast();
  Stream<Map<ApiKeyType, String>> get apiKeyExistsStream =>
      apiKeyExistsStreamController.stream;

  // cards number (CardOfProductService --> BottomNavigationViewModel)
  final subscriptionStreamController = StreamController<(int, int)>.broadcast();
  Stream<(int, int)> get cardsNumberStream =>
      subscriptionStreamController.stream;

  // Advert (AdvertService ---> MainNavigationViewModel) (AdvertService ---> AllAdvertsStatScreenViewModel)
  final updatedAdvertStreamController =
      StreamController<StreamAdvertEvent>.broadcast();
  Stream<StreamAdvertEvent> get updatedAdvertStream =>
      updatedAdvertStreamController.stream;
}

class ScreenFactoryDefault implements ScreenFactory {
  final _DIContainer _diContainer;

  const ScreenFactoryDefault(this._diContainer);

  @override
  Widget makeScreen1() {
    return Screen1();
  }

  @override
  Widget makeScreen2() {
    return Screen2();
  }

  @override
  Widget makeScreen3() {
    return Screen3();
  }

  @override
  Widget makeHomeScreen() {
    return HomeScreen();
  }
}
