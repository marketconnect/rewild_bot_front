import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_autocomplite_keyword_screen/autocomplite_keyword_expansion_view_model.dart';

// suggestions
abstract class WBSearchSuggestionServiceApiClient {
  Future<Either<RewildError, List<String>>> fetchSuggestions({
    required String query,
    String gender = "common",
    String locale = "ru",
    String lang = "ru",
  });
}

// frequency
abstract class WbSearchSuggestionServiceSearchQueryApiClient {
  Future<Either<RewildError, List<(String, int)>>> getSearchQuery(
      {required String token, required List<String> queries});
}

// cache
abstract class WbSearchSuggestionServiceKwByAutocompliteDataProvider {
  Future<Either<RewildError, void>> addAll(List<(String, int)> keywords);
  Future<Either<RewildError, List<(String, int)>>> getAll();
}

class WBSearchSuggestionService
    implements
        // SeoCoreViewModelSearchSuggestionService
        AutocompliteKeywordExpansionSearchSuggestionService {
  final WBSearchSuggestionServiceApiClient apiClient;
  final WbSearchSuggestionServiceSearchQueryApiClient searchQueryApiClient;
  final WbSearchSuggestionServiceKwByAutocompliteDataProvider
      kwByAutocompliteDataProvider;
  const WBSearchSuggestionService(
      {required this.apiClient,
      required this.searchQueryApiClient,
      required this.kwByAutocompliteDataProvider});

  @override
  Future<Either<RewildError, List<String>>> fetchSuggestions({
    required String query,
  }) async {
    final suggestionsEither = await apiClient.fetchSuggestions(
      query: query,
    );
    if (suggestionsEither is Left) {
      return left(RewildError('err in fetchSuggestions',
          name: 'fetchSuggestions',
          sendToTg: true,
          source: "WbSearchSuggestionSevice"));
    }
    final suggestions =
        suggestionsEither.fold((l) => throw UnimplementedError(), (r) => r);

    return right(suggestions);
  }

  @override
  Future<Either<RewildError, List<(String, int)>>> fetchFrequency({
    required String? token,
    required List<String> keyPhrases,
  }) async {
    List<(String, int)> result = [];
    List<String> keyPhrasesToFetch = [];
    // get from cache
    final localFreqEither = await kwByAutocompliteDataProvider.getAll();
    if (localFreqEither is Left) {
      return left(RewildError('err in fetchFrequency',
          name: 'fetchFrequency',
          sendToTg: true,
          source: "WbSearchSuggestionSevice"));
    }
    final localDbFreq =
        localFreqEither.fold((l) => throw UnimplementedError(), (r) => r);
    result = localDbFreq;

    for (final keyPhrase in keyPhrases) {
      if (!result.any((element) => element.$1 == keyPhrase)) {
        keyPhrasesToFetch.add(keyPhrase);
      }
    }
    if (keyPhrasesToFetch.isEmpty) {
      return right(result);
    }
    if (token == null) {
      return right([]);
    }
    // get frequency
    final freqEither = await searchQueryApiClient.getSearchQuery(
        token: token, queries: keyPhrasesToFetch);

    if (freqEither is Left) {
      final result = keyPhrases.map((e) => (e, 0)).toList();
      return right(result);
    }

    final freq = freqEither.fold((l) => throw UnimplementedError(), (r) => r);
    // save to cache
    await kwByAutocompliteDataProvider.addAll(freq);
    result.addAll(freq);
    return right(result);
  }
}
