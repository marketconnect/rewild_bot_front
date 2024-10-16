import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/domain/entities/commission_model.dart';
import 'package:rewild_bot_front/domain/services/commission_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CommissionDataProvider
    implements
        CommissionServiceCommissionDataProvider,
        UpdateServiceCommissionDataProvider {
  const CommissionDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  // Method to get a commission by ID
  @override
  Future<Either<RewildError, CommissionModel?>> get({required int id}) async {
    try {
      final db = await _db;
      final txn = db.transaction('commissions', idbModeReadOnly);
      final store = txn.objectStore('commissions');
      final result = await store.getObject(id);

      await txn.completed;

      if (result == null) {
        return right(null);
      }

      final commission =
          CommissionModel.fromMap(result as Map<String, dynamic>);
      return right(commission);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Ошибка во время получения комиссии ${e.toString()}',
        source: "CommissionDataProvider",
        name: "get",
        args: [id],
      ));
    }
  }

  // Method to insert a commission into the commissions table
  @override
  Future<Either<RewildError, void>> insert(
      {required CommissionModel commission}) async {
    try {
      final db = await _db;
      final txn = db.transaction('commissions', idbModeReadWrite);
      final store = txn.objectStore('commissions');

      await store.put(commission.toMap());

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Ошибка во время добавления комиссии ${e.toString()}',
        source: "CommissionDataProvider",
        name: "insert",
        args: [commission],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('commissions', idbModeReadWrite);
      final store = txn.objectStore('commissions');

      final allCommissionsRequest = store.clear();

      await allCommissionsRequest;

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete old commissions: ${e.toString()}",
        source: "CommissionDataProvider",
        name: "deleteAll",
        args: [],
        sendToTg: true,
      ));
    }
  }
}
