import 'package:fpdart/fpdart.dart';
import 'package:idb_shim/idb.dart';

import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CachedKwByAutocompliteDataProvider
    implements UpdateServiceKwByAutocompliteDataProvider {
  const CachedKwByAutocompliteDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> addAll(List<(String, int)> keywords) async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_kw_by_autocomplite', idbModeReadWrite);
      final store = txn.objectStore('cached_kw_by_autocomplite');

      for (var keyword in keywords) {
        await store.put({
          'keyword': keyword.$1,
          'freq': keyword.$2,
        }, keyword.$1);
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "addAll",
        source: "CachedKwByAutocompliteDataProvider",
        sendToTg: true,
        args: [keywords],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<(String, int)>>> getAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_kw_by_autocomplite', idbModeReadOnly);
      final store = txn.objectStore('cached_kw_by_autocomplite');

      final cursorStream = store.openCursor(autoAdvance: true);

      final List<(String, int)> keywords = [];

      await for (final cursor in cursorStream) {
        final value = cursor.value as Map<String, dynamic>;
        keywords.add((value['keyword'] as String, value['freq'] as int));
      }

      await txn.completed;
      return right(keywords);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "getAll",
        source: "CachedKwByAutocompliteDataProvider",
        sendToTg: true,
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_kw_by_autocomplite', idbModeReadWrite);
      final store = txn.objectStore('cached_kw_by_autocomplite');

      await store.clear();

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "deleteAll",
        source: "CachedKwByAutocompliteDataProvider",
        sendToTg: true,
        args: [],
      ));
    }
  }
}
