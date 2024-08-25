import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:idb_shim/idb.dart';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/domain/services/filter_values_service.dart';

class FilterValuesDataProvider implements FilterServiceFilterDataProvider {
  const FilterValuesDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> insert(
      String filterName, List<String> values) async {
    try {
      final String updatedAt =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final db = await _db;
      final txn = db.transaction('filterValues', idbModeReadWrite);
      final store = txn.objectStore('filterValues');

      for (var value in values) {
        await store.put(
          {
            'filterName': filterName,
            'value': value,
            'updatedAt': updatedAt,
          },
        );
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "insert",
        sendToTg: true,
        args: [filterName, values],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<String>>> getAllForFilterName(
      String filterName) async {
    try {
      final db = await _db;
      final txn = db.transaction('filterValues', idbModeReadOnly);
      final store = txn.objectStore('filterValues');

      final index = store.index('filterName');
      final range = KeyRange.only(filterName);
      final results = await index.getAll(range);

      List<String> values = results
          .map((result) => (result as Map<String, dynamic>)['value'] as String)
          .toList();

      await txn.completed;
      return right(values);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "getAllForFilterName",
        sendToTg: true,
        args: [filterName],
      ));
    }
  }

  Future<Either<RewildError, void>> deleteOld() async {
    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final db = await _db;
      final txn = db.transaction('filterValues', idbModeReadWrite);
      final store = txn.objectStore('filterValues');
      final index = store.index('updatedAt');

      final range = KeyRange.upperBound("$today 00:00:00");
      final cursorStream = index.openCursor(range: range);

      await for (final cursor in cursorStream) {
        await cursor.delete();
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "deleteOld",
        sendToTg: true,
        args: [],
      ));
    }
  }
}
