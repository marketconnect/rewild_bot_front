import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/lemma_by_filter_id.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CachedLemmaDataProvider implements UpdateServiceLemmaDataProvider {
  const CachedLemmaDataProvider();

  Future<Box<LemmaByFilterId>> _openBox() async {
    return await Hive.openBox<LemmaByFilterId>('cached_lemmas');
  }

  @override
  Future<Either<RewildError, void>> addAll(
      int subjectId, List<LemmaByFilterId> lemmas) async {
    try {
      final box = await _openBox();

      for (var lemma in lemmas) {
        await box.put('${subjectId}_${lemma.lemmaId}', lemma);
      }

      return right(null);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "addAll",
        sendToTg: true,
        args: [subjectId, lemmas],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<LemmaByFilterId>>> getAllForSubjectID(
      int subjectId) async {
    try {
      final box = await _openBox();
      final lemmas =
          box.values.where((lemma) => lemma.lemmaId == subjectId).toList();
      return right(lemmas);
    } catch (e) {
      return left(RewildError(
        e.toString(),
        name: "getAllForSubjectID",
        sendToTg: true,
        args: [subjectId],
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
