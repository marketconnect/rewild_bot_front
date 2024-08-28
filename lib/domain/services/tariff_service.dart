import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/prices.dart';
import 'package:rewild_bot_front/domain/entities/tariff_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/all_cards_screen/all_cards_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/expense_manager_screen/expense_manager_view_model.dart';
import 'package:rewild_bot_front/presentation/products/cards/single_card_screen/single_card_screen_view_model.dart';

abstract class TariffServiceTariffDataProvider {
  Future<Either<RewildError, List<TariffModel>>> getByStoreId(int storeId);
}

abstract class TariffServiceAverageLogisticsApiClient {
  Future<Either<RewildError, Prices>> getCurrentPrice({required String token});
}

abstract class TariffServiceAverageLogisticsDataProvider {
  Future<Either<RewildError, int?>> get();
  Future<Either<RewildError, void>> update(int price);
}

class TariffService
    implements
        AllCardsScreenAverageLogisticsService,
        ExpenseManagerAverageLogisticsService,
        SingleCardScreenTariffService {
  final TariffServiceTariffDataProvider tariffDataProvider;
  final TariffServiceAverageLogisticsApiClient averageLogisticsApiClient;
  final TariffServiceAverageLogisticsDataProvider averageLogisticsDataProvider;
  TariffService(
      {required this.tariffDataProvider,
      required this.averageLogisticsApiClient,
      required this.averageLogisticsDataProvider});
  @override
  Future<Either<RewildError, List<TariffModel>>> getByStoreId(
      int storeId) async {
    return tariffDataProvider.getByStoreId(storeId);
  }

  @override
  Future<Either<RewildError, int>> getCurrentAverageLogistics(
      {required String token}) async {
    // from local db
    final averageLogisticsEither = await averageLogisticsDataProvider.get();
    if (averageLogisticsEither.isRight()) {
      final price = averageLogisticsEither.fold(
          (l) => throw UnimplementedError(), (r) => r);
      if (price != null) {
        return right(price);
      }
    }

    // from server
    final pricesEither =
        await averageLogisticsApiClient.getCurrentPrice(token: token);
    if (pricesEither.isRight()) {
      final prices =
          pricesEither.fold((l) => throw UnimplementedError(), (r) => r);
      await averageLogisticsDataProvider.update(prices.averageLogistics);
      return right(prices.averageLogistics);
    }
    return right(100);
  }
}
