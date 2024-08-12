import 'package:hive/hive.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/kw_by_lemma.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CachedKwByLemmaDataProvider
    implements UpdateServiceKwByLemmaDataProvider {
  const CachedKwByLemmaDataProvider();

  Future<Box<KwByLemma>> _openBox() async {
    return await Hive.openBox<KwByLemma>('cached_kw_by_lemma');
  }

  @override
  Future<Either<RewildError, void>> insertAll(List<KwByLemma> lemmas) async {
    try {
      final box = await _openBox();

      for (var lemma in lemmas) {
        await box.put(lemma.lemmaID, lemma);
      }

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
  Future<Either<RewildError, List<KwByLemma>>> getByLemmaId(int lemmaID) async {
    try {
      final box = await _openBox();
      final lemma = box.get(lemmaID);

      if (lemma != null) {
        return right([lemma]);
      } else {
        return right([]);
      }
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "getByLemma",
        sendToTg: true,
        args: [lemmaID],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> deleteAll() async {
    try {
      final box = await _openBox();
      await box.clear();
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
