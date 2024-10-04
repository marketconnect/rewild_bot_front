import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';

// server token
abstract class CompetitorKeywordExpansionTokenService {
  Future<Either<RewildError, String>> getToken();
}

abstract class CompetitorKeywordExpansionCardOfProductService {
  Future<Either<RewildError, List<CardOfProductModel>>> getNotUserCards();
}

abstract class CompetitorKeywordExpansionCardKeywordsService {
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsForCards(
      {required String token, required List<int> skus});
}

class CompetitorKeywordExpansionViewModel extends ResourceChangeNotifier {
  CompetitorKeywordExpansionViewModel(
      {required super.context,
      required this.tokenService,
      required this.keywordsService,
      required this.cardsService}) {
    _asyncInit();
  }

  // Constructor params
  final CompetitorKeywordExpansionTokenService tokenService;
  final CompetitorKeywordExpansionCardOfProductService cardsService;
  final CompetitorKeywordExpansionCardKeywordsService keywordsService;

  // Other fields
  // isLoading
  bool _isLoading = false;
  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notify();
  }

  bool get isLoading => _isLoading;

  // Cards
  List<CardOfProductModel> _cards = [];
  void setCards(List<CardOfProductModel> cards) {
    _cards = cards;
  }

  List<CardOfProductModel> get cards => _cards;

  // phrases
  // List<KwByLemma> _phrases = [];
  // void setPhrases(List<KwByLemma> phrases) {
  //   _phrases = phrases;
  //   notify();
  // }

  // List<KwByLemma> get phrases => _phrases;

  // Selected competitors cards
  Set<CardOfProductModel> _selectedCards = {};
  void setSelectedCards(Set<CardOfProductModel> selectedCards) {
    _selectedCards = selectedCards;
  }

  void selectCard(CardOfProductModel card) {
    if (_selectedCards.contains(card)) {
      _selectedCards.remove(card);
    } else {
      _selectedCards.add(card);
    }
    notify();
  }

  void clearSelection() {
    _selectedCards.clear();
    notify();
  }

  Set<CardOfProductModel> get selectedCards => _selectedCards;

  // methods
  Future<void> _asyncInit() async {
    setIsLoading(true);
    final allNotUserCards = await fetch(() => cardsService.getNotUserCards());
    if (allNotUserCards == null) {
      setIsLoading(false);
      return;
    }
    setCards(allNotUserCards);
    setIsLoading(false);
  }

  Future<void> goBack() async {
    setIsLoading(true);
    final tokenOrNull = await fetch(() => tokenService.getToken());
    if (tokenOrNull == null) {
      setIsLoading(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Ошибка при обработке токена."),
        ));
      }
      return;
    }

    final kwLemmasForSelectedCardsOrNull = await fetch(
        () => keywordsService.getKeywordsForCards(
              token: tokenOrNull,
              skus: _selectedCards.map((e) => e.nmId).toList(),
            ),
        showError: true);
    if (kwLemmasForSelectedCardsOrNull == null) {
      setIsLoading(false);
      return;
    }

    setIsLoading(false);
    if (context.mounted) {
      Navigator.of(context).pop(kwLemmasForSelectedCardsOrNull);
    }
  }
  // Future<void> save() async {
  //   setIsSaving(true);
  //   // save selected lemmas
  //   List<String> lemmasToSaveLocal = [];
  //   if (_selectedQueries.isNotEmpty) {
  //     lemmasToSaveLocal = _selectedQueries.map((e) => e.lemma).toList();
  //     await seoCoreSeoService.addAllLemmas(CmIdcompetitorId.$1, lemmasToSaveLocal);
  //   }

  //   // save selected phrases
  //   if (_selectedPhrases.isNotEmpty) {
  //     await seoCoreSeoService.savePhrasesForNmId(
  //         CmIdcompetitorId.$1, _selectedPhrases);
  //   }

  //   // delete tracking queries
  //   // await fetch(
  //   //   () => seoCoreTrackingService.deleteAllQueryForNmId(CmIdcompetitorId.$1),
  //   // );

  //   // save tracking queries

  //   // await fetch(
  //   //     () => seoCoreTrackingService.addAllForNmId(
  //   //         queries: _selectedPhrases.map((e) => e.keyword).toList(),
  //   //         nmId: CmIdcompetitorId.$1),
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
