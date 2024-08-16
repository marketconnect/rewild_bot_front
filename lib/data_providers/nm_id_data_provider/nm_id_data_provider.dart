import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/nm_id.dart';

import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';

import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/domain/services/content_service.dart';

class NmIdDataProvider
    implements
        CardOfProductServiceNmIdDataProvider,
        ContentServiceNmIdDataProvider {
  const NmIdDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  // A method that retrieves all the nmIds from the nm_ids table.
  @override
  Future<Either<RewildError, List<NmId>>> getNmIds() async {
    try {
      final db = await _db;
      final txn = db.transaction('nm_ids', idbModeReadOnly);
      final store = txn.objectStore('nm_ids');
      final List<Object?> maps = await store.getAll();

      List<NmId> nmIds = maps.map((map) {
        final nmIdMap = map as Map<String, dynamic>;
        return NmId(
          nmId: nmIdMap['nmId'] as int,
        );
      }).toList();

      await txn.completed;
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

  // A method that inserts a NmId into the nm_ids table.
  @override
  Future<Either<RewildError, void>> insertNmId(NmId nmId) async {
    try {
      final db = await _db;
      final txn = db.transaction('nm_ids', idbModeReadWrite);
      final store = txn.objectStore('nm_ids');

      await store.put(nmId.toMap());
      await txn.completed;
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
