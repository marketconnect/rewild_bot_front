import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/top_product.dart';
import 'package:rewild_bot_front/domain/services/top_products_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class TopProductsDataProvider
    implements
        UpdateServiceTopProductDataProvider,
        TopProductsServiceDataProvider {
  const TopProductsDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('top_products', idbModeReadWrite);
      final store = txn.objectStore('top_products');

      await store.clear();

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete all top products: ${e.toString()}",
        source: "TopProductsDataProvider",
        name: "deleteAll",
        args: [],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, List<TopProduct>>> getTodayForSubjectId(
      int subjectId) async {
    try {
      final db = await _db;
      final txn = db.transaction('top_products', idbModeReadOnly);
      final store = txn.objectStore('top_products');

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final index = store.index('subject_id');

      final result = await index.getAll(subjectId);

      final filtered = result
          .where((data) =>
              (data as Map<String, dynamic>)['last_updated'] == dateStr)
          .map((data) =>
              TopProduct.fromJson(Map<String, dynamic>.from(data as Map)))
          .toList();

      await txn.completed;

      return right(filtered);
    } catch (e) {
      return left(RewildError(
        "Failed to get top products for subjectId: ${e.toString()}",
        source: "TopProductsDataProvider",
        name: "getTodayForSubjectId",
        args: [subjectId],
        sendToTg: true,
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> insertAll(List<TopProduct> products) async {
    try {
      final db = await _db;
      final txn = db.transaction('top_products', idbModeReadWrite);
      final store = txn.objectStore('top_products');

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var product in products) {
        final data = {
          'sku': product.sku,
          'total_orders': product.totalOrders,
          'total_revenue': product.totalRevenue,
          'subject_id': product.subjectId,
          'name': product.name,
          'supplier': product.supplier,
          'review_rating': product.reviewRating,
          'feedbacks': product.feedbacks,
          'img': product.img,
          'last_updated': dateStr,
        };
        await store.put(data);
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to insert top products: ${e.toString()}",
        source: "TopProductsDataProvider",
        name: "insertAll",
        args: [products.map((p) => p.toJson()).toList()],
        sendToTg: true,
      ));
    }
  }
}
