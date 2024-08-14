import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CachedKwByWordDataProvider
    implements UpdateServiceKwByLemmaByWordDataProvider {
  const CachedKwByWordDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> insertAll(List<KwByLemma> lemmas) async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_kw_by_word', idbModeReadWrite);
      final store = txn.objectStore('cached_kw_by_word');

      for (var lemma in lemmas) {
        await store.put({
          'lemmaID': lemma.lemmaID,
          'lemma': lemma.lemma,
          'keyword': lemma.keyword,
          'freq': lemma.freq,
        });
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "insertAll",
        sendToTg: true,
        args: [lemmas],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<KwByLemma>>> getByWord(String word) async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_kw_by_word', idbModeReadOnly);
      final store = txn.objectStore('cached_kw_by_word');

      final index =
          store.index('lemma'); // Assuming an index on 'lemma' is created
      final range = KeyRange.only(word);
      final cursorStream = index.openCursor(range: range);

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
        name: "getByWord",
        sendToTg: true,
        args: [word],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_kw_by_word', idbModeReadWrite);
      final store = txn.objectStore('cached_kw_by_word');

      await store.clear();
      await txn.completed;

      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "deleteAll",
        sendToTg: true,
        args: [],
      ));
    }
  }
}
