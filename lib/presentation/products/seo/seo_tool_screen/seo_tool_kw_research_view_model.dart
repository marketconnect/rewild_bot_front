import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// server token
abstract class SeoToolKwResearchTokenService {
  Future<Either<RewildError, String>> getToken();
}

// Seo
abstract class SeoToolSeoService {
  // Future<Either<RewildError, void>> addAllLemmas(int nmId, List<String> lemmas);
  // Future<Either<RewildError, List<String>>> getAllLemmasForNmID(int nmId);
  Future<Either<RewildError, List<KwByLemma>>> getPhrasesForNmId(int nmId);
  Future<Either<RewildError, void>> savePhrasesForNmId(
      int nmId, List<KwByLemma> kw);
}

// tracking queries data provider
abstract class SeoToolKwResearchTrackingService {
  Future<Either<RewildError, void>> addAllForNmId(
      {required int nmId, required List<String> queries, String? geoNum});
  Future<Either<RewildError, void>> deleteAllQueryForNmId(int nmId);
}

class SeoToolKwResearchViewModel extends ResourceChangeNotifier {
  final SeoToolSeoService seoService;
  final SeoToolKwResearchTokenService tokenService;
  final SeoToolKwResearchTrackingService trackingService;
  final int productId;
  final int subjectId;

  SeoToolKwResearchViewModel(
      {required super.context,
      required this.productId,
      required this.subjectId,
      required this.trackingService,
      required this.tokenService,
      required this.seoService}) {
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    setIsLoading(true);

    final tokenEither = await tokenService.getToken();
    if (tokenEither.isLeft()) {
      setIsLoading(false);
      return;
    }
    _token = tokenEither.fold((l) => throw UnimplementedError(), (r) => r);
    if (_token == null) {
      setIsLoading(false);
      return;
    }

    // get saved phrases from local db
    final phrasesEither = await seoService.getPhrasesForNmId(productId);
    if (phrasesEither.isLeft()) {
      setIsLoading(false);
      return;
    }
    final phrases =
        phrasesEither.fold((l) => throw UnimplementedError(), (r) => r);
    setCorePhrases(phrases);
    if (phrases.isNotEmpty) {
      _isNotEmpty = true;
    }
    setIsLoading(false);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notify();
  }

  // token
  String? _token;

  // Selected phrases
  List<KwByLemma> _corePhrases = [];
  void setCorePhrases(List<KwByLemma> phrases) {
    _corePhrases = phrases;
    notify();
  }

  List<KwByLemma> get corePhrases => _corePhrases;

  //   // is not empty
  bool _isNotEmpty = false;

  bool get isNotEmpty => _isNotEmpty;

  void addKeywordToCore(KwByLemma kw) async {
    final coreWords = _corePhrases.map((e) => e.keyword).toList();

    if (coreWords.contains(kw.keyword)) {
      return;
    }
    _corePhrases.add(kw);

    notify();
  }

  void removeKeywordFromCore(String keyword) {
    _corePhrases.removeWhere((element) => element.keyword == keyword);
    setHasChange(true);
    notify();
  }

  Future<void> goToSubjectKwExpansionScreen() async {
    List<KwByLemma> corePhrasesCopy = [..._corePhrases];

    final result = await Navigator.of(context).pushNamed(
      MainNavigationRouteNames.subjectKeywordExpansionScreen,
      arguments: (corePhrasesCopy, subjectId),
    );

    if (result != null &&
        result is List<KwByLemma> &&
        result.length > corePhrases.length) {
      corePhrases.clear();

      corePhrases.addAll(result);
      setHasChange(true);
      notify();
    }
  }

  Future<void> goToWordsKwExpansionScreen() async {
    List<KwByLemma> corePhrasesCopy = [..._corePhrases];

    final result = await Navigator.of(context).pushNamed(
      MainNavigationRouteNames.wordsKeywordExpansionScreen,
      arguments: corePhrasesCopy,
    );
    if (result != null &&
        result is List<KwByLemma> &&
        result.length > corePhrases.length) {
      corePhrases.clear();

      corePhrases.addAll(result);
      setHasChange(true);
      notify();
    }
  }

