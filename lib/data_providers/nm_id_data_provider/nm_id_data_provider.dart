import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/nm_id.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';

class NmIdDataProvider implements CardOfProductServiceNmIdDataProvider {
  const NmIdDataProvider();

  Box<NmId> get _box => Hive.box<NmId>(HiveBoxes.nmIds);

  // Метод для получения всех NmId из Hive
  @override
  Future<Either<RewildError, List<NmId>>> getNmIds() async {
    try {
      final nmIds = _box.values.toList();
      return right(nmIds);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        sendToTg: false,
        source: 'NmIdDataProvider',
        name: 'getNmIds',
        args: [],
      ));
    }
  }

  // Метод для вставки NmId в Hive
  @override
  Future<Either<RewildError, void>> insertNmId(NmId nmId) async {
    try {
      await _box.put(nmId.nmId, nmId); // Сохраняем объект по его nmId
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        sendToTg: false,
        source: 'NmIdDataProvider',
        name: 'insertNmId',
        args: [],
      ));
    }
  }
}
