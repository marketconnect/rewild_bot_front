import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';
import 'package:rewild_bot_front/di/di.dart';
import 'package:rewild_bot_front/domain/entities/card_keyword.dart';
import 'package:rewild_bot_front/domain/entities/hive/cached_keyword.dart';
import 'package:rewild_bot_front/domain/entities/hive/card_of_product.dart';
import 'package:rewild_bot_front/domain/entities/hive/commission_model.dart';
import 'package:rewild_bot_front/domain/entities/hive/filter_model.dart';
import 'package:rewild_bot_front/domain/entities/hive/group_model.dart';
import 'package:rewild_bot_front/domain/entities/hive/initial_stock.dart';
import 'package:rewild_bot_front/domain/entities/hive/kw_by_lemma.dart';
import 'package:rewild_bot_front/domain/entities/hive/nm_id.dart';
import 'package:rewild_bot_front/domain/entities/hive/order_model.dart';
import 'package:rewild_bot_front/domain/entities/hive/rewild_notification_model.dart';
import 'package:rewild_bot_front/domain/entities/hive/seller.dart';
import 'package:rewild_bot_front/domain/entities/hive/stock.dart';
import 'package:rewild_bot_front/domain/entities/hive/supply.dart';
import 'package:rewild_bot_front/domain/entities/hive/tariff.dart';

import 'package:rewild_bot_front/domain/entities/hive/total_cost_calculator.dart';

import 'package:rewild_bot_front/domain/entities/hive/user_seller.dart';

abstract class AppFactory {
  Widget makeApp();
}

final appFactory = makeAppFactory();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(UserSellerAdapter());
  Hive.registerAdapter(InitialStockAdapter());
  await Hive.openBox<CardOfProduct>(HiveBoxes.cardOfProducts); // 0
  await Hive.openBox<GroupModel>(HiveBoxes.groups); // 1
  await Hive.openBox<InitialStock>(HiveBoxes.initialStocks); // 2
  await Hive.openBox<NmId>(HiveBoxes.nmIds); // 3
  await Hive.openBox<Seller>(HiveBoxes.sellers); // 4
  await Hive.openBox<Stock>(HiveBoxes.stocks); // 5
  await Hive.openBox<Supply>(HiveBoxes.supplies); // 6
  await Hive.openBox<Tariff>(HiveBoxes.tariffs); // 7
  await Hive.openBox<UserSeller>(HiveBoxes.userSellers); // 8
  await Hive.openBox<FilterModel>(HiveBoxes.filters); // 9
  await Hive.openBox<ReWildNotificationModel>(
      HiveBoxes.rewildNotifications); // 10
  await Hive.openBox<CommissionModel>(HiveBoxes.commissions); // 11
  await Hive.openBox<OrderModel>(HiveBoxes.orders); // 12
  await Hive.openBox<TotalCostCalculator>(HiveBoxes.totalCosts); //14
  await Hive.openBox<CardKeyword>(HiveBoxes.cardKeywords); // 15
  await Hive.openBox<CachedKeyword>(HiveBoxes.cachedKeywords); // 16
  await Hive.openBox<KwByLemma>(HiveBoxes.kwByLemmas); // 17

  setUrlStrategy(PathUrlStrategy());
  runApp(appFactory.makeApp());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/screen1');
              },
              child: const Text('Go to Screen 1'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/screen2');
              },
              child: const Text('Go to Screen 2'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/screen3');
              },
              child: const Text('Go to Screen 3'),
            ),
          ],
        ),
      ),
    );
  }
}

class Screen1 extends StatelessWidget {
  const Screen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Экран 1'),
      ),
      body: const Center(
        child: Text('Это есть Экран 1'),
      ),
    );
  }
}

class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Экран 2'),
      ),
      body: const Center(
        child: Text('А Это есть Экран 2'),
      ),
    );
  }
}

class Screen3 extends StatelessWidget {
  const Screen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('"Экран 3'),
      ),
      body: const Center(
        child: Text('Это есть Экран 3'),
      ),
    );
  }
}