  Future<void> goToAutocompliteKwExpansionScreen() async {
    List<KwByLemma> corePhrasesCopy = [..._corePhrases];

    final result = await Navigator.of(context).pushNamed(
      MainNavigationRouteNames.autocompliteKwExpansionScreen,
      arguments: (corePhrasesCopy),
    );

    if (result != null &&
        result is List<KwByLemma> &&
        result.length > corePhrases.length) {
      corePhrases.clear();

      corePhrases.addAll(result);
      setHasChange(true);
      notify();
    }
  }

  Future<void> goToCompetitorsKwExpansionScreen() async {
    final result = await Navigator.of(context).pushNamed(
      MainNavigationRouteNames.competitorKwExpansionScreen,
    );
    if (result != null && result is List<KwByLemma>) {
      // corePhrases.clear();

      for (final res in result) {
        if (corePhrases
            .where((element) => element.keyword == res.keyword)
            .isEmpty) {
          corePhrases.add(res);
        }
      }
      setHasChange(true);
      notify();
    }
  }

  bool _isSaving = false;
  bool get isSaving => _isSaving;
  setIsSaving(bool isSaving) {
    _isSaving = isSaving;
    notify();
  }

  bool _hasChange = false;
  void setHasChange(bool value) {
    _hasChange = value;
  }

  bool hasChange() => _hasChange;
  Future<void> save() async {
    setIsSaving(true);
    // save selected phrases
    if (corePhrases.isNotEmpty) {
      await seoService.savePhrasesForNmId(productId, corePhrases);
    }
    // delete tracking queries
    await fetch(
      () => trackingService.deleteAllQueryForNmId(productId),
    );
    // save tracking queries
    await fetch(
        () => trackingService.addAllForNmId(
            queries: corePhrases.map((e) => e.keyword).toList(),
            nmId: productId),
        showError: true,
        message: 'Failed to add tracking queries');
    setIsSaving(false);
  }

  void countKeyPhraseOccurrences(
      {required String text, required bool isTitle}) {
    final lowerText = text.toLowerCase().trim();

    // Normalize the text to remove common word endings and other variants
    String normalize(String input) {
      return input.replaceAll(
          RegExp(
              r'(а|у|е|я|и|ы|о|й|ю|ь|ъ|ей|ое|ие|ые|ый|их|ую|юю|ам|ом|ем|ым|им|ах|ях|ью|ов|ев|ий|ый|ой|её|яя|ие|ия|ий|ые|ым|им|ем|ое|ую|юю|ое|яя|ей|ей|а|у|е|я|и|ы|о|й|ю|ь|ъ)$'),
          '');
    }

    // Extract and normalize words from the input text
    List<String> getWords(String input) {
      return input
          .split(RegExp(r'[\s,;.?!]+')) // Split by whitespace and punctuation
          .map((word) => normalize(word.trim()))
          .where((word) => word.isNotEmpty) // Remove empty words
          .toList();
    }

    final normalizedWords = getWords(lowerText);

    for (var kwByLemma in _corePhrases) {
      final phrase = kwByLemma.keyword;
      final lowerPhrase = phrase.toLowerCase();
      final normalizedPhraseWords = getWords(lowerPhrase);

      int count = 0;
      for (int i = 0;
          i <= normalizedWords.length - normalizedPhraseWords.length;
          i++) {
        bool match = true;
        for (int j = 0; j < normalizedPhraseWords.length; j++) {
          if (normalizedWords[i + j] != normalizedPhraseWords[j]) {
            match = false;
            break;
          }
        }
        if (match) {
          count++;
        }
      }
      if (isTitle) {
        kwByLemma.setNumberOfOccurrencesInTitle(count);
      } else {
        kwByLemma.setNumberOfOccurrencesInDescription(count);
      }
      // print('$phrase: ${phraseOccurrences[phrase]}');
    }

    notify();
  }
}