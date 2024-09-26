import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';

// server token
abstract class AutocompliteKeywordExpansionTokenService {
  Future<Either<RewildError, String>> getToken();
}

abstract class AutocompliteKeywordExpansionSearchSuggestionService {
  Future<Either<RewildError, List<String>>> fetchSuggestions({
    required String query,
  });
  Future<Either<RewildError, List<(String, int)>>> fetchFrequency({
    required String? token,
    required List<String> keyPhrases,
  });
}

class AutocompliteKeywordExpansionViewModel extends ResourceChangeNotifier {
  final List<KwByLemma> alreadyAddedPhrases;
  final AutocompliteKeywordExpansionSearchSuggestionService suggestionService;
  final AutocompliteKeywordExpansionTokenService tokenService;
  final List<KwByLemma> _allFetchedKeywords = [];

  final Set<KwByLemma> _addedKeywords = {};

  AutocompliteKeywordExpansionViewModel({
    required super.context,
    required this.suggestionService,
    required this.tokenService,
    required this.alreadyAddedPhrases,
  });

  List<KwByLemma> get allFetchedKeywords => _allFetchedKeywords;
  Set<KwByLemma> get addedKeywords => _addedKeywords;

  Future<void> fetchSuggestionsAndFreq(String query) async {
    final suggestionsOrNull =
        await fetch(() => suggestionService.fetchSuggestions(query: query));
    if (suggestionsOrNull == null) {
      return;
    }
    final token = await fetch(() => tokenService.getToken());
    if (token == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при получении токена')),
        );
      }
      return;
    }
    final frequenciesOrNull = await fetch(() => suggestionService
        .fetchFrequency(token: token, keyPhrases: suggestionsOrNull));
    List<KwByLemma> kwLemmasToAdd = [];
    if (frequenciesOrNull != null) {
      for (final f in frequenciesOrNull) {
        if (!alreadyAddedPhrases.any((element) => element.keyword == f.$1)) {
          kwLemmasToAdd.add(
            KwByLemma(keyword: f.$1, freq: f.$2, lemma: "", lemmaID: 0),
          );
        }
      }
    }
    _allFetchedKeywords.clear();
    _allFetchedKeywords.addAll(kwLemmasToAdd);
    _allFetchedKeywords.sort((a, b) => b.freq - a.freq);
    notify();
  }

  Future<void> fetchAndAddKeywords(String text) async {
    final query = text.trim();
    if (query.isNotEmpty) {
      await fetchSuggestionsAndFreq(query);
    }
  }

  void addKeyword(KwByLemma kwByLemma) {
    if (_addedKeywords.any((element) => element.keyword == kwByLemma.keyword)) {
      _addedKeywords
          .removeWhere((element) => element.keyword == kwByLemma.keyword);
    } else {
      _addedKeywords.add(kwByLemma);
    }
    notify();
  }

  void clearAddedKeywords() {
    _addedKeywords.clear();
    notify();
  }

  void acceptKeywords() {
    if (!context.mounted) {
      return;
    }
    alreadyAddedPhrases.addAll(_addedKeywords.toList());
    Navigator.of(context).pop(alreadyAddedPhrases);
  }

  void goBack() {
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop(alreadyAddedPhrases);
  }
}
