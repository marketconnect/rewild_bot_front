import 'package:fpdart/fpdart.dart';
import 'package:idb_shim/idb.dart';
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subject_commission_model.dart';
import 'package:rewild_bot_front/domain/services/categories_and_subjects_sevice.dart';

class SubjectCommissionDataProvider
    implements CategoriesAndSubjectsServiceSubjectsDataProvider {
  const SubjectCommissionDataProvider();
  Future<Database> get _db async => await DatabaseHelper().database;
  @override
  Future<Either<RewildError, bool>> isUpdated(String catName) async {
    try {
      final db = await DatabaseHelper().database;
      final txn = db.transaction('subject_commissions', idbModeReadOnly);
      final store = txn.objectStore('subject_commissions');

      final index = store.index('catName');
      final keyRange = KeyRange.only(catName);

      bool isUpdatedToday = false;

      // Use 'await for' to iterate over the cursor
      await for (var cursor in index.openCursor(range: keyRange)) {
        final data = cursor.value as Map<String, dynamic>;
        final dateStr = data['createdAt'] as String;
        final updatedAt =
            DateFormat('yyyy-MM-dd').parse(dateStr, true).toLocal();
        final today = DateTime.now();
        final isToday = (updatedAt.year == today.year &&
            updatedAt.month == today.month &&
            updatedAt.day == today.day);

        if (isToday) {
          isUpdatedToday = true;
          break; // Exit the loop if the condition is met
        }
      }

      await txn.completed;

      return right(isUpdatedToday);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve subject commission: ${e.toString()}",
        source: "SubjectCommissionDataProvider",
        name: "isUpdated",
        args: [],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubjectCommissionModel>>> getAllForCatName(
      String catName) async {
    try {
      final db = await _db;
      final txn = db.transaction('subject_commissions', idbModeReadOnly);
      final store = txn.objectStore('subject_commissions');

      final index = store.index('catName');
      final keyRange = KeyRange.only(catName);
      final request = index.openCursor(range: keyRange);

      List<SubjectCommissionModel> models = [];

      await request.forEach((cursor) {
        final data = cursor.value as Map<String, dynamic>;
        models.add(SubjectCommissionModel.fromMap(data));
        cursor.next();
      });

      await txn.completed;

      return right(models);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve subject commissions: ${e.toString()}",
        source: "SubjectCommissionDataProvider",
        name: "getAllForCatName",
        args: [],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> insertAll(
      List<SubjectCommissionModel> models) async {
    try {
      final db = await _db;
      final txn = db.transaction('subject_commissions', idbModeReadWrite);
      final store = txn.objectStore('subject_commissions');

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var model in models) {
        final data = {
          'id': model.id,
          'catName': model.catName,
          'isKiz': model.isKiz ? 1 : 0,
          'commission': model.commission,
          'createdAt': dateStr,
        };
        await store.put(data);
      }

      await txn.completed;

      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to insert subject commission: ${e.toString()}",
        source: "SubjectCommissionDataProvider",
        name: "insertAll",
        args: [models.map((m) => m.toJson()).toList()],
        sendToTg: true,
      ));
    }
  }
}
