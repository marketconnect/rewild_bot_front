import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/commission_model.dart';

class CommissionDataProvider {
  const CommissionDataProvider();

  @override
  Future<Either<RewildError, CommissionModel?>> get({required int id}) async {
    try {
      final box = await Hive.openBox<CommissionModel>(HiveBoxes.commissions);
      final commission = box.get(id);

      if (commission == null) {
        return right(null);
      }

      return right(commission);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Ошибка во время получения комиссии: ${e.toString()}',
        source: runtimeType.toString(),
        name: "get",
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> insert(
      {required CommissionModel commission}) async {
    try {
      final box = await Hive.openBox<CommissionModel>(HiveBoxes.commissions);
      await box.put(commission.id, commission);

      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Ошибка во время добавления комиссии: ${e.toString()}',
        source: runtimeType.toString(),
        name: "insert",
        args: [commission],
      ));
    }
  }
}
