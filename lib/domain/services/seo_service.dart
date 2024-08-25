import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/presentation/seo_tool_screen/seo_tool_kw_research_view_model.dart';

abstract class SeoServiceSeoKwByLemmaDataProvider {
  Future<Either<RewildError, void>> insertAll(int nmId, List<KwByLemma> lemmas);
  Future<Either<RewildError, List<KwByLemma>>> getForNmId(int nmId);
  Future<Either<RewildError, void>> deleteForNmID(int nmId);
}

class SeoService implements SeoToolSeoService {
  // final SeoServiceLemmaDataProvider seoServiceDataProvider;
  final SeoServiceSeoKwByLemmaDataProvider seoServiceSeoKwByLemmaDataProvider;
  const SeoService(
      {
      // required this.seoServiceDataProvider,
      required this.seoServiceSeoKwByLemmaDataProvider});

  // @override
  // Future<Either<RewildError, void>> addAllLemmas(
  //     int nmId, List<String> lemmas) async {
  //   final deleteAllEither = await seoServiceDataProvider.deleteAllForNmID(nmId);
  //   if (deleteAllEither.isLeft()) {
  //     return deleteAllEither;
  //   }

  //   return seoServiceDataProvider.addAll(nmId, lemmas);
  // }

  // @override
  // Future<Either<RewildError, List<String>>> getAllLemmasForNmID(int nmId) {
  //   return seoServiceDataProvider.getAllForNmID(nmId);
  // }

  // get all kw for nmId
  @override
  Future<Either<RewildError, List<KwByLemma>>> getPhrasesForNmId(
      int nmId) async {
    return seoServiceSeoKwByLemmaDataProvider.getForNmId(nmId);
  }

  // save all kw for nmId
  @override
  Future<Either<RewildError, void>> savePhrasesForNmId(
      int nmId, List<KwByLemma> kw) async {
    final deleteEither =
        await seoServiceSeoKwByLemmaDataProvider.deleteForNmID(nmId);
    if (deleteEither.isLeft()) {
      return deleteEither;
    }
    return seoServiceSeoKwByLemmaDataProvider.insertAll(nmId, kw);
  }
}
