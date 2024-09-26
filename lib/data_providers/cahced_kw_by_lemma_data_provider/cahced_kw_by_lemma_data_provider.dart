import 'package:fpdart/fpdart.dart';
import 'package:idb_shim/idb.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/services/filter_values_service.dart';

import 'package:rewild_bot_front/domain/services/update_service.dart';

class CachedKwByLemmaDataProvider
    implements
        UpdateServiceKwByLemmaDataProvider,
        FilterServiceKwByLemmaDataProvider {
  const CachedKwByLemmaDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> insertAll(List<KwByLemma> lemmas) async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_kw_by_lemma', idbModeReadWrite);
      final store = txn.objectStore('cached_kw_by_lemma');

      for (var lemma in lemmas) {
        await store.put({
          'lemmaID': lemma.lemmaID,
          'lemma': lemma.lemma,
          'keyword': lemma.keyword,
          'freq': lemma.freq,
          'lemmaID_keyword': '${lemma.lemmaID}_${lemma.keyword}',
        });
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "insertAll",
        source: "CachedKwByLemmaDataProvider",
        sendToTg: true,
        args: [lemmas],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<KwByLemma>>> getByLemmaId(int lemmaID) async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_kw_by_lemma', idbModeReadOnly);
      final store = txn.objectStore('cached_kw_by_lemma');

      // Use IDBKeyRange to create a key range for lemmaID
      final range = KeyRange.only(lemmaID); // Corrected KeyRange usage
      final cursorStream = store.openCursor(range: range);

      final List<KwByLemma> lemmas = [];

      await cursorStream.forEach((cursor) {
        final value = cursor.value as Map<String, dynamic>;
        lemmas.add(KwByLemma(
          lemmaID: value['lemmaID'] as int,
          lemma: value['lemma'] as String,
          keyword: value['keyword'] as String,
          freq: value['freq'] as int,
        ));
        cursor.next();
      });

      await txn.completed;
      return right(lemmas);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "getByLemmaId",
        source: "CachedKwByLemmaDataProvider",
        sendToTg: true,
        args: [lemmaID],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_kw_by_lemma', idbModeReadWrite);
      final store = txn.objectStore('cached_kw_by_lemma');

      await store.clear();
      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "deleteAll",
        source: "CachedKwByLemmaDataProvider",
        sendToTg: true,
        args: [],
      ));
    }
  }
}
