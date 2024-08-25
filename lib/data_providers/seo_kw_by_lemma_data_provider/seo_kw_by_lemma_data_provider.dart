import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/services/seo_service.dart';

class SeoKwByLemmaDataProvider implements SeoServiceSeoKwByLemmaDataProvider {
  const SeoKwByLemmaDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  @override
  Future<Either<RewildError, void>> insertAll(
      int nmId, List<KwByLemma> lemmas) async {
    try {
      final db = await _db;
      final txn = db.transaction('seo_kw_by_lemma', idbModeReadWrite);
      final store = txn.objectStore('seo_kw_by_lemma');

      for (KwByLemma lemma in lemmas) {
        await store.put({
          'nmId': nmId,
          'lemma': lemma.lemma,
          'freq': lemma.freq,
          'keyword': lemma.keyword,
          'lemmaID': lemma.lemmaID,
        });
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to insert SEO keywords by lemma: ${e.toString()}",
        name: "insertAll",
        sendToTg: true,
        args: [nmId, lemmas],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteForNmID(int nmId) async {
    try {
      final db = await _db;
      final txn = db.transaction('seo_kw_by_lemma', idbModeReadWrite);
      final store = txn.objectStore('seo_kw_by_lemma');

      final index = store.index('nmId');
      final range = KeyRange.only(nmId);
      final cursorStream = index.openCursor(
          range: range); // Указываем именованный параметр range

      await for (final cursor in cursorStream) {
        await cursor.delete();
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        "Failed to delete SEO keywords for nmId: ${e.toString()}",
        name: "deleteForNmID",
        sendToTg: true,
        args: [nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<KwByLemma>>> getForNmId(int nmId) async {
    try {
      final db = await _db;
      final txn = db.transaction('seo_kw_by_lemma', idbModeReadOnly);
      final store = txn.objectStore('seo_kw_by_lemma');

      final index = store.index('nmId');
      final range = KeyRange.only(nmId);
      final results = await index.getAll(range);

      List<KwByLemma> lemmas = results.map((result) {
        final map = result as Map<String, dynamic>;
        return KwByLemma(
          lemma: map['lemma'],
          freq: map['freq'],
          keyword: map['keyword'],
          lemmaID: map['lemmaID'],
        );
      }).toList();

      await txn.completed;
      return right(lemmas);
    } catch (e) {
      return left(RewildError(
        "Failed to retrieve SEO keywords for nmId: ${e.toString()}",
        name: "getForNmId",
        sendToTg: true,
        args: [nmId],
      ));
    }
  }
}
