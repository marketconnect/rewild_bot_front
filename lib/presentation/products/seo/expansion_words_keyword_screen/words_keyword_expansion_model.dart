import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';

// server token
abstract class WordsKeywordExpansionTokenService {
  Future<Either<RewildError, String>> getToken();
}

// keywords
abstract class WordsKeywordExpansionFilterValuesService {
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsByWords({
    required String token,
    required List<String> words,
  });
}

class WordsKeywordExpansionViewModel extends ResourceChangeNotifier {
  final List<KwByLemma> addedPhrases;
  final WordsKeywordExpansionTokenService seoCoreTokenService;
  final WordsKeywordExpansionFilterValuesService filterValuesService;

  WordsKeywordExpansionViewModel(
      {required super.context,
      required this.seoCoreTokenService,
      required this.filterValuesService,
      required this.addedPhrases}) {
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

  // Selected phrases
  List<KwByLemma> _selectedPhrases = [];
  void setSelectedPhrases(List<KwByLemma> selectedPhrases) {
    _selectedPhrases = selectedPhrases;
  }

  void selectPhrase(String kw) {
    final index = _selectedPhrases.indexWhere((item) => item.keyword == kw);
    if (index == -1) {
      final phrase =
          _suggestedKeywords.firstWhere((item) => item.keyword == kw);
      _selectedPhrases.add(phrase);
      _selectedCount++;
    } else {
      _selectedPhrases.removeAt(index);
      _selectedCount--;
    }
    notify();
  }

  void resetSelectedPhrases() {
    _selectedPhrases = [];
    notify();
  }

  int _selectedCount = 0;

  int get selectedCount => _selectedCount;

  List<KwByLemma> get selectedPhrases => _selectedPhrases;

  bool _selectedPhrasesChanged = false;

  bool get hasChanges => _selectedPhrasesChanged;

  // is loading
  bool _isLoading = false;

  setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  bool get isLoading => _isLoading;

  // kw
  final List<String> _keywords = [];

  List<String> get keywords => _keywords;

  void addKeywords(List<String> kws) {
    for (var kw in kws) {
      if (kw.isNotEmpty) {
        final keyword = kw.trim().toLowerCase();
        if (keyword.isNotEmpty && !_keywords.contains(keyword)) {
          _keywords.add(keyword);
          notify();
        }
      }
    }
  }

  int userAddedPhrasesLength() {
    return _selectedPhrases.length - addedPhrases.length;
  }

  void removeKeyword(String kw) {
    _keywords.remove(kw);
    notify();
  }

  // ignore: prefer_final_fields
  List<KwByLemma> _suggestedKeywords = [];
  List<KwByLemma> get suggestedKeywords => _suggestedKeywords;

  void fetchKeywords(List<String> phrases) async {
    setIsLoading(true);
    final fixedPhrases = phrases.map((item) => item.toLowerCase().trim());
    final keywordsOrNull =
        await fetch(() => filterValuesService.getKeywordsByWords(
              token: _token!,
              words: fixedPhrases.toList(),
            ));
    if (keywordsOrNull == null) {
      setIsLoading(false);
      return;
    }

    _suggestedKeywords.clear();
    List<KwByLemma> keywordsToAdd = [];

    for (var kw in keywordsOrNull) {
      if (_selectedPhrases
          .where((element) => element.keyword == kw.keyword)
          .isEmpty) {
        keywordsToAdd.add(kw);
      }
    }

    _suggestedKeywords.addAll(keywordsToAdd);
    setIsLoading(false);
  }

  bool isPhraseSelected(KwByLemma kw) {
    return _selectedPhrases.any((item) => item.keyword == kw.keyword);
  }

  void goBack() {
    Navigator.of(context).pop(selectedPhrases);
  }
}
