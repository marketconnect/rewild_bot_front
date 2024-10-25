import 'package:fpdart/fpdart.dart';

import 'package:idb_shim/idb.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/tracking_query.dart';
import 'package:rewild_bot_front/domain/services/tracking_service.dart';

class TrackingQueryDataProvider implements TrackingServiceQueryDataProvider {
  const TrackingQueryDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> addQuery(TrackingQuery query) async {
    try {
      final db = await _db;
      final txn = db.transaction('tracking_queries', idbModeReadWrite);
      final store = txn.objectStore('tracking_queries');

      final Map<String, dynamic> queryMap = {
        'query': query.query,
        'nmId': query.nmId,
        'geo': query.geo,
      };

      await store.put(queryMap);

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to add query: $e",
        source: "TrackingQueryDataProvider",
        name: "addQuery",
        args: [query.query, query.geo],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<TrackingQuery>>> getAllQueries(
      int nmId) async {
    try {
      final db = await _db;
      final txn = db.transaction('tracking_queries', idbModeReadOnly);
      final store = txn.objectStore('tracking_queries');

      final index = store.index('nmId');
      final range = KeyRange.only(nmId);
      final results = await index.getAll(range);

      List<TrackingQuery> queries = results
          .map(
              (result) => TrackingQuery.fromMap(result as Map<String, dynamic>))
          .toList();

      await txn.completed;
      return right(queries);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve queries: $e",
        source: "TrackingQueryDataProvider",
        name: "getAllQueries",
        args: [],
        sendToTg: true,
      ));
    }
  }

  @override
  @override
  Future<Either<RewildError, void>> deleteAllQueryForNmId(int nmId) async {
    try {
      final db = await _db;
      final txn = db.transaction('tracking_queries', idbModeReadWrite);
      final store = txn.objectStore('tracking_queries');

      final index = store.index('nmId');
      final range = KeyRange.only(nmId);

      final keys = await index.getAllKeys(range);

      if (keys.isNotEmpty) {
        for (final key in keys) {
          await store.delete(key);
        }
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete queries: $e",
        source: "TrackingQueryDataProvider",
        name: "deleteAllQueryForNmId",
        args: [nmId],
        sendToTg: true,
      ));
    }
  }

  static Future<Either<RewildError, List<TrackingQuery>>>
      getAllQueriesInBg() async {
    try {
      final db = await DatabaseHelper().database;
      final txn = db.transaction('tracking_queries', idbModeReadOnly);
      final store = txn.objectStore('tracking_queries');
      final results = await store.getAll();

      List<TrackingQuery> queries = results
          .map(
              (result) => TrackingQuery.fromMap(result as Map<String, dynamic>))
          .toList();

      await txn.completed;
      return right(queries);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve queries: $e",
        source: "TrackingQueryDataProvider",
        name: "getAllQueriesInBg",
        args: [],
        sendToTg: true,
      ));
    }
  }
}
