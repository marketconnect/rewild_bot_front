import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/presentation/products/cards/single_card_screen/single_card_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_competitor_keyword_screen/competitor_keyword_expansion_model.dart';

// API client
abstract class CardKeywordsServiceApiClient {
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsForProducts(
      {required String token, required List<int> skus});
}

// Data provider
abstract class CardKeywordsServiceCardKeywordsDataProvider {
  Future<Either<RewildError, void>> insert(
      int cardId, List<(String keyword, int freq)> keywords);

  Future<Either<RewildError, List<(String keyword, int freq)>>>
      getKeywordsByCardId(int cardId);
}

class CardKeywordsService
    implements
        CompetitorKeywordExpansionCardKeywordsService,
        SingleCardCardKeywordsService {
  final CardKeywordsServiceApiClient apiClient;
  final CardKeywordsServiceCardKeywordsDataProvider cardKeywordsDataProvider;
  const CardKeywordsService(
      {required this.apiClient, required this.cardKeywordsDataProvider});

  @override
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsForCards(
      {required String token, required List<int> skus}) async {
    List<KwByLemma> keywords = [];
    List<int> skusForRequest = [];

    // try to get keywords from local storage
    // for each sku
    for (int sku in skus) {
      // get keywords from local storage
      final localKeywordsEither =
          await cardKeywordsDataProvider.getKeywordsByCardId(sku);
      if (localKeywordsEither.isRight()) {
        final localKeywords = localKeywordsEither.fold(
            (l) => throw UnimplementedError(), (r) => r);
        if (localKeywords.isNotEmpty) {
          // if local storage contains keywords for this sku
          final kwByLemmas = localKeywords.map((e) => KwByLemma.fromKwFreq(
                keyword: e.$1,
                freq: e.$2,
                sku: sku,
              ));
          keywords.addAll(kwByLemmas);
        } else {
          // if local storage doesn't contain keywords for this sku
          // we will request keywords from Server
          skusForRequest.add(sku);
        }
      }
    }

    if (skusForRequest.isEmpty) {
      List<KwByLemma> uniqueKwByLemmas = removeDuplicates(keywords);
      return right(uniqueKwByLemmas);
    }

    final keywordsFromServerEither = await apiClient.getKeywordsForProducts(
        token: token, skus: skusForRequest);
    if (keywordsFromServerEither.isLeft()) {
      return keywordsFromServerEither;
    }
    // save keywords to local storage
    if (keywordsFromServerEither.isRight()) {
      final keywordsFromServer = keywordsFromServerEither.fold(
          (l) => throw UnimplementedError(), (r) => r);
      // save keywords to local storage
      for (final sku in skusForRequest) {
        final kwByLemmas = keywordsFromServer.where((e) => e.sku == sku);
        if (kwByLemmas.isNotEmpty) {
          await cardKeywordsDataProvider.insert(
              sku, kwByLemmas.map((e) => (e.keyword, e.freq)).toList());
        }
      }
      keywords.addAll(keywordsFromServer);
    }

    // Remove duplicates
    List<KwByLemma> uniqueKwByLemmas = removeDuplicates(keywords);

    return right(uniqueKwByLemmas);
  }

  List<KwByLemma> removeDuplicates(List<KwByLemma> keywords) {
    final uniqueKeywords = <String>{};
    final uniqueKwByLemmas = <KwByLemma>[];
    for (final kw in keywords) {
      if (uniqueKeywords.add(kw.keyword)) {
        uniqueKwByLemmas.add(kw);
      }
    }
    return uniqueKwByLemmas;
  }
}
