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
// abstract class AllCardsSeoUpdateService {
//   Future<Either<RewildError, int>> insert(
//       {required String token,
//       required List<CardOfProductModel> cardOfProductsToInsert});
// }
abstract class AllCardsSeoScreenUserCardsService {
  Future<Either<RewildError, void>> addProductCard({
    required int sku,
    required String img,
    required String mp,
    required String name,
    required int subjectId,
  });
}

// abstract class AllCardsSeoScreenCardOfProductService {
//   Future<Either<RewildError, List<CardOfProductModel>>> getAll(
//       [List<int>? nmIds]);
// }

abstract class AllCardsSeoContentService {
  Future<Either<RewildError, CardCatalog>> fetchNomenclatures();
  Future<Either<RewildError, bool>> apiKeyExist();
}

class AllCardsSeoViewModel extends ResourceChangeNotifier {
  AllCardsSeoViewModel({
    required super.context,
    required this.contentService,
    required this.authService,
    // required this.updateService,
    required this.userCardsService,
    // required this.cardOfProductService
  }) {
    _asyncInit();
  }
  // constructor params ========================================================
  // final AllCardsSeoScreenCardOfProductService cardOfProductService;
  final AllCardsSeoContentService contentService;
  final AllCardsSeoAuthService authService;
  final AllCardsSeoScreenUserCardsService userCardsService;
  // final AllCardsSeoUpdateService updateService;
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
    // final nmIds = _cardsContent.map((e) => e.nmID).toList();
    // final allCardsOrNull =
    //     await fetch(() => cardOfProductService.getAll(nmIds));
    // List<int> savedNmIds = [];
    // if there are no cards in local storage
    // if (allCardsOrNull == null) {
    //   savedNmIds = [];
    // } else {
    //   // filter only the saved cards with images and names and get their nmIds
    //   savedNmIds = allCardsOrNull
    //       .where((e) => e.img.isNotEmpty && e.name.isNotEmpty)
    //       .map((e) => e.nmId)
    //       .toList();
    // }

    // get cards that are not in local storage or that have no images and names
    // final notSavedCards =
    //     contentOrNull.cards.where((card) => !savedNmIds.contains(card.nmID));

    List<CardOfProductModel> cardOfProducts = [];

    // add all cards that are not in local storage
    for (final c in contentOrNull.cards) {
      final sku = c.nmID;
      final img = c.photos.first.big;
      final name = c.title;
      final subjectID = c.subjectID;
      await userCardsService.addProductCard(
          sku: sku, img: img, mp: "wb", name: name, subjectId: subjectID);
      final cardOfProduct = CardOfProductModel(
        nmId: sku,
        img: img,
        name: name,
      );
      cardOfProducts.add(cardOfProduct);
    }

    // set cards for view

    setCards(cardOfProducts);

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
