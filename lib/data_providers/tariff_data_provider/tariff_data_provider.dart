import 'package:fpdart/fpdart.dart';
import 'package:idb_shim/idb.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/domain/entities/tariff_model.dart';
import 'package:rewild_bot_front/domain/services/tariff_service.dart';

import 'package:rewild_bot_front/domain/services/update_service.dart';

class TariffDataProvider
    implements
        UpdateServiceTariffDataProvider,
        TariffServiceTariffDataProvider {
  const TariffDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, List<TariffModel>>> getByStoreId(
      int storeId) async {
    try {
      final db = await _db;
      final txn = db.transaction('tariffs', idbModeReadOnly);
      final store = txn.objectStore('tariffs');

      // Get all tariffs and filter by storeId
      final result = await store.getAll() as List<Map<String, dynamic>>;
      await txn.completed;

      final tariffs = result
          .where((map) => map['storeId'] == storeId)
          .map((map) => TariffModel(
                storeId: map['storeId'] as int,
                wh: map['wh'] as String,
                coef: map['coef'] as int,
                type: map['type'] as String,
              ))
          .toList();

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
  Future<Either<RewildError, void>> insertAll(List<TariffModel> tariffs) async {
    try {
      final db = await _db;
      final txn = db.transaction('tariffs', idbModeReadWrite);
      final store = txn.objectStore('tariffs');

      for (var tariff in tariffs) {
        await store.put({
          'storeId': tariff.storeId,
          'wh': tariff.wh,
          'coef': tariff.coef,
          'type': tariff.type,
        });
      }

      await txn.completed;
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
