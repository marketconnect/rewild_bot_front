import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/core/utils/jwt_decode.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';

import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
import 'package:rewild_bot_front/domain/entities/card_catalog.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/user_seller.dart';
import 'package:rewild_bot_front/env.dart';

// Api key service
abstract class AddApiKeysScreenApiKeysService {
  Future<Either<RewildError, List<ApiKeyModel>>> getAll(
      {required List<String> types});
  Future<Either<RewildError, bool>> add(
      {required String key,
      required String type,
      required String sellerId,
      required DateTime expiryDate,
      required String tokenReadOrWrite,
      required String sellerName});
  Future<Either<RewildError, void>> deleteApiKey({required ApiKeyModel apiKey});
  Future<Either<RewildError, List<UserSeller>>> getAllUserSellers();
  Future<Either<RewildError, void>> setActiveUserSeller(String id);
  Future<Either<RewildError, void>> renameSeller(String id, String name);
}

// Auth
abstract class AddApiKeysAuthService {
  Future<Either<RewildError, String>> getToken();
}

// Update
abstract class AddApiKeysUpdateService {
  Future<Either<RewildError, int>> insert(
      {required String token,
      required List<CardOfProductModel> cardOfProductsToInsert});
}

// Content
abstract class AddApiKeysContentService {
  Future<Either<RewildError, CardCatalog>> fetchNomenclatures();
  Future<Either<RewildError, bool>> apiKeyExist();
}

// Cards
abstract class AddApiKeysCardOfProductService {
  Future<Either<RewildError, List<CardOfProductModel>>> getAll(
      [List<int>? nmIds]);
}

class AddApiKeysScreenViewModel extends ResourceChangeNotifier {
  AddApiKeysScreenViewModel({
    required super.context,
    required this.apiKeysService,
    required this.contentService,
    required this.updateService,
    required this.cardOfProductService,
    required this.authService,
  }) {
    _asyncInit();
  }

  // constructor params
  final AddApiKeysScreenApiKeysService apiKeysService;
  final AddApiKeysUpdateService updateService;
  final AddApiKeysContentService contentService;
  final AddApiKeysCardOfProductService cardOfProductService;
  final AddApiKeysAuthService authService;

  // other fields
  // is loading
  bool _isLoading = false;
  void setIsLoading(bool variable) {
    _isLoading = variable;
    notify();
  }

  bool get isLoading => _isLoading;

  // Api keys
  final List<ApiKeyModel> _apiKeys = [];
  void setApiKeys(List<ApiKeyModel> apiKeys) {
    _apiKeys.clear();
    _apiKeys.addAll(apiKeys);
    notify();
  }

  List<ApiKeyModel> get apiKeys => _apiKeys;

  // types
  final Map<ApiKeyType, String> _types = ApiKeyConstants.apiKeyTypes;
  List<String> get types => _types.entries.map((e) => e.value).toList();

  // added types
  final List<String> _addedTypes = [];
  void setAddedTypes(List<String> addedTypes) {
    _addedTypes.clear();
    _addedTypes.addAll(addedTypes);
  }

  List<String> get addedTypes => _addedTypes;

  // user sellers
  final List<UserSeller> _userSellers = [];
  void setUserSellers(List<UserSeller> userSellers) {
    _userSellers.clear();
    _userSellers.addAll(userSellers);
  }

  List<UserSeller> get userSellers => _userSellers;

  // active user seller
  UserSeller? get activeUserSeller =>
      userSellers.where((e) => e.isActive).isNotEmpty
          ? userSellers.where((e) => e.isActive).first
          : null;

  // Methods
  void _asyncInit() async {
    setIsLoading(true);
    final fetchedApiKeys =
        await fetch(() => apiKeysService.getAll(types: types));

    if (fetchedApiKeys == null) {
      setIsLoading(false);
      return;
    }

    setApiKeys(fetchedApiKeys);
    _addedTypes.clear();
    for (final apiKey in fetchedApiKeys) {
      _addedTypes.add(apiKey.type);
    }
    final uSellers = await fetch(() => apiKeysService.getAllUserSellers());
    if (uSellers != null) {
      setUserSellers(uSellers);
    }

    // active user seller

    setIsLoading(false);
  }

