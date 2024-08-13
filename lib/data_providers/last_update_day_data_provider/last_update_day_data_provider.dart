import 'package:fpdart/fpdart.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LastUpdateDayDataProvider
    implements UpdateServiceLastUpdateDayDataProvider {
  const LastUpdateDayDataProvider();
  static const updatedAtKey = 'updatedAt';
  @override
  Future<Either<RewildError, void>> update() async {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final ok = await prefs.setString(updatedAtKey, formattedDate);
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

  static Future<Either<RewildError, void>> updateInBackground() async {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final ok = await prefs.setString(updatedAtKey, formattedDate);
      if (!ok) {
        return left(RewildError(
          sendToTg: true,
          'Не удалось сохранить дату последнего обновления',
          source: "LastUpdateDayDataProvider",
          name: "updateInBackground",
        ));
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Не удалось сохранить дату последнего обновления: $e',
        source: "LastUpdateDayDataProvider",
        name: "updateInBackground",
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> todayUpdated() async {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    try {
      final prefs = await SharedPreferences.getInstance();
      final updatedAt = prefs.getString(updatedAtKey);
      if (updatedAt != null) {
        return right(formattedDate == updatedAt);
      }
      return right(false);
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
