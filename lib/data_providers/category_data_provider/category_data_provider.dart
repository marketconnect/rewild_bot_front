import 'package:fpdart/fpdart.dart';
import 'package:idb_shim/idb.dart';
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/services/categories_and_subjects_sevice.dart';

class CategoryDataProvider
    implements CategoriesAndSubjectsServiceCategoriesDataProvider {
  const CategoryDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;
  @override
  Future<Either<RewildError, void>> updateAll(List<String> categories) async {
    try {
      final db = await _db;
      final txn = db.transaction('categories', idbModeReadWrite);
      final store = txn.objectStore('categories');

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Очищаем таблицу 'categories'
      await store.clear();

      // Добавляем новые категории
      for (var category in categories) {
        final data = {
          'categoryName': category,
          'updatedAt': dateStr,
        };
        await store.put(data);
      }

      await txn.completed;

      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to update all categories: $e",
        source: "CategoryDataProvider",
        name: "updateAll",
        args: [categories],
        sendToTg: true,
      ));
    }
  }

  @override
  @override
  Future<Either<RewildError, bool>> isUpdated() async {
    try {
      final db = await DatabaseHelper().database;
      final txn = db.transaction('categories', idbModeReadOnly);
      final store = txn.objectStore('categories');

      // Use the 'updatedAt' index
      final index = store.index('updatedAt');
      const keyRange = null; // Get all values
      const direction = idbDirectionPrev; // For descending order

      bool isUpdatedToday = false;

      await for (var cursor
          in index.openCursor(range: keyRange, direction: direction)) {
        final data = cursor.value as Map<String, dynamic>;
        final dateStr = data['updatedAt'] as String;
        final updatedAt =
            DateFormat('yyyy-MM-dd').parse(dateStr, true).toLocal();
        final today = DateTime.now();
        final isToday = (updatedAt.year == today.year &&
            updatedAt.month == today.month &&
            updatedAt.day == today.day);

        isUpdatedToday = isToday;
        break; // Only need to check the most recent record
      }

      await txn.completed;

      return right(isUpdatedToday);
    } catch (e) {
      return left(RewildError(
        "Failed to check if categories were updated today: $e",
        source: "CategoryDataProvider",
        name: "isUpdated",
        args: [],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<String>>> getAllCategories() async {
    try {
      final db = await _db;
      final txn = db.transaction('categories', idbModeReadOnly);
      final store = txn.objectStore('categories');

      List<String> categories = [];

      await for (var cursor in store.openCursor(autoAdvance: true)) {
        final data = cursor.value as Map<String, dynamic>;
        final categoryName = data['categoryName'] as String;
        categories.add(categoryName);
      }

      await txn.completed;

      return right(categories);
    } catch (e) {
      return left(RewildError(
        "Failed to get all categories: $e",
        source: "CategoryDataProvider",
        name: "getAllCategories",
        args: [],
        sendToTg: true,
      ));
    }
  }
}
