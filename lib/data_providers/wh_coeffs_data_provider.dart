import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';

import 'package:rewild_bot_front/domain/entities/wh_coeffs.dart';
import 'package:rewild_bot_front/domain/services/wf_cofficient_service.dart';

class WarehouseCoeffsDataProvider implements WhCoefficientsServiceDataProvider {
  const WarehouseCoeffsDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  // Subscribe method to add WarehouseCoeffs
  @override
  Future<Either<RewildError, void>> subscribe(
      WarehouseCoeffs warehouseCoeffs) async {
    try {
      final db = await _db;
      final txn = db.transaction('wh_coefficients_subs', idbModeReadWrite);
      final store = txn.objectStore('wh_coefficients_subs');
      await store.put(warehouseCoeffs.toMap());
      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to subscribe warehouse coefficients: $e",
        source: "WarehouseCoeffsDataProvider",
        name: "subscribe",
        args: [warehouseCoeffs],
        sendToTg: true,
      ));
    }
  }

  // Unsubscribe method to remove WarehouseCoeffs by warehouseId and boxTypeId
  Future<Either<RewildError, void>> unsubscribe(
      int warehouseId, int boxTypeId) async {
    try {
      final db = await _db;
      final txn = db.transaction('wh_coefficients_subs', idbModeReadWrite);
      final store = txn.objectStore('wh_coefficients_subs');
      final key = '${warehouseId}__$boxTypeId';
      await store.delete(key);
      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to unsubscribe warehouse coefficients: $e",
        source: "WarehouseCoeffsDataProvider",
        name: "unsubscribe",
        args: [warehouseId, boxTypeId],
        sendToTg: true,
      ));
    }
  }

  // Get all warehouse coefficients (optional utility function)
  Future<Either<RewildError, List<WarehouseCoeffs>>> getAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('wh_coefficients_subs', idbModeReadOnly);
      final store = txn.objectStore('wh_coefficients_subs');
      final result = await store.getAll();
      await txn.completed;

      // Map results to WarehouseCoeffs objects
      final coeffs = result
          .whereType<Map<String, dynamic>>()
          .map((item) => WarehouseCoeffs.fromJson(item))
          .toList();

      return right(coeffs);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve all warehouse coefficients: $e",
        source: "WarehouseCoeffsDataProvider",
        name: "getAll",
        args: [],
        sendToTg: true,
      ));
    }
  }
}
