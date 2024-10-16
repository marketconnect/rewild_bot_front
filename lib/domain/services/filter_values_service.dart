import 'package:fpdart/fpdart.dart';
// import 'package:rewild_bot_front/.env.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/entities/lemma_by_filter.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_subject_keyword_screen/subject_keyword_expansion_model.dart';
import 'package:rewild_bot_front/presentation/products/seo/expansion_words_keyword_screen/words_keyword_expansion_model.dart';

// Api
abstract class FilterServiceFilterApiClient {
  // Future<Either<RewildError, List<String>>> getFilterValues(
  //     {required String token, required String filterName});
  Future<Either<RewildError, List<LemmaByFilterId>>> getLemmasByFilterId({
    required String token,
    required int filterID,
    int limit = 100,
    int offset = 0,
  });
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsByLemmas(
      {required String token,
      required List<int> lemmasIDs,
      required int filterID});
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsByWords(
      {required String token, required List<String> words});
}

// Data provider
abstract class FilterServiceFilterDataProvider {
  Future<Either<RewildError, void>> insert(
      String filterName, List<String> values);
  Future<Either<RewildError, List<String>>> getAllForFilterName(
      String filterName);
}

// Cached lemmas data provider
abstract class FilterServiceLemmaDataProvider {
  Future<Either<RewildError, void>> addAll(
      int subjectId, List<LemmaByFilterId> lemmas);
  Future<Either<RewildError, List<LemmaByFilterId>>> getAllForSubjectID(
      int subjectId);
}

// Cached Kw by lemmas data provider
abstract class FilterServiceKwByLemmaDataProvider {
  Future<Either<RewildError, List<KwByLemma>>> getByLemmaId(int lemmaID);
  Future<Either<RewildError, void>> insertAll(List<KwByLemma> lemmas);
}

// Cached Kw by words data provider
abstract class FilterServiceCachedKwByWordDataProvider {
  Future<Either<RewildError, void>> insertAll(List<KwByLemma> lemmas);
  Future<Either<RewildError, List<KwByLemma>>> getByWord(String word);
}

