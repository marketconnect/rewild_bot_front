import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subject_history.dart';
import 'package:rewild_bot_front/domain/services/top_products_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class SubjectHistoryDataProvider
    implements
        UpdateServiceSubjectsHistoryDataProvider,
        TopProductsServiceSubjectHistoryDataProvider {
  const SubjectHistoryDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('subject_history', idbModeReadWrite);
      final store = txn.objectStore('subject_history');

      await store.clear();

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete all subject histories: ${e.toString()}",
        source: "SubjectHistoryDataProvider",
        name: "deleteAll",
        args: [],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubjectHistory>>> getBySubjectId(
      int subjectId) async {
    try {
      final db = await _db;
      final txn = db.transaction('subject_history', idbModeReadOnly);
      final store = txn.objectStore('subject_history');
      final index = store.index('subject_id');

      final result = await index.getAll(subjectId);
      final filtered = result
          .map((data) =>
              SubjectHistory.fromMap(Map<String, dynamic>.from(data as Map)))
          .toList();

      await txn.completed;

      return right(filtered);
    } catch (e) {
      return left(RewildError(
        "Failed to get subject history for subjectId: ${e.toString()}",
        source: "SubjectHistoryDataProvider",
        name: "getBySubjectId",
        args: [subjectId],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> insertAll(
      List<SubjectHistory> histories) async {
    try {
      final db = await _db;
      final txn = db.transaction('subject_history', idbModeReadWrite);
      final store = txn.objectStore('subject_history');

      for (var history in histories) {
        await store.put(history.toMap());
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to insert subject histories: ${e.toString()}",
        source: "SubjectHistoryDataProvider",
        name: "insertAll",
        args: [histories.map((h) => h.toMap()).toList()],
        sendToTg: true,
      ));
    }
  }
}
