import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/entities/lemma_by_filter.dart';

// tracking queries data provider
// abstract class SubjectKeywordExpansionTrackingService {
//   Future<Either<RewildError, void>> addAllForNmId(
//       {required int nmId, required List<String> queries, String? geoNum});
//   Future<Either<RewildError, void>> deleteAllQueryForNmId(int nmId);
// }

// abstract class SubjectKeywordExpansionSeoService {
//   // Future<Either<RewildError, List<String>>> getAllLemmasForNmID(int nmId);
//   Future<Either<RewildError, void>> savePhrasesForNmId(
//       int nmId, List<KwByLemma> kw);
// }

// server token
abstract class SubjectKeywordExpansionTokenService {
  Future<Either<RewildError, String>> getToken();
}

// keywords
abstract class SubjectKeywordExpansionFilterValuesService {
  Future<Either<RewildError, List<LemmaByFilterId>>> getLemmasBySubjectId({
    required String token,
    required int subjectId,
    int limit = 100,
    int offset = 0,
  });
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsByLemmas({
    required String token,
    required List<int> lemmasIDs,
    required int filterID,
  });
}

// abstract class SubjectKeywordExpansionSearchSuggestionService {
//   Future<Either<RewildError, List<(String, int)>>> fetchFrequency({
//     required String? token,
//     required List<String> keyPhrases,
//   });
// }

class SubjectKeywordExpansionViewModel extends ResourceChangeNotifier {
  final int subjectId;
  final List<KwByLemma> addedPhrases;
  final SubjectKeywordExpansionTokenService seoCoreTokenService;
  final SubjectKeywordExpansionFilterValuesService seoCoreFilterValuesService;
  // final SubjectKeywordExpansionSeoService seoCoreSeoService;

  SubjectKeywordExpansionViewModel(
      {required super.context,
      required this.seoCoreTokenService,
      // required this.seoCoreSeoService,
      required this.seoCoreFilterValuesService,
      required this.addedPhrases,
      required this.subjectId}) {
    _asyncInit();
  }

  void _asyncInit() async {
    // SqfliteService.printTableContent('seo_lemmas');
    setIsLoading(true);
    final tokenEither = await seoCoreTokenService.getToken();
    if (tokenEither.isLeft()) {
      setIsLoading(false);
      return;
    }
    _token = tokenEither.fold((l) => throw UnimplementedError(), (r) => r);
    if (_token == null) {
      setIsLoading(false);
      return;
    }

    setSelectedPhrases(addedPhrases);
    if (addedPhrases.isNotEmpty) {
      _isNotEmpty = true;
    }
    setIsLoading(false);
  }

  // token
  String? _token;

  // is not empty
  bool _isNotEmpty = false;

  bool get isNotEmpty => _isNotEmpty;

