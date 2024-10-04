import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/card_catalog.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';

// token for cards inserting

abstract class AllCardsSeoAuthService {
  Future<Either<RewildError, String>> getToken();
}

// update
abstract class AllCardsSeoUpdateService {
  Future<Either<RewildError, int>> insert(
      {required String token,
      required List<CardOfProductModel> cardOfProductsToInsert});
}

abstract class AllCardsSeoScreenCardOfProductService {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]);
}

abstract class AllCardsSeoContentService {
  Future<Either<RewildError, CardCatalog>> fetchNomenclatures();
  Future<Either<RewildError, bool>> apiKeyExist();
}

class AllCardsSeoViewModel extends ResourceChangeNotifier {
  AllCardsSeoViewModel(
      {required super.context,
      required this.contentService,
      required this.authService,
      required this.updateService,
      required this.cardOfProductService}) {
    _asyncInit();
  }
  // constructor params ========================================================
  final AllCardsSeoScreenCardOfProductService cardOfProductService;
  final AllCardsSeoContentService contentService;
  final AllCardsSeoAuthService authService;
  final AllCardsSeoUpdateService updateService;
  // other fields ========================================================
  // loading
  bool _isLoading = true;
  void _setIsLoading(bool value) {
    _isLoading = value;
    notify();
  }

  bool get isLoading => _isLoading;

  // products
  final List<CardOfProductModel> _cards = [];
  void setCards(List<CardOfProductModel> value) {
    _cards.clear();
    _cards.addAll(value);
    notify();
  }

  List<CardOfProductModel> get cards => _cards;

  // content of cards
  final List<CardItem> _cardsContent = [];
  void setCardsContent(List<CardItem> value) {
    _cardsContent.clear();
    _cardsContent.addAll(value);
    notify();
  }

  CardItem? getCardContent(int nmID) {
    final c = _cardsContent.where((e) => e.nmID == nmID);
    if (c.isEmpty) {
      return null;
    }
    return c.first;
  }

  // // content api key exists
  bool _apiKeyExists = false;
  void _setApiKeyExists(bool apiKeyExists) {
    _apiKeyExists = apiKeyExists;
  }

  bool get apiKeyExists => _apiKeyExists;

  // methods ===================================================================

  Future<void> _asyncInit() async {
    _setIsLoading(true);
    // check if wb content api key exists
    final apiKey = await fetch(() => contentService.apiKeyExist());
    if (apiKey == null || !apiKey) {
      _setIsLoading(false);
      return;
    }
    _setApiKeyExists(apiKey);
    // get all users cards content
    final contentOrNull =
        await fetch(() => contentService.fetchNomenclatures());

    if (contentOrNull == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Ошибка при получении данных от API WB")),
        );
      }
      _setIsLoading(false);
    }

    setCardsContent(contentOrNull!.cards);

    // Get all the user cards as we need images and subject ids to pass to SeoTool.
    final nmIds = _cardsContent.map((e) => e.nmID).toList();
    final allCardsOrNull =
        await fetch(() => cardOfProductService.getAll(nmIds));

    // get local saved cards nmIds
    final savedNmIds = allCardsOrNull!.map((e) => e.nmId);
    // get cards that are not in local storage
    final notSavedCards =
        contentOrNull.cards.where((card) => !savedNmIds.contains(card.nmID));

    List<CardOfProductModel> cardOfProducts = [];

    for (final c in notSavedCards) {
      final nmId = c.nmID;
      final img = c.photos.first.big;
      final name = c.title;
      final cardOfProduct = CardOfProductModel(
        nmId: nmId,
        img: img,
        name: name,
      );
      cardOfProducts.add(cardOfProduct);
    }

    if (cardOfProducts.isNotEmpty) {
      final tokenOrNull = await fetch(() => authService.getToken());
      if (tokenOrNull == null) {
        _setIsLoading(false);
        return;
      }

      await updateService.insert(
          token: tokenOrNull, cardOfProductsToInsert: cardOfProducts);
    }

    setCards([...allCardsOrNull, ...cardOfProducts]);

    _setIsLoading(false);
  }

  void goToSeoToolScreen(
      {required CardOfProductModel product, required CardItem card}) {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.seoToolScreen,
      arguments: (product, card),
    );
    return;
  }

  void onAddApiKeyPressed() {
    Navigator.of(context).pushNamed(MainNavigationRouteNames.apiKeysScreen);
  }

  void onSeoByCategoryPressed() {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.seoToolCategoryScreen,
      arguments: 436,
    );
    return;
  }
}
