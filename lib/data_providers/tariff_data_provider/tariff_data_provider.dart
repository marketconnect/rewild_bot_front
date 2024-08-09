import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/tariff.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class TariffDataProvider implements UpdateServiceTariffDataProvider {
  const TariffDataProvider();

  Box<Tariff> get _box => Hive.box<Tariff>(HiveBoxes.tariffs);

  @override
  Future<Either<RewildError, List<Tariff>>> getByStoreId(int storeId) async {
    try {
      final tariffs =
          _box.values.where((tariff) => tariff.storeId == storeId).toList();
      return right(tariffs);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve tariffs by storeId: $e",
        source: "TariffDataProvider",
        name: "getByStoreId",
        args: [storeId],
        sendToTg: false,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> insertAll(List<Tariff> tariffs) async {
    try {
      for (var tariff in tariffs) {
        await _box.put('${tariff.storeId}_${tariff.type}', tariff);
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to insert tariffs: $e",
        source: "TariffDataProvider",
        name: "insertAll",
        args: [tariffs],
        sendToTg: false,
      ));
    }
  }
}
