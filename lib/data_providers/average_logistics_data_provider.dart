import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AverageLogisticsDataProvider
    implements UpdateServiceAverageLogisticsDataProvider {
  const AverageLogisticsDataProvider();
  static const averageLogisticsPriceKey = 'averageLogistics';
  @override
  Future<Either<RewildError, void>> update(int price) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final ok = await prefs.setInt(averageLogisticsPriceKey, price);
      if (!ok) {
        return left(RewildError(
          sendToTg: true,
          'Не удалось сохранить дату последнего обновления',
          source: runtimeType.toString(),
          name: "update",
        ));
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось сохранить дату последнего обновления: $e',
        source: runtimeType.toString(),
        name: "update",
      ));
    }
  }

  // static Future<Either<RewildError, void>> updateInBackground(int price) async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();

  //     final ok = await prefs.setInt(averageLogisticsPriceKey, price);
  //     if (!ok) {
  //       return left(RewildError(
  //         sendToTg: true,
  //         'Не удалось сохранить дату последнего обновления',
  //         source: "LastUpdateDayDataProvider",
  //         name: "updateInBackground",
  //       ));
  //     }
  //     return right(null);
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: true,
  //       'Не удалось сохранить дату последнего обновления: $e',
  //       source: "LastUpdateDayDataProvider",
  //       name: "updateInBackground",
  //     ));
  //   }
  // }

  @override
  Future<Either<RewildError, int?>> get() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final price = prefs.getInt(averageLogisticsPriceKey);

      return right(price);
    } on Exception catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось получить дату последнего обновления:  $e',
        source: runtimeType.toString(),
        name: "todayUpdated",
      ));
    }
  }
}
