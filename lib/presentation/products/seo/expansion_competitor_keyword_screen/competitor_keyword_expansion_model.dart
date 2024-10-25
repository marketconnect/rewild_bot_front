import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/entities/subject_history.dart';
import 'package:rewild_bot_front/domain/entities/top_product.dart';

// server token
abstract class CompetitorKeywordExpansionTokenService {
  Future<Either<RewildError, String>> getToken();
}

// Top product service
abstract class CompetitorKeywordExpansionTopProductService {
  Future<Either<RewildError, (List<TopProduct>, List<SubjectHistory>)>>
      getTopProducts({
    required String token,
    required int subjectId,
  });
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
      required this.subjectId,
      required this.tokenService,
      required this.keywordsService,
      required this.topProductService,
      required this.cardsService}) {
    _asyncInit();
  }

  // Constructor params
  final int? subjectId;
  final CompetitorKeywordExpansionTokenService tokenService;
  final CompetitorKeywordExpansionCardOfProductService cardsService;
  final CompetitorKeywordExpansionCardKeywordsService keywordsService;
  final CompetitorKeywordExpansionTopProductService topProductService;

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

  // Top products
  List<TopProduct> _topProducts = [];
  void setTopProducts(List<TopProduct> topProducts) {
    _topProducts = topProducts;
  }

  List<TopProduct> get topProducts => _topProducts;

  // Selected competitors cards
  Set<CardOfProductModel> _selectedCards = {};
  void setSelectedCards(Set<CardOfProductModel> selectedCards) {
    _selectedCards = selectedCards;
  }

  Set<CardOfProductModel> get selectedCards => _selectedCards;

// Selected top products
  // ignore: prefer_final_fields
  Set<TopProduct> _selectedTopProducts = {};
  Set<TopProduct> get selectedTopProducts => _selectedTopProducts;

  // methods
  Future<void> _asyncInit() async {
    setIsLoading(true);
    if (subjectId == null) {
      // get all not user cards
      final allNotUserCards = await fetch(() => cardsService.getNotUserCards());
      if (allNotUserCards == null) {
        setIsLoading(false);
        return;
      }
      setCards(allNotUserCards);
    } else {
      final tokenOrNull = await fetch(() => tokenService.getToken());
      if (tokenOrNull == null) {
        setIsLoading(false);
        return;
      }
      // get all not user cards
      final allNotUserCards = await fetch(() => cardsService.getNotUserCards());
      if (allNotUserCards == null) {
        setIsLoading(false);
        return;
      }
      setCards(allNotUserCards);

      // get top products
      final topProductsOrNull =
          await fetch(() => topProductService.getTopProducts(
                token: tokenOrNull,
                subjectId: subjectId!,
              ));
      if (topProductsOrNull == null) {
        setIsLoading(false);
        return;
      }
      setTopProducts(topProductsOrNull.$1);
    }
    setIsLoading(false);
  }

  void selectCard(CardOfProductModel card) {
    if (_selectedCards.contains(card)) {
      _selectedCards.remove(card);
    } else {
      _selectedCards.add(card);
    }
    notify();
  }

  void selectTopProduct(TopProduct product) {
    if (_selectedTopProducts.contains(product)) {
      _selectedTopProducts.remove(product);
    } else {
      _selectedTopProducts.add(product);
    }
    notify();
  }

  void clearSelection() {
    _selectedCards.clear();
    _selectedTopProducts.clear();
    notify();
  }

  // methods

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

    // Собираем sku из выбранных карточек
    final selectedCardSkus = _selectedCards.map((e) => e.nmId).toList();
    // Собираем sku из выбранных топ-продуктов
    final selectedTopProductSkus =
        _selectedTopProducts.map((e) => e.sku).toList();

    // Объединяем оба списка sku
    final allSelectedSkus = [...selectedCardSkus, ...selectedTopProductSkus];

    if (allSelectedSkus.isEmpty) {
      setIsLoading(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Не выбрано ни одной карточки."),
        ));
      }
      return;
    }

    final kwLemmasForSelectedCardsOrNull = await fetch(
        () => keywordsService.getKeywordsForCards(
              token: tokenOrNull,
              skus: allSelectedSkus,
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
}
