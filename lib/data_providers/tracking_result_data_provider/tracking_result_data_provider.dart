import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/constants/hive_boxes.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/tracking_query.dart';
import 'package:rewild_bot_front/domain/entities/hive/tracking_result.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class TrackingResultDataProvider
    implements UpdateServiceTrackingResultDataProvider {
  const TrackingResultDataProvider();

  Future<Box<TrackingResult>> _openBox() async {
    return await Hive.openBox<TrackingResult>(HiveBoxes.trackingResults);
  }

  @override
  Future<Either<RewildError, void>> addTrackingResult(
      TrackingResult trackingResult) async {
    try {
      final box = await _openBox();
      await box.add(trackingResult);
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

  @override
  Future<Either<RewildError, List<TrackingResult>>>
      getAllTrackingResults() async {
    try {
      final box = await _openBox();
      return right(box.values.toList());
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
      final box = await _openBox();
      DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 90));

      final oldResults = box.values.where((result) {
        return result.date.isBefore(oneMonthAgo);
      }).toList();

      for (var result in oldResults) {
        await result.delete();
      }

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

  @override
  Future<Either<RewildError, List<TrackingQuery>>>
      getKeywordsWithoutTodayEntries(List<TrackingQuery> queries) async {
    try {
      final box = await _openBox();
      DateTime today = DateTime.now();
      String todayStr = DateFormat('yyyy-MM-dd').format(today);

      List<TrackingQuery> keywordsWithoutEntries = [];
      for (TrackingQuery query in queries) {
        final results = box.values.where((result) {
          return result.geo == query.geo &&
              result.keyword == query.query &&
              DateFormat('yyyy-MM-dd').format(result.date) == todayStr;
        }).toList();
        if (results.isEmpty) {
          keywordsWithoutEntries.add(query);
        }
      }

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
