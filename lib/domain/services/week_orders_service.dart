import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/order_model.dart';
import 'package:rewild_bot_front/presentation/single_card_screen/single_card_screen_view_model.dart';

abstract class WeekOrdersServiceWeekOrdersApiClient {
  Future<Either<RewildError, List<OrderModel>>> getOrdersFromTo(
      {required String token, required List<int> skus});
}

abstract class WeekOrdersServiceOrdersDataProvider {
  Future<Either<RewildError, void>> insertAll(List<OrderModel> orders);
  Future<Either<RewildError, List<OrderModel>>> getAllBySkus(List<int> skus);
  Future<Either<RewildError, bool>> isUpdated(int sku);
}

class WeekOrdersService implements SingleCardScreenWeekOrdersService {
  final WeekOrdersServiceWeekOrdersApiClient ordersApiClient;
  final WeekOrdersServiceOrdersDataProvider ordersDataProvider;

  const WeekOrdersService(
      {required this.ordersApiClient, required this.ordersDataProvider});

  @override
  Future<Either<RewildError, List<OrderModel>>> getOrdersFromTo(
      {required String token,
      // required int from,
      // required int to,

      required List<int> skus}) async {
    // try to get from local db
    List<int> skusForFetch = [];
    List<int> localSkus = [];
    List<OrderModel> ordersFromLocalDb = [];

    for (var sku in skus) {
      final isUpdatedEither = await ordersDataProvider.isUpdated(sku);

      final isUpdated = isUpdatedEither.fold((l) => false, (r) => r);
      if (!isUpdated) {
        skusForFetch.add(sku);
      } else {
        localSkus.add(sku);
      }
    }
    final ordersFromLocalDbEither =
        await ordersDataProvider.getAllBySkus(localSkus);
    if (ordersFromLocalDbEither.isRight()) {
      ordersFromLocalDb = ordersFromLocalDbEither.fold(
          (l) => throw UnimplementedError(), (r) => r);
    } else {
      skusForFetch.addAll(localSkus);
    }

    if (skusForFetch.isEmpty) {
      return right(ordersFromLocalDb);
    }
    // fetchprint
    final resourceEither =
        await ordersApiClient.getOrdersFromTo(token: token, skus: skusForFetch);
    List<OrderModel> result = [];
    if (resourceEither.isRight()) {
      final orders =
          resourceEither.fold((l) => throw UnimplementedError(), (r) => r);
      for (var order in orders) {
        if (order.qty < -15) {
          final ordersOfSku = orders.where((o) => o.sku == order.sku).toList();

          final posOrders = ordersOfSku.where((o) => o.qty >= 0);

          if (posOrders.isNotEmpty) {
            final avgOrder = posOrders.fold(0,
                    (previousValue, element) => previousValue + element.qty) /
                posOrders.length;

            final newOrder = OrderModel(
              sku: order.sku,
              qty: avgOrder.toInt(),
              price: order.price,
              // sizeOption: order.sizeOption,
              warehouse: order.warehouse,
              period: order.period,
              // createdAt: order.createdAt
            );
            result.add(newOrder);
          }
        } else if (order.qty < 0) {
          final newOrder = OrderModel(
            sku: order.sku,
            qty: 0,
            price: order.price,
            // sizeOption: order.sizeOption,
            warehouse: order.warehouse,
            period: order.period,
            // createdAt: order.createdAt
          );
          result.add(newOrder);
        } else {
          result.add(order);
        }
      }
    }

    await ordersDataProvider.insertAll(result);
    final allResults = result + ordersFromLocalDb;
    return right(allResults);
  }
}
