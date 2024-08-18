import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/initial_stock_model.dart';
import 'package:rewild_bot_front/presentation/single_card_screen/single_card_screen_view_model.dart';

abstract class InitStockServiceInitStockDataProvider {
  Future<Either<RewildError, List<InitialStockModel>>> getAll(
      {required DateTime dateFrom, required DateTime dateTo});

  Future<Either<RewildError, List<InitialStockModel>>> get(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo});
}

class InitialStockService
    implements
        // AllCardsScreenInitStockService,
        SingleCardScreenInitialStockService {
  final InitStockServiceInitStockDataProvider initStockDataProvider;

  InitialStockService({required this.initStockDataProvider});

  // Future<Either<RewildError,List<InitialStockModel>>> getAll(
  //     [DateTime? dateFrom, DateTime? dateTo]) async {
  //   if (dateFrom == null || dateTo == null) {
  //     dateFrom = yesterdayEndOfTheDay();
  //     dateTo = DateTime.now();
  //   }
  //   return initStockDataProvider.getAll(dateFrom, dateTo);
  // }

  @override
  Future<Either<RewildError, List<InitialStockModel>>> get(
      {required int nmId, DateTime? dateFrom, DateTime? dateTo}) async {
    if (dateFrom == null || dateTo == null) {
      dateFrom = yesterdayEndOfTheDay();
      dateTo = DateTime.now();
    }
    return initStockDataProvider.get(
        nmId: nmId, dateFrom: dateFrom, dateTo: dateTo);
  }
}