  _update() async {
    setIsLoading(true);
    // fetch api keys and update
    final fetchedApiKeys =
        await fetch(() => apiKeysService.getAll(types: types));

    if (fetchedApiKeys == null) {
      setIsLoading(false);
      return;
    }

    setApiKeys(fetchedApiKeys);

    _addedTypes.clear();
    for (final apiKey in fetchedApiKeys) {
      _addedTypes.add(apiKey.type);
    }
    final uSellers = await fetch(() => apiKeysService.getAllUserSellers());
    if (uSellers != null) {
      setUserSellers(uSellers);
    }

    if (_addedTypes.contains(ApiKeyConstants.apiKeyTypes[ApiKeyType.content])) {
      await updateUsersCards();
    }

    setIsLoading(false);
  }

  Future<void> add(
    String key,
  ) async {
    final t = decodeJWT(key, 'ru');

    if (t.isEmpty) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "API-ключ не действителен.(Личный кабинет WB партнеры -> Настройки профиля -> Доступ к API -> Создать новый токен)."),
        ));
      }
      setIsLoading(false);
      return;
    }

    final readOrWrite = t['tokenReadOrWrite'];
    final expired = t['timeEnd'];
    final expiredDateTime = DateTime.tryParse(expired);

    final scops = t['scopes'];
    final userId = t['sellerId'];
    if (scops == null ||
        scops.isEmpty ||
        expiredDateTime == null ||
        readOrWrite == null) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "API-ключ не действителен.(Личный кабинет WB партнеры -> Настройки профиля -> Доступ к API -> Создать новый токен)."),
        ));
      }
      setIsLoading(false);
      return;
    }

    for (var scope in scops) {
      if (scope == 'Вопросы и отзывы') {
        scope = 'Вопросы/Отз.';
      }
      setIsLoading(true);
      final result = await fetch(() => apiKeysService.add(
          key: key,
          type: scope,
          sellerId: userId,
          sellerName: userId,
          tokenReadOrWrite: readOrWrite,
          expiryDate: expiredDateTime));

      if (result == false && context.mounted) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "API-ключ не действителен.(Личный кабинет WB партнеры -> Настройки профиля -> Доступ к API -> Создать новый токен)."),
          ));
        }
        setIsLoading(false);
        return;
      }
    }
    _update();

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> delete() async {
    for (int index = 0; index < _apiKeys.length; index++) {
      if (_apiKeys[index].isSelected) {
        await fetch(() => apiKeysService.deleteApiKey(apiKey: _apiKeys[index]));
      }
    }

    _asyncInit();
  }

  void select(int index) {
    _apiKeys[index].toggleSelected();
    notify();
  }

  Future<void> selectSeller(String sellerId) async {
    await fetch(() => apiKeysService.setActiveUserSeller(sellerId));
    _asyncInit();
  }

  Future<void> renameSeller(String id, String name) async {
    await fetch(() => apiKeysService.renameSeller(id, name));
    _asyncInit();
  }

  Future<void> updateUsersCards() async {
    // check if wb content api key exists
    final apiKey = await fetch(() => contentService.apiKeyExist());
    if (apiKey == null || !apiKey) {
      return;
    }
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
      return;
    }

    final nmIds = contentOrNull.cards.map((e) => e.nmID).toList();
    List<int> savedNmIds = [];

    // get local saved cards nmIds
    final allSavedCardsOrNull =
        await fetch(() => cardOfProductService.getAll(nmIds));
    if (allSavedCardsOrNull != null) {
      await sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
          'allCardsOrNull  != null ${allSavedCardsOrNull.length}');
      savedNmIds = allSavedCardsOrNull.map((e) => e.nmId).toList();
    }
    await sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
        'allCardsOrNull ${allSavedCardsOrNull!.length}');

    // get cards that are not in local storage
    List<CardItem> notSavedCards = [];
    if (savedNmIds.isEmpty) {
      notSavedCards = contentOrNull.cards;
    } else {
      notSavedCards = contentOrNull.cards
          .where((card) => !savedNmIds.contains(card.nmID))
          .toList();
    }

    List<CardOfProductModel> cardOfProducts = [];
    await sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
        'notSavedCards ${notSavedCards.length}');
    for (final c in notSavedCards) {
      await sendMessageToTelegramBot(
          TBot.tBotErrorToken, TBot.tBotErrorChatId, '${c.toMap()}');

      final nmId = c.nmID;
      final img = c.photos.first.big;
      final cardOfProduct = CardOfProductModel(
        nmId: nmId,
        img: img,
      );
      cardOfProducts.add(cardOfProduct);
    }
    if (cardOfProducts.isNotEmpty) {
      final tokenOrNull = await fetch(() => authService.getToken());
      if (tokenOrNull == null) {
        return;
      }

      await updateService.insert(
          token: tokenOrNull, cardOfProductsToInsert: cardOfProducts);
    }
  }
}
