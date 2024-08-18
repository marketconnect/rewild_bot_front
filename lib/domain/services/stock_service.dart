import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/stocks_model.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/presentation/single_card_screen/single_card_screen_view_model.dart';

abstract class StockServiceStocksDataProvider {
  Future<Either<RewildError, List<StocksModel>>> getAll();
  Future<Either<RewildError, List<StocksModel>>> get({required int nmId});
}

class StockService
    implements
        CardOfProductServiceStockDataProvider,
        SingleCardScreenStockService {
  final StockServiceStocksDataProvider stocksDataProvider;

  StockService({required this.stocksDataProvider});

  @override
  Future<Either<RewildError, List<StocksModel>>> getAll() async {
    return stocksDataProvider.getAll();
  }

  @override
  Future<Either<RewildError, List<StocksModel>>> get(
      {required int nmId}) async {
    return stocksDataProvider.get(nmId: nmId);
  }
}
