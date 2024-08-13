import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/total_cost_calculator.dart';
import 'package:rewild_bot_front/presentation/all_cards_screen/all_cards_screen_view_model.dart';

abstract class TotalCostServiceTotalCostDataProvider {
  Future<Either<RewildError, void>> addOrUpdateExpense(
      int nmId, String name, double value);
  Future<Either<RewildError, void>> removeExpense(int nmId, String name);
  Future<Either<RewildError, TotalCostCalculator>> getTotalCost(int nmId);
  Future<Either<RewildError, List<int>>> getAllNmIds();
  Future<Either<RewildError, void>> deleteAll(int nmId);
  Future<Either<RewildError, void>> addAll(
      int nmId, Map<String, double> expenses);
}

class TotalCostService implements AllCardsScreenTotalCostService {
  final TotalCostServiceTotalCostDataProvider totalCostDataProvider;
  const TotalCostService({required this.totalCostDataProvider});

  @override
  Future<Either<RewildError, TotalCostCalculator>> getTotalCost(
      int nmId) async {
    return await totalCostDataProvider.getTotalCost(nmId);
  }

  @override
  Future<Either<RewildError, void>> addOrUpdateExpense(
      int nmId, String name, double value) async {
    // print('nmId: $nmId, name: $name, value: $value');
    return await totalCostDataProvider.addOrUpdateExpense(nmId, name, value);
  }

  @override
  Future<Either<RewildError, void>> removeExpense(int nmId, String name) async {
    return await totalCostDataProvider.removeExpense(nmId, name);
  }

  @override
  Future<Either<RewildError, void>> updateWith(
      {required int nmIdFrom, required int nmIdTo}) async {
    final deleteRes = await totalCostDataProvider.deleteAll(nmIdTo);
    if (deleteRes.isLeft()) {
      return left(deleteRes.fold((l) => l, (r) => throw UnimplementedError()));
    }

    final totalCostEither = await totalCostDataProvider.getTotalCost(nmIdFrom);
    if (totalCostEither.isLeft()) {
      return left(
          totalCostEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    final totalCost =
        totalCostEither.fold((l) => throw UnimplementedError(), (r) => r);

    final addRes =
        await totalCostDataProvider.addAll(nmIdTo, totalCost.getExpenses());
    if (addRes.isLeft()) {
      return left(addRes.fold((l) => l, (r) => throw UnimplementedError()));
    }

    return right(null);
  }

  @override
  Future<Either<RewildError, List<int>>> getAllNmIds() async {
    final result = await totalCostDataProvider.getAllNmIds();
    if (result.isLeft()) {
      return right([]);
    }

    final nmIds = result.fold((l) => throw UnimplementedError(), (r) => r);
    final distinctNmIds = nmIds.toSet().toList();
    return right(distinctNmIds);
  }

  @override
  Future<Either<RewildError, Map<int, double>>> getAllGrossProfit(
      int averageLogistics) async {
    final allNmIds = await getAllNmIds();
    if (allNmIds.isLeft()) {
      return left(allNmIds.fold((l) => l, (r) => throw UnimplementedError()));
    }

    final nmIds = allNmIds.fold((l) => throw UnimplementedError(), (r) => r);

    final totalCosts = <int, double>{};
    for (final nmId in nmIds) {
      final totalCostEither = await getTotalCost(nmId);
      if (totalCostEither.isLeft()) {
        return left(
            totalCostEither.fold((l) => l, (r) => throw UnimplementedError()));
      }
      final totalCost =
          totalCostEither.fold((l) => throw UnimplementedError(), (r) => r);

      if (totalCost.totalCost > 0) {
        totalCosts[nmId] = totalCost.grossProfit(averageLogistics);
      }
    }
    return right(totalCosts);
  }
}
