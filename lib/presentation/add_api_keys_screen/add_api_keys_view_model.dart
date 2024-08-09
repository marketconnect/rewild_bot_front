import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/core/utils/jwt_decode.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
import 'package:rewild_bot_front/domain/entities/hive/user_seller.dart';

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

class AddApiKeysScreenViewModel extends ResourceChangeNotifier {
  final AddApiKeysScreenApiKeysService apiKeysService;
  AddApiKeysScreenViewModel({
    required super.context,
    required this.apiKeysService,
  }) {
    _asyncInit();
  }

  List<ApiKeyModel> _apiKeys = [];
  void setApiKeys(List<ApiKeyModel> apiKeys) {
    _apiKeys = apiKeys;
    notify();
  }

  bool _isLoading = false;
  void setIsLoading(bool variable) {
    _isLoading = variable;
    notify();
  }

  bool get isLoading => _isLoading;

  List<ApiKeyModel> get apiKeys => _apiKeys;

  final Map<ApiKeyType, String> _types = ApiKeyConstants.apiKeyTypes;
  List<String> get types => _types.entries.map((e) => e.value).toList();

  List<String> _addedTypes = [];
  void setAddedTypes(List<String> addedTypes) {
    _addedTypes = addedTypes;
  }

  List<String> get addedTypes => _addedTypes;
  List<UserSeller> _userSellers = [];
  void setUserSellers(List<UserSeller> userSellers) {
    _userSellers = userSellers;
  }

  List<UserSeller> get userSellers => _userSellers;

  // active user seller
  UserSeller? get activeUserSeller =>
      userSellers.where((e) => e.isActive).isNotEmpty
          ? userSellers.where((e) => e.isActive).first
          : null;

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
    _asyncInit();

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
}
