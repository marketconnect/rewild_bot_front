import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/filter_model.dart';

class FilterDataProvider {
  const FilterDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> insert(
      {required FilterModel filter}) async {
    try {
      final db = await _db;
      final txn = db.transaction('filters', idbModeReadWrite);
      final store = txn.objectStore('filters');

      // Insert subjects
      if (filter.subjects != null) {
        for (final subjId in filter.subjects!.keys) {
          await store.put({
            'sectionName': 'subjects',
            'itemId': subjId,
            'itemName': filter.subjects![subjId],
          });
        }
      }

      // Insert brands
      if (filter.brands != null) {
        for (final brandId in filter.brands!.keys) {
          await store.put({
            'sectionName': 'brands',
            'itemId': brandId,
            'itemName': filter.brands![brandId],
          });
        }
      }

      // Insert suppliers
      if (filter.suppliers != null) {
        for (final supplierId in filter.suppliers!.keys) {
          await store.put({
            'sectionName': 'suppliers',
            'itemId': supplierId,
            'itemName': filter.suppliers![supplierId],
          });
        }
      }

      // Insert promos
      if (filter.promos != null) {
        for (final promoId in filter.promos!.keys) {
          await store.put({
            'sectionName': 'promos',
            'itemId': promoId,
            'itemName': filter.promos![promoId],
          });
        }
      }

      // Insert withSales
      if (filter.withSales != null) {
        await store.put({
          'sectionName': 'withSales',
          'itemId': 1,
          'itemName': '', // Empty string as itemName since it is a boolean flag
        });
      }

      // Insert withStocks
      if (filter.withStocks != null) {
        await store.put({
          'sectionName': 'withStocks',
          'itemId': 1,
          'itemName': '', // Empty string as itemName since it is a boolean flag
        });
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "insert",
        args: [filter],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> delete() async {
    try {
      final db = await _db;
      final txn = db.transaction('filters', idbModeReadWrite);
      final store = txn.objectStore('filters');
      await store.clear();
      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "delete",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, FilterModel>> get() async {
    try {
      final db = await _db;
      final txn = db.transaction('filters', idbModeReadOnly);
      final store = txn.objectStore('filters');
      final result = await store.getAll();

      if (result.isEmpty) {
        return right(FilterModel.empty());
      }

      Map<int, String> subjects = {};
      Map<int, String> brands = {};
      Map<int, String> suppliers = {};
      Map<int, String> promos = {};
      bool? withSales;
      bool? withStocks;

      for (final item in result) {
        final row = item
            as Map<String, dynamic>; // Cast each item to Map<String, dynamic>

        final itemId = row['itemId'] as int?;
        final itemName = row['itemName'] as String?;
        if (itemId == null || itemName == null) {
          continue;
        }
        if (row['sectionName'] == 'subjects') {
          subjects[itemId] = itemName;
        }
        if (row['sectionName'] == 'brands') {
          brands[itemId] = itemName;
        }
        if (row['sectionName'] == 'suppliers') {
          suppliers[itemId] = itemName;
        }
        if (row['sectionName'] == 'promos') {
          promos[itemId] = itemName;
        }
        if (row['sectionName'] == 'withSales') {
          withSales = true;
        }
        if (row['sectionName'] == 'withStocks') {
          withStocks = true;
        }
      }

      final newFilter = FilterModel(
        brands: brands,
        promos: promos,
        subjects: subjects,
        suppliers: suppliers,
        withSales: withSales,
        withStocks: withStocks,
      );

      await txn.completed;
      return right(newFilter);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: "get",
        args: [],
      ));
    }
  }
}
