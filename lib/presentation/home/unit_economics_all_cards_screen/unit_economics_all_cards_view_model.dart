import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/commission_model.dart';
import 'package:rewild_bot_front/domain/entities/total_cost_calculator.dart';
import 'package:rewild_bot_front/domain/entities/user_product_card.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

abstract class UnitEconomicsAllCardsAuthService {
  Future<Either<RewildError, String>> getToken();
}

abstract class UnitEconomicsAllCardsTariffService {
  Future<Either<RewildError, int>> getCurrentAverageLogistics(
      {required String token});
}

abstract class UnitEconomicsAllCardsUpdateService {
  Future<Either<RewildError, int>> insertForUnitEconomy(
      {required String token,
      required List<UserProductCard> cardOfProductsToInsert});
}

abstract class UnitEconomicsAllCardsUserCardService {
  Future<Either<RewildError, List<UserProductCard>>> getAllUserCards();
}

abstract class UnitEconomicsAllCardsCommissionService {
  Future<Either<RewildError, CommissionModel>> get(
      {required String token, required int id});
}

abstract class UnitEconomicsAllCardsTotalCostsService {
  Future<Either<RewildError, TotalCostCalculator>> getTotalCost(int nmId);
}

class UnitEconomicsAllCardsViewModel extends ResourceChangeNotifier {
  UnitEconomicsAllCardsViewModel(
      {required super.context,
      required this.userCardService,
      required this.commissionService,
      required this.authService,
      required this.updateService,
      required this.tariffService,
      required this.totalCostService}) {
    _asyncInit();
  }
  final UnitEconomicsAllCardsUserCardService userCardService;
  final UnitEconomicsAllCardsTotalCostsService totalCostService;
  final UnitEconomicsAllCardsCommissionService commissionService;
  final UnitEconomicsAllCardsAuthService authService;
  final UnitEconomicsAllCardsUpdateService updateService;

  final UnitEconomicsAllCardsTariffService tariffService;

  final List<UserProductCard> _userProductCards = [];
  void setUserProductCards(List<UserProductCard> userProductCards) {
    _userProductCards.clear();
    _userProductCards.addAll(userProductCards);
  }

  // loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setIsLoading(bool loading) {
    _isLoading = loading;
    notify();
  }

// api key exists
  bool _apiKeyExists = false;
  bool get apiKeyExists => _apiKeyExists;
  void setApiKeyExists(bool exists) {
    _apiKeyExists = exists;
  }

  List<UserProductCard> get userProductCards => _userProductCards;
  int _averageLogisticCost = 50;
  void setAverageLogisticCost(int averageLogisticCost) {
    _averageLogisticCost = averageLogisticCost;
  }

  int get averageLogisticCost => _averageLogisticCost;
  Future<void> _asyncInit() async {
    setIsLoading(true);

    final values = await Future.wait([
      fetch(() => userCardService.getAllUserCards()),
      fetch(() => authService.getToken())
    ]);

    final userProductCardsOrNull = values[0] as List<UserProductCard>?;

    final tokenOrNull = values[1] as String?;
    if (tokenOrNull == null) {
      setApiKeyExists(false);
      setIsLoading(false);
      return;
    }

    setApiKeyExists(true);
    if (userProductCardsOrNull == null) {
      setIsLoading(false);
      return;
    }

    List<UserProductCard> userProductCardsWithUnitEconomics = [];
    for (final card in userProductCardsOrNull) {
      final totalCosts =
          await fetch(() => totalCostService.getTotalCost(card.sku));
      if (totalCosts == null) {
        continue;
      }

      final averageLogisticCostFromServerOrNull = await fetch(
        () => tariffService.getCurrentAverageLogistics(token: tokenOrNull),
      );
      if (averageLogisticCostFromServerOrNull != null) {
        setAverageLogisticCost(averageLogisticCostFromServerOrNull);
      }
      final grossProfit = totalCosts.grossProfit(_averageLogisticCost);
      userProductCardsWithUnitEconomics.add(
        UserProductCard(
          sku: card.sku,
          img: card.img,
          mp: card.mp,
          name: card.name,
          subjectId: card.subjectId,
          totalCost: grossProfit,
        ),
      );
    }

    // Insert cards in the CardOfProducts storage that the expenseManagerScreen can use details of the cards
    await fetch(() => updateService.insertForUnitEconomy(
          token: tokenOrNull,
          cardOfProductsToInsert: userProductCardsWithUnitEconomics,
        ));
    setUserProductCards(userProductCardsWithUnitEconomics);
    setIsLoading(false);
  }

  Future<void> _reload() async {
    setIsLoading(true);
    final userProductCardsOrNull =
        await fetch(() => userCardService.getAllUserCards());

    if (userProductCardsOrNull == null) {
      setIsLoading(false);
      return;
    }
    List<UserProductCard> userProductCardsWithUnitEconomics = [];
    for (final card in userProductCardsOrNull) {
      final totalCosts =
          await fetch(() => totalCostService.getTotalCost(card.sku));
      if (totalCosts == null) {
        continue;
      }

      userProductCardsWithUnitEconomics.add(
        UserProductCard(
          sku: card.sku,
          img: card.img,
          mp: card.mp,
          name: card.name,
          subjectId: card.subjectId,
          totalCost: totalCosts.grossProfit(_averageLogisticCost),
        ),
      );
    }

    setUserProductCards(userProductCardsWithUnitEconomics);
    setIsLoading(false);
  }

  Future<void> expenseManagerScreen(int sku) async {
    final card = _userProductCards.firstWhere((element) => element.sku == sku);
    final subjectId = card.subjectId;
    final tokenOrNull = await fetch(() => authService.getToken());
    if (tokenOrNull == null) {
      return;
    }
    // final maxLogistic = calculateMaxTariffCost(_tarrifs);
    final commissionOrNull = await fetch(
        () => commissionService.get(token: tokenOrNull, id: subjectId));
    final commission = commissionOrNull?.commission;
    if (context.mounted) {
      final res = await Navigator.of(context).pushNamed(
          MainNavigationRouteNames.expenseManagerScreen,
          arguments: (sku, 0, commission ?? 0));

      if (res != null && res is bool && res) {
        await _reload();
      }
    }
  }

  Future<void> addToken() async {
    await Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.apiKeysScreen);
    _asyncInit();
  }
}
