import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subject_model.dart';
import 'package:rewild_bot_front/domain/services/stats_service.dart';

class SubjectDataProvider implements StatsServiceSubjectDataProvider {
  const SubjectDataProvider();
  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> updateAll(
      List<SubjectModel> subjects) async {
    try {
      final db = await _db;
      final txn = db.transaction('subjects', idbModeReadWrite);
      final store = txn.objectStore('subjects');

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var subject in subjects) {
        final data = {
          'subjectId': subject.subjectId,
          'name': subject.name,
          'total_revenue': subject.totalRevenue,
          'total_orders': subject.totalOrders,
          'total_skus': subject.totalSkus,
          'percentage_skus_without_orders': subject.percentageSkusWithoutOrders,
          'total_volume': subject.totalVolume,
          'cpm_average': subject.cpmAverage,
          'updatedAt': dateStr,
        };
        await store.put(data);
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to update all subjects: ${e.toString()}",
        source: "SubjectDataProvider",
        name: "updateAll",
        args: [subjects.map((s) => s.toJson()).toList()],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, SubjectModel?>> getOne(int subjectId) async {
    try {
      final db = await _db;
      final txn = db.transaction('subjects', idbModeReadOnly);
      final store = txn.objectStore('subjects');

      final data = await store.getObject(subjectId);

      await txn.completed;

      if (data != null) {
        if (data is Map<String, dynamic>) {
          // Data is already of the correct type
          final subject = SubjectModel.fromJson(data);
          return right(subject);
        } else if (data is Map) {
          // Data is a Map but not Map<String, dynamic>, so we cast it
          final subject =
              SubjectModel.fromJson(Map<String, dynamic>.from(data));

          return right(subject);
        } else {
          // Data is not a Map, cannot proceed
          return left(RewildError(
            "Data retrieved is not a Map",
            source: "SubjectDataProvider",
            name: "getOne",
            args: [subjectId],
            sendToTg: true,
          ));
        }
      } else {
        return right(null);
      }
    } catch (e) {
      return left(RewildError(
        "Failed to get subject: ${e.toString()}",
        source: "SubjectDataProvider",
        name: "getOne",
        args: [subjectId],
        sendToTg: true,
      ));
    }
  }
}
