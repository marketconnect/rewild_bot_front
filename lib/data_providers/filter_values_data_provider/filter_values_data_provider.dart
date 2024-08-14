import 'package:fpdart/fpdart.dart';
import 'package:idb_shim/idb.dart';
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class FilterValuesDataProvider implements UpdateServiceFilterDataProvider {
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
        await store.put({
          'filterName': filterName,
          'value': value,
          'updatedAt': updatedAt,
        });
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

      final List<String> values = [];

      final cursorStream = index.openCursor(key: filterName);

      await for (final cursor in cursorStream) {
        final valueMap = cursor.value as Map<String, dynamic>;
        final value = valueMap['value'] as String;
        values.add(value);
        cursor.next();
      }

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

  @override
  Future<Either<RewildError, void>> deleteOld() async {
    try {
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final db = await _db;
      final txn = db.transaction('filterValues', idbModeReadWrite);
      final store = txn.objectStore('filterValues');
      final index = store.index('updatedAt');

      final cursorStream = index.openCursor(
        range: KeyRange.upperBound("$today 00:00:00"),
      );

      await for (final cursor in cursorStream) {
        await cursor.delete();
        cursor.next();
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
