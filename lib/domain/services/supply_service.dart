import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/supply.dart';
import 'package:rewild_bot_front/presentation/all_cards_screen/all_cards_screen_view_model.dart';

abstract class SupplyServiceSupplyDataProvider {
  Future<Either<RewildError, List<Supply>?>> getForOne({required int nmId});
  Future<Either<RewildError, List<Supply>>> get({required int nmId});
}

class SupplyService implements AllCardsScreenSupplyService {
  final SupplyServiceSupplyDataProvider supplyDataProvider;

  SupplyService({required this.supplyDataProvider});

  @override
  Future<Either<RewildError, List<Supply>?>> getForOne(
      {required int nmId,
      required DateTime dateFrom,
      required DateTime dateTo}) async {
    return supplyDataProvider.getForOne(nmId: nmId);
  }
}
