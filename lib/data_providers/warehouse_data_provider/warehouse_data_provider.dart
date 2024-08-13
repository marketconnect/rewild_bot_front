import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/warehouse.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class WarehouseDataProvider
    implements CardOfProductServiceWarehouseDataProvider {
  const WarehouseDataProvider();

  // Function to update a list of warehouses
  @override
  Future<Either<RewildError, bool>> update(
      {required List<Warehouse> warehouses}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      for (final warehouse in warehouses) {
        final ok =
            await prefs.setString(warehouse.id.toString(), warehouse.name);
        if (!ok) {
          return left(RewildError(
              sendToTg: true,
              '',
              source: runtimeType.toString(),
              name: "update",
              args: [warehouse.id, warehouse.name]));
        }
      }
      return right(true);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          e.toString(),
          source: runtimeType.toString(),
          name: "update",
          args: [warehouses]));
    }
  }

  // Function to get a warehouse name by id
  @override
  Future<Either<RewildError, String?>> get({required int id}) async {
    try {
      final strId = id.toString();
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(strId) ?? '';
      if (name.isNotEmpty) {
        return right(name);
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          e.toString(),
          source: runtimeType.toString(),
          name: "get",
          args: [id]));
    }
  }
}
