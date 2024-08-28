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
    setLoadingText('Проверяю токен');
    final tokenEither = await seoCoreTokenService.getToken();
    if (tokenEither.isLeft()) {
      setLoadingText(null);
      return;
    }
    _token = tokenEither.fold((l) => throw UnimplementedError(), (r) => r);
    if (_token == null) {
      setLoadingText(null);
      return;
    }

    setSelectedPhrases(addedPhrases);
    if (addedPhrases.isNotEmpty) {
      _isNotEmpty = true;
    }
    setLoadingText(null);
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
    if (!_selectedPhrases.any((item) => item.keyword == kw)) {
      final phrase = _suggestedKeywords.where((item) => item.keyword == kw);
      if (phrase.isEmpty) {
        return;
      }
      _selectedPhrases.add(phrase.first);
      // _allKws.removeWhere((item) => item.keyword == phrase.keyword);
      _selectedPhrasesChanged = true;
    } else {
      _selectedPhrases.removeWhere((item) => item.keyword == kw);
    }
    notify();
  }

  int get selectedCount => _selectedPhrases.length;

  List<KwByLemma> get selectedPhrases => _selectedPhrases;

  bool _selectedPhrasesChanged = false;

  bool get hasChanges => _selectedPhrasesChanged;

  // is loading
  String? _loadingText;
  String? get loadingText => _loadingText;
  setLoadingText(String? loadingText) {
    _loadingText = loadingText;
    notify();
  }

  // final List<String> _keywords = [];

  // List<String> get keywords => _keywords;

  // void addKeyword(String kw) {
  //   final keyword = kw.trim().toLowerCase();
  //   if (keyword.isNotEmpty) {
  //     _keywords.add(keyword);
  //     notify();
  //   }
  // }

  // void removeKeyword(String kw) {
  //   _keywords.remove(kw);
  //   notify();
  // }

  final List<String> _keywords = [];

  List<String> get keywords => _keywords;

  void addKeyword(String kw) {
    final keyword = kw.trim().toLowerCase();
    if (keyword.isNotEmpty && !_keywords.contains(keyword)) {
      _keywords.add(keyword);
      notify();
    }
  }

  void removeKeyword(String kw) {
    _keywords.remove(kw);
    notify();
  }

  // ignore: prefer_final_fields
  List<KwByLemma> _suggestedKeywords = [];
  List<KwByLemma> get suggestedKeywords => _suggestedKeywords;

  void fetchKeywords(List<String> phrases) async {
    setLoadingText('Получаю ключевые фразы для выбранных слов...');
    final fixedPhrases = phrases.map((item) => item.toLowerCase().trim());
    final keywordsOrNull =
        await fetch(() => filterValuesService.getKeywordsByWords(
              token: _token!,
              words: fixedPhrases.toList(),
            ));
    if (keywordsOrNull == null) {
      setLoadingText(null);
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
    setLoadingText(null);
  }

  void goBack() {
    Navigator.of(context).pop(selectedPhrases);
  }
}
