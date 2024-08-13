import 'package:hive/hive.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/kw_by_lemma.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CachedKwByWordDataProvider
    implements UpdateServiceKwByLemmaByWordDataProvider {
  const CachedKwByWordDataProvider();

  Future<Box<KwByLemma>> _openBox() async {
    return await Hive.openBox<KwByLemma>('cached_kw_by_word');
  }

  @override
  Future<Either<RewildError, void>> insertAll(List<KwByLemma> lemmas) async {
    try {
      final box = await _openBox();

      for (var lemma in lemmas) {
        // Используем уникальное сочетание 'lemma' и 'keyword' для ключа, если нужно
        final key = '${lemma.lemma}_${lemma.keyword}';
        await box.put(key, lemma);
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
  Future<Either<RewildError, List<KwByLemma>>> getByWord(String word) async {
    try {
      final box = await _openBox();
      final lemmas = box.values.where((lemma) => lemma.lemma == word).toList();

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
