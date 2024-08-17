import 'package:fpdart/fpdart.dart';
import 'package:idb_shim/idb.dart';
import 'package:intl/intl.dart';

import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/tracking_query.dart';
import 'package:rewild_bot_front/domain/entities/tracking_result.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class TrackingResultDataProvider
    implements UpdateServiceTrackingResultDataProvider {
  const TrackingResultDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  Future<Either<RewildError, void>> addTrackingResult(
      TrackingResult trackingResult) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(trackingResult.date);

      final db = await _db;
      final txn = db.transaction('tracking_results', idbModeReadWrite);
      final store = txn.objectStore('tracking_results');

      await store.put({
        'keyword': trackingResult.keyword,
        'product_id': trackingResult.productId,
        'position': trackingResult.position,
        'date': dateString,
        'geo': trackingResult.geo,
      });

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to add tracking result: $e",
        source: "TrackingResultDataProvider",
        name: "addTrackingResult",
        args: [trackingResult],
        sendToTg: false,
      ));
    }
  }

  Future<Either<RewildError, List<TrackingResult>>>
      getAllTrackingResults() async {
    try {
      final db = await _db;
      final txn = db.transaction('tracking_results', idbModeReadOnly);
      final store = txn.objectStore('tracking_results');
      final result = await store.getAll();

      final List<TrackingResult> trackingResults = result.map((map) {
        final data = map as Map<String, dynamic>;
        return TrackingResult(
          id: data['id'] as int?,
          keyword: data['keyword'] as String,
          productId: data['product_id'] as int,
          position: data['position'] as int,
          geo: data['geo'] as String,
          date: DateTime.parse(data['date'] as String),
        );
      }).toList();

      await txn.completed;
      return right(trackingResults);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve tracking results: $e",
        source: "TrackingResultDataProvider",
        name: "getAllTrackingResults",
        sendToTg: false,
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteOldTrackingResults() async {
    try {
      final db = await _db;
      final txn = db.transaction('tracking_results', idbModeReadWrite);
      final store = txn.objectStore('tracking_results');

      DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 90));
      String oneMonthAgoStr = DateFormat('yyyy-MM-dd').format(oneMonthAgo);

      final index = store.index('date');
      final cursorStream = index.openCursor(
        range: KeyRange.upperBound(oneMonthAgoStr),
      );

      await for (final cursor in cursorStream) {
        await cursor.delete();
        cursor.next();
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete old tracking results: $e",
        source: "TrackingResultDataProvider",
        name: "deleteOldTrackingResults",
        sendToTg: false,
        args: [],
      ));
    }
  }

  Future<Either<RewildError, List<TrackingQuery>>>
      getKeywordsWithoutTodayEntries(List<TrackingQuery> queries) async {
    try {
      final db = await _db;
      final txn = db.transaction('tracking_results', idbModeReadOnly);
      final store = txn.objectStore('tracking_results');

      DateTime today = DateTime.now();
      String todayStr = DateFormat('yyyy-MM-dd').format(today);

      List<TrackingQuery> keywordsWithoutEntries = [];
      for (TrackingQuery query in queries) {
        final index = store.index('keyword_geo_date');
        final cursorStream = index.openCursor(
          range: KeyRange.only([query.query, query.geo, todayStr]),
        );

        bool hasEntry = false;
        // ignore: unused_local_variable
        await for (final cursor in cursorStream) {
          hasEntry = true;
          break;
        }

        if (!hasEntry) {
          keywordsWithoutEntries.add(query);
        }
      }

      await txn.completed;
      return right(keywordsWithoutEntries);
    } catch (e) {
      return left(RewildError(
        "Failed to get keywords without today's entries: $e",
        source: "TrackingResultDataProvider",
        name: "getKeywordsWithoutTodayEntries",
        sendToTg: false,
        args: [queries.map((query) => query.query).toList()],
      ));
    }
  }
}