class FilterValuesService
    implements
        WordsKeywordExpansionFilterValuesService,
        SubjectKeywordExpansionFilterValuesService {
  final FilterServiceFilterApiClient filterApiClient;
  // final FilterServiceFilterDataProvider filterDataProvider;
  final FilterServiceLemmaDataProvider lemmaDataProvider;
  final FilterServiceKwByLemmaDataProvider kwByLemmaDataProvider;
  final FilterServiceCachedKwByWordDataProvider cachedKwByWordDataProvider;
  const FilterValuesService({
    required this.filterApiClient,
    // required this.filterDataProvider,
    required this.lemmaDataProvider,
    required this.kwByLemmaDataProvider,
    required this.cachedKwByWordDataProvider,
  });

  // Future<Either<RewildError, List<String>>> getFilterValues(
  //     {required String token, required String filterName}) async {
  //   // get from local db
  //   final localDbValuesEither = await filterDataProvider.getAllForFilterName(
  //     filterName,
  //   );
  //   if (localDbValuesEither.isLeft()) {
  //     return left(localDbValuesEither.fold(
  //         (l) => l, (r) => throw UnimplementedError()));
  //   }
  //   final localDbValues =
  //       localDbValuesEither.fold((l) => throw UnimplementedError(), (r) => r);
  //   if (localDbValues.isNotEmpty) {
  //     return right(localDbValues);
  //   }

  //   // get filter values from server
  //   final filterValuesEither = await filterApiClient.getFilterValues(
  //       token: token, filterName: filterName);
  //   if (filterValuesEither.isLeft()) {
  //     return left(
  //         filterValuesEither.fold((l) => l, (r) => throw UnimplementedError()));
  //   }

  //   // save filter values
  //   final filterValues =
  //       filterValuesEither.fold((l) => throw UnimplementedError(), (r) => r);

  //   final saveFilterValuesEither =
  //       await filterDataProvider.insert(filterName, filterValues);
  //   if (saveFilterValuesEither.isLeft()) {
  //     return left(saveFilterValuesEither.fold(
  //         (l) => l, (r) => throw UnimplementedError()));
  //   }
  //   return right(filterValues);
  // }

  @override
  Future<Either<RewildError, List<LemmaByFilterId>>> getLemmasBySubjectId({
    required String token,
    required int subjectId,
    int limit = 100,
    int offset = 0,
  }) async {
    // get from local db

    final localDbValuesEither =
        await lemmaDataProvider.getAllForSubjectID(subjectId);
    if (localDbValuesEither.isLeft()) {
      return left(localDbValuesEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }
    final localDbValues =
        localDbValuesEither.fold((l) => throw UnimplementedError(), (r) => r);

    if (localDbValues.isNotEmpty) {
      return right(localDbValues);
    }

    // if local db is empty get from server
    final filterValuesEither = await filterApiClient.getLemmasByFilterId(
      token: token,
      filterID: subjectId,
      limit: limit,
      offset: offset,
    );

    if (filterValuesEither.isLeft()) {
      return left(
          filterValuesEither.fold((l) => l, (r) => throw UnimplementedError()));
    }

    // save lemmas to local db
    final filterValues =
        filterValuesEither.fold((l) => throw UnimplementedError(), (r) => r);

    final saveFilterValuesEither =
        await lemmaDataProvider.addAll(subjectId, filterValues);

    if (saveFilterValuesEither.isLeft()) {
      return left(saveFilterValuesEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }

    return right(filterValues);
  }

  @override
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsByLemmas({
    required String token,
    required List<int> lemmasIDs,
    required int filterID,
  }) async {
    List<KwByLemma> kwByLemmasFromLocalDb = [];
    List<int> lemmasIDsForFetching = [];
    // get from local db
    for (final lemmaID in lemmasIDs) {
      final localDbValuesEither = await kwByLemmaDataProvider.getByLemmaId(
        lemmaID,
      );
      if (localDbValuesEither.isLeft()) {
        return left(localDbValuesEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      final localDbValues =
          localDbValuesEither.fold((l) => throw UnimplementedError(), (r) => r);
      if (localDbValues.isNotEmpty) {
        kwByLemmasFromLocalDb.addAll(localDbValues);
      } else {
        lemmasIDsForFetching.add(lemmaID);
      }
    }

    if (lemmasIDsForFetching.isEmpty) {
      return right(kwByLemmasFromLocalDb);
    }
    // fetch from server
    final fetchedLemmasEither = await filterApiClient.getKeywordsByLemmas(
        token: token, lemmasIDs: lemmasIDsForFetching, filterID: filterID);
    if (fetchedLemmasEither.isLeft()) {
      return left(fetchedLemmasEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }
    final fetchedLemmas =
        fetchedLemmasEither.fold((l) => throw UnimplementedError(), (r) => r);
    // save to local db
    if (fetchedLemmas.isNotEmpty) {
      final saveFilterValuesEither =
          await kwByLemmaDataProvider.insertAll(fetchedLemmas);
      if (saveFilterValuesEither.isLeft()) {
        return left(saveFilterValuesEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
    }

    return right(kwByLemmasFromLocalDb + fetchedLemmas);
  }

  @override
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsByWords({
    required String token,
    required List<String> words,
  }) async {
    // try to get from local db
    List<KwByLemma> kwByLemmasFromLocalDb = [];
    List<String> wordsForFetching = [];
    for (final word in words) {
      final localDbValuesEither =
          await cachedKwByWordDataProvider.getByWord(word);
      if (localDbValuesEither.isLeft()) {
        return left(localDbValuesEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
      final localDbValues =
          localDbValuesEither.fold((l) => throw UnimplementedError(), (r) => r);
      if (localDbValues.isNotEmpty) {
        kwByLemmasFromLocalDb.addAll(localDbValues);
      } else {
        wordsForFetching.add(word);
      }
    }

    // fetch from server
    if (wordsForFetching.isEmpty) {
      return right(kwByLemmasFromLocalDb);
    }
    final fetchedLemmasEither = await filterApiClient.getKeywordsByWords(
      token: token,
      words: wordsForFetching,
    );
    if (fetchedLemmasEither.isLeft()) {
      return left(fetchedLemmasEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }
    final fetchedLemmas =
        fetchedLemmasEither.fold((l) => throw UnimplementedError(), (r) => r);
    // save to local db
    if (fetchedLemmas.isNotEmpty) {
      final saveFilterValuesEither =
          await cachedKwByWordDataProvider.insertAll(fetchedLemmas);
      if (saveFilterValuesEither.isLeft()) {
        return left(saveFilterValuesEither.fold(
            (l) => l, (r) => throw UnimplementedError()));
      }
    }

    return right(kwByLemmasFromLocalDb + fetchedLemmas);
  }
}
