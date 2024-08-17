import 'package:idb_shim/idb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/database_helper.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/lemma_by_filter.dart';

import 'package:rewild_bot_front/domain/services/update_service.dart';

class CachedLemmaDataProvider implements UpdateServiceLemmaDataProvider {
  const CachedLemmaDataProvider();

  Future<Database> get _db async => await DatabaseHelper().database;

  Future<Either<RewildError, void>> addAll(
      int subjectId, List<LemmaByFilterId> lemmas) async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_lemmas', idbModeReadWrite);
      final store = txn.objectStore('cached_lemmas');

      for (var lemma in lemmas) {
        await store.put({
          'subjectId': subjectId,
          'lemmaId': lemma.lemmaId,
          'lemma': lemma.lemma,
          'totalFrequency': lemma.totalFrequency,
        });
      }

      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "addAll",
        source: "CachedLemmaDataProvider",
        sendToTg: true,
        args: [subjectId, lemmas],
      ));
    }
  }

  Future<Either<RewildError, List<LemmaByFilterId>>> getAllForSubjectID(
      int subjectId) async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_lemmas', idbModeReadOnly);
      final store = txn.objectStore('cached_lemmas');
      final index = store.index('subjectId'); // Используем новый индекс

      final lemmas = <LemmaByFilterId>[];
      final cursorStream = index.openCursor(key: subjectId);

      await for (final cursor in cursorStream) {
        final value = cursor.value as Map<String, dynamic>;
        lemmas.add(LemmaByFilterId(
          lemmaId: value['lemmaId'] as int,
          lemma: value['lemma'] as String,
          totalFrequency: value['totalFrequency'] as int,
        ));
        cursor.next();
      }

      await txn.completed;
      return right(lemmas);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "getAllForSubjectID",
        source: "CachedLemmaDataProvider",
        sendToTg: true,
        args: [subjectId],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final db = await _db;
      final txn = db.transaction('cached_lemmas', idbModeReadWrite);
      final store = txn.objectStore('cached_lemmas');
      await store.clear();
      await txn.completed;
      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "deleteAll",
        source: "CachedLemmaDataProvider",
        sendToTg: true,
        args: [],
      ));
    }
  }
}
