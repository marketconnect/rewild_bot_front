import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/tracking_query.dart';

class TrackingQueryDataProvider {
  const TrackingQueryDataProvider();

  Future<Box<TrackingQuery>> _openBox() async {
    return await Hive.openBox<TrackingQuery>(HiveBoxes.trackingQueries);
  }

  @override
  Future<Either<RewildError, void>> addQuery(TrackingQuery query) async {
    try {
      final box = await _openBox();
      await box.add(query);
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to add query: $e",
        source: "TrackingQueryDataProvider",
        name: "addQuery",
        args: [query.query, query.geo],
        sendToTg: false,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<TrackingQuery>>> getAllQueries(
      int nmId) async {
    try {
      final box = await _openBox();
      final queries = box.values.where((query) => query.nmId == nmId).toList();
      return right(queries);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve queries: $e",
        source: "TrackingQueryDataProvider",
        name: "getAllQueries",
        args: [],
        sendToTg: false,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAllQueryForNmId(int nmId) async {
    try {
      final box = await _openBox();
      final queriesToDelete = box.values.where((query) => query.nmId == nmId);
      for (var query in queriesToDelete) {
        await query.delete();
      }
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete queries for nmId $nmId: $e",
        source: "TrackingQueryDataProvider",
        name: "deleteAllQueryForNmId",
        args: [nmId],
        sendToTg: false,
      ));
    }
  }

  static Future<Either<RewildError, List<TrackingQuery>>>
      getAllQueriesInBg() async {
    try {
      final box = await Hive.openBox<TrackingQuery>('tracking_queries');
      final queries = box.values.toList();
      return right(queries);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve queries: $e",
        source: "TrackingQueryDataProvider",
        name: "getAllQueriesInBg",
        args: [],
        sendToTg: false,
      ));
    }
  }
}