  bool _isLoading = false;
  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notify();
  }

  bool get isLoading => _isLoading;

  // fetch lemmas
  Future<void> updateLemmas() async {
    if (_token == null) {
      return;
    }
    setIsLoading(true);

    final lemmasFromServerEither = await seoCoreFilterValuesService
        .getLemmasBySubjectId(token: _token!, subjectId: subjectId);
    if (lemmasFromServerEither.isLeft()) {
      setIsLoading(false);
      return;
    }

    // get lemmas from server
    final lemmasFromServer = lemmasFromServerEither.fold(
        (l) => throw UnimplementedError(), (r) => r);
    setAllQueries(lemmasFromServer);

    // get lemmas from local db
    // final lemmasEither = await seoCoreSeoService.getAllLemmasForNmID(subjectId);
    // if (lemmasEither.isLeft()) {
    //   setIsLoading(false);
    //   return;
    // }
    // final lemmas =
    //     lemmasEither.fold((l) => throw UnimplementedError(), (r) => r);
    // setSelectedLemmas(lemmasFromServer
    //     .where((element) => lemmas.contains(element.lemma))
    //     .toList());
    setIsLoading(false);
  }

  // all keywords
  // ignore: prefer_final_fields
  List<KwByLemma> _allKws = [];
  void setAllKws(List<KwByLemma> kws) {
    _allKws.clear();
    final addedKeywords = addedPhrases.map((e) => e.keyword).toList();
    for (var kw in kws) {
      if (addedKeywords.contains(kw.keyword)) {
        continue;
      }
      if (!_allKws.any((existingKw) => existingKw.keyword == kw.keyword)) {
        _allKws.add(kw);
      }
    }
    notify();
  }

  List<KwByLemma> get allKws => _allKws;

  // Selected phrases
  List<KwByLemma> _selectedPhrases = [];
  void setSelectedPhrases(List<KwByLemma> selectedPhrases) {
    _selectedPhrases = selectedPhrases;
  }

  void selectPhrase(KwByLemma phrase) {
    if (!_selectedPhrases.any((item) => item.keyword == phrase.keyword)) {
      _selectedPhrases.add(phrase);
      _allKws.removeWhere((item) => item.keyword == phrase.keyword);
      _selectedPhrasesChanged = true;
      notify();
    }
  }

  bool wordIsSelected(String lemma) {
    return _selectedPhrases.any((element) => element.lemma == lemma);
  }

  void deselectPhrase(KwByLemma phrase) {
    _selectedPhrases.remove(phrase);
    _allKws.add(phrase);
    _selectedPhrasesChanged = true;
    notify();
  }

  List<KwByLemma> get selectedPhrases => _selectedPhrases;

  bool _selectedPhrasesChanged = false;
  bool _selectedQueriesChanged = false;
  bool get hasChanges => _selectedPhrasesChanged || _selectedQueriesChanged;

  // is loading
  // String? _loadingText;
  // String? get loadingText => _loadingText;
  // setIsLoading(String? loadingText) {
  //   _loadingText = loadingText;
  //   notify();
  // }

  bool _isSaving = false;
  bool get isSaving => _isSaving;
  setIsSaving(bool isSaving) {
    _isSaving = isSaving;
    notify();
  }

  // all queries
  List<LemmaByFilterId> _allQueries = [];
  void setAllQueries(List<LemmaByFilterId> queries) {
    _allQueries = queries;
  }

  // filtered queries
  List<LemmaByFilterId>? _filteredQueries;

  List<LemmaByFilterId> get filteredQueries {
    if (_filteredQueries == null || _filteredQueries!.isEmpty) {
      List<LemmaByFilterId> sortedQueries = [];
      List<LemmaByFilterId> restQueries = [];

      // Separate selected and saved from the rest
      for (var lemma in _allQueries) {
        if (_selectedQueries.contains(lemma)) {
          sortedQueries.add(lemma);
        } else {
          restQueries.add(lemma);
        }
      }

      // Sort saved and selected to be at the top
      sortedQueries.sort((a, b) {
        bool isSelectedA = _selectedQueries.contains(a);
        bool isSelectedB = _selectedQueries.contains(b);

        if ((isSelectedA) && !(isSelectedB)) return -1;
        if (!(isSelectedA) && (isSelectedB)) return 1;
        return 0; // If both are selected or unselected, retain their order
      });

      // Append the rest of the queries
      return sortedQueries..addAll(restQueries);
    } else {
      return _filteredQueries!;
    }
  }

  // Selected queries
  // ignore: prefer_final_fields
  List<LemmaByFilterId> _selectedQueries = [];
  void setSelectedLemmas(List<LemmaByFilterId> lemmas) {
    _selectedQueries = lemmas;
  }

  int get selectedCount => _selectedQueries.length;

  bool isSelectedLemma(LemmaByFilterId lemma) {
    return _selectedQueries.contains(lemma);
  }

  // Methods to add and remove lemmas
  void addLemma(LemmaByFilterId lemma) {
    if (!_selectedQueries.contains(lemma)) {
      _selectedQueries.add(lemma);

      _filteredQueries?.sort((a, b) {
        // Check if either item is selected and prioritize them
        bool isSelectedA = isSelectedLemma(a);
        bool isSelectedB = isSelectedLemma(b);
        if (isSelectedA && !isSelectedB) return -1;
        if (!isSelectedA && isSelectedB) return 1;
        return 0; // If both are selected or unselected, retain their order
      });

      _selectedQueriesChanged = true;

      notify();
    }
  }

  void clearSelection() {
    _selectedQueries.clear();
    notify();
  }

  void removeLemma(LemmaByFilterId lemma) {
    if (_selectedQueries.contains(lemma)) {
      _selectedQueries.remove(lemma);
      _filteredQueries?.sort((a, b) {
        // Check if either item is selected and prioritize them
        bool isSelectedA = isSelectedLemma(a);
        bool isSelectedB = isSelectedLemma(b);
        if (isSelectedA && !isSelectedB) return -1;
        if (!isSelectedA && isSelectedB) return 1;
        return 0; // If both are selected or unselected, retain their order
      });
      _selectedQueriesChanged = true;
      notify();
    }
  }

  void filterQueries(String searchText) {
    if (searchText.isEmpty) {
      _filteredQueries = List.from(_allQueries);
    } else {
      _filteredQueries = _allQueries.where((lemma) {
        return lemma.lemma.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    }
    notify();
  }

  void clearSearch() {
    _filteredQueries = List.from(_allQueries); // Reset to the full list

    notify();
  }

  // upfdate keywords
  Future<void> updatePhrases() async {
    setIsLoading(true);
    if (_token == null) {
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Неверный токен.')),
        );
      }
      setIsLoading(false);
      return;
    }

    if (_selectedQueries.isEmpty) {
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите хотя бы одно слово.')),
        );
      }
      setIsLoading(false);
      return;
    }

    final keywordsOrNull = await fetch(() =>
        seoCoreFilterValuesService.getKeywordsByLemmas(
            token: _token!,
            lemmasIDs: _selectedQueries.map((e) => e.lemmaId).toList(),
            filterID: subjectId));
    if (keywordsOrNull == null) {
      setIsLoading(false);
      return;
    }
    setAllKws(keywordsOrNull);
    setIsLoading(false);
  }

  void goBack() {
    Navigator.of(context).pop(selectedPhrases);
  }

  // Future<void> save() async {
  //   setIsSaving(true);
  //   // save selected lemmas
  //   List<String> lemmasToSaveLocal = [];
  //   if (_selectedQueries.isNotEmpty) {
  //     lemmasToSaveLocal = _selectedQueries.map((e) => e.lemma).toList();
  //     await seoCoreSeoService.addAllLemmas(nmIdSubjectId.$1, lemmasToSaveLocal);
  //   }

  //   // save selected phrases
  //   if (_selectedPhrases.isNotEmpty) {
  //     await seoCoreSeoService.savePhrasesForNmId(
  //         nmIdSubjectId.$1, _selectedPhrases);
  //   }

  //   // delete tracking queries
  //   // await fetch(
  //   //   () => seoCoreTrackingService.deleteAllQueryForNmId(nmIdSubjectId.$1),
  //   // );

  //   // save tracking queries

  //   // await fetch(
  //   //     () => seoCoreTrackingService.addAllForNmId(
  //   //         queries: _selectedPhrases.map((e) => e.keyword).toList(),
  //   //         nmId: nmIdSubjectId.$1),
  //   //     showError: true,
  //   //     message: 'Failed to add tracking queries');
  //   // setIsSaving(false);
  // }

  // Future<void> insertPhrasesFromClipboard(List<String> newPhrases) async {
  //   bool anyInserted = false;
  //   List<String> phrasesToServerRequest = [];
  //   List<KwByLemma> fetchedEarlierKwByLemma = [];
  //   for (final newPhrase in newPhrases) {
  //     if (newPhrase.isNotEmpty &&
  //         !_selectedPhrases.any((phrase) => phrase.keyword == newPhrase)) {
  //       final exist = _allKws.any((kw) => kw.keyword == newPhrase);
  //       if (!exist) {
  //         phrasesToServerRequest.add(newPhrase);
  //       } else {
  //         final kwByLemma = _allKws.firstWhere((kw) => kw.keyword == newPhrase);
  //         fetchedEarlierKwByLemma.add(kwByLemma);
  //       }
  //       // final newKwByLemma = KwByLemma(
  //       //     keyword: newPhrase,
  //       //     freq: 0, // or any default value
  //       //     lemma: '', // or any default value
  //       //     lemmaID: 0);
  //     }
  //   }
  //   if (phrasesToServerRequest.isNotEmpty && _token != null) {
  //     final resultOrNull = await fetch(() => seoCoreSearchSuggestionService
  //         .fetchFrequency(token: _token, keyPhrases: phrasesToServerRequest));
  //     if (resultOrNull != null) {
  //       final newKwByLemmaList = resultOrNull;
  //       for (final newKwByLemma in newKwByLemmaList) {
  //         fetchedEarlierKwByLemma.add(KwByLemma(
  //             lemmaID: 0,
  //             lemma: '',
  //             keyword: newKwByLemma.$1,
  //             freq: newKwByLemma.$2));
  //       }
  //     } else {
  //       for (final newKwByLemma in phrasesToServerRequest) {
  //         fetchedEarlierKwByLemma.add(
  //             KwByLemma(lemmaID: 0, lemma: '', keyword: newKwByLemma, freq: 0));
  //       }
  //     }
  //     if (fetchedEarlierKwByLemma.isNotEmpty) {
  //       _selectedPhrases.addAll(fetchedEarlierKwByLemma);
  //       _selectedPhrasesChanged = true;
  //       anyInserted = true;
  //     }
  //   }

  //   if (anyInserted) {
  //     notify();
  //   } else {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Все фразы уже существуют или пусты')),
  //       );
  //     }
  //   }
  // }
}
