import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/telegram_web_apps_api.dart';
import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
import 'package:rewild_bot_front/domain/services/advert_service.dart';
import 'package:rewild_bot_front/domain/services/adverts_analitics_service.dart';

import 'package:rewild_bot_front/domain/services/api_keys_service.dart';
import 'package:rewild_bot_front/domain/services/auth_service.dart';
// import 'package:rewild_bot_front/domain/services/balance_service.dart';
import 'package:rewild_bot_front/domain/services/content_service.dart';
import 'package:rewild_bot_front/domain/services/keywords_service.dart';
import 'package:rewild_bot_front/domain/services/notification_service.dart';
import 'package:rewild_bot_front/domain/services/question_service.dart';
import 'package:rewild_bot_front/domain/services/realization_report_service.dart';
import 'package:rewild_bot_front/domain/services/review_service.dart';

class SecureStorageProvider
    implements
        ApiKeysServiceApiKeysDataProvider,
        KeywordsServiceApiKeyDataProvider,
        AdvertsAnaliticsServiceApiKeyDataProvider,
        NotificationServiceSecureDataProvider,
        ReviewServiceApiKeyDataProvider,
        ContentServiceApiKeyDataProvider,
        RealizationReportServiceApiKeyDataProvider,
        QuestionServiceApiKeyDataProvider,
        // BalanceServiceBalanceDataProvider,
        AdvertServiceApiKeyDataProvider,
        AuthServiceSecureDataProvider {
  static const _secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ));

  const SecureStorageProvider();

  // Function to update user-related data (e.g., username, token, etc.) in secure storage
  @override
  Future<Either<RewildError, void>> updateUserInfo(
      {String? token, String? expiredAt, bool? freebie}) async {
    if (token != null) {
      final result = await _write(key: 'token', value: token);
      if (result.isLeft()) {
        return result;
      }
    }
    if (expiredAt != null) {
      final result = await _write(key: 'token_expired_at', value: expiredAt);
      if (result.isLeft()) {
        return result;
      }
    }
    if (freebie != null) {
      final result = await _write(key: 'freevie', value: freebie ? "1" : "");
      if (result.isLeft()) {
        return result;
      }
    }
    return right(null);
  }

  // Function to read token from secure storage
  @override
  Future<Either<RewildError, String?>> getServerToken() async {
    // read token from local storage
    final resultEither = await _read(key: 'token');
    if (resultEither.isLeft()) {
      return resultEither;
    }
    final result =
        resultEither.fold((l) => throw UnimplementedError(), (r) => r);
    return right(result);
  }

  // Function to check if token is expired
  @override
  Future<Either<RewildError, bool>> tokenNotExpired() async {
    final result = await _read(key: 'token_expired_at');
    return result.fold(
      (l) => left(l),
      (r) {
        if (r == null) {
          return right(false);
        }
        final now = DateTime.now();
        final timestamp = int.parse(r);
        final expiredAtDT =
            DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        return right(
          expiredAtDT.isAfter(now),
        );
      },
    );
  }

  // Function to get username
  @override
  Future<Either<RewildError, String?>> getUsername() async {
    try {
      final resultEither = await _read(key: 'username');
      if (resultEither.isLeft()) {
        return resultEither;
      }
      final username =
          resultEither.fold((l) => throw UnimplementedError(), (r) => r);
      if (username == null) {
        final chatId = await TelegramWebApp.getChatId();

        // Save username
        final result = await _write(key: 'username', value: chatId);
        if (result.isLeft()) {
          return left(result.fold((l) => l, (r) => throw UnimplementedError()));
        }

        return right(chatId);
      } else {
        return right(username);
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SecureStorageProvider",
        name: 'getUsername',
        args: [],
      ));
    }
  }

  // Function to get an API key of a specific type =============================
  @override
  Future<Either<RewildError, ApiKeyModel?>> getWBApiKey(
      {required String type, required String sellerId}) async {
    final result = await _read(key: '${type}_$sellerId');

    return result.fold((l) => left(l), (r) {
      if (r == null) {
        return right(null);
      }
      final apiKey = ApiKeyModel.fromJson(jsonDecode(r));
      // Check if API key is expired
      if (apiKey.expiryDate.isBefore(DateTime.now())) {
        return right(null);
      }
      return right(apiKey);
    });
  }

  // Function to get all API keys of specific types

  @override
  Future<Either<RewildError, List<ApiKeyModel>>> getAllWBApiKeys(
      List<String> types, String sellerId) async {
    List<ApiKeyModel> apiKeys = [];

    for (final type in types) {
      final key = '${type}_$sellerId';
      final result = await _read(key: key);

      if (result.isLeft()) {
        // Логируем ошибку и возвращаем ее
        return left(result.fold((l) => l, (r) => throw UnimplementedError()));
      }

      final value = result.fold((l) => null, (r) => r);
      if (value == null) {
        continue;
      }

      try {
        final apiKey = ApiKeyModel.fromJson(jsonDecode(value));

        // Проверяем, не истек ли срок действия ключа
        if (apiKey.expiryDate.isAfter(DateTime.now())) {
          apiKeys.add(apiKey);
        } else {}
      } catch (e) {
        return left(RewildError(
          sendToTg: true,
          e.toString(),
          source: "SecureStorageProvider",
          name: 'getAllWBApiKeys',
          args: [],
        ));
      }
    }

    return right(apiKeys);
  }

  @override
  Future<Either<RewildError, void>> addWBApiKey(ApiKeyModel apiKey) async {
    final value = jsonEncode(apiKey.toJson());
    return await _write(key: '${apiKey.type}_${apiKey.sellerId}', value: value);
  }

  // Function to delete an API key from secure storage
  @override
  Future<Either<RewildError, void>> deleteWBApiKey(
      String apiKeyType, String sellerId) async {
    try {
      await _secureStorage.delete(
          key: '${apiKeyType}_$sellerId',
          aOptions: const AndroidOptions(encryptedSharedPreferences: true));
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SecureStorageProvider",
        name: 'deleteWBApiKey',
        args: [apiKeyType],
      ));
    }
  }

  // Balance ===================================================================
  // Store the balance
  Future<Either<RewildError, void>> storeUserBalance(double balance) async {
    try {
      await _secureStorage.write(
        key: 'user_balance',
        value: balance.toString(),
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      );
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: "SecureStorageProvider",
        name: 'storeUserBalance',
      ));
    }
  }

  // Function to write data to secure storage ==================================
  Future<Either<RewildError, void>> _write(
      {required String key, required String? value}) async {
    try {
      await _secureStorage.write(
          key: key,
          value: value,
          aOptions: const AndroidOptions(
            encryptedSharedPreferences: true,
          ));
      return right(null);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "could not write to secure storage: $e",
        source: 'SecureStorageProvider',
        name: '_write',
        args: [key, value],
      ));
    }
  }

  // Function to read a value from secure storage
  Future<Either<RewildError, String?>> _read({required String key}) async {
    try {
      final value = await _secureStorage.read(
        key: key,
        aOptions: const AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );

      return right(value);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "could not read from secure storage: $e",
        source: "SecureStorageDataProvider",
        name: '_read',
        args: [key],
      ));
    }
  }

  Future<void> debugPrintAllKeys() async {
    final allKeys = await _secureStorage.readAll();
    allKeys.forEach((key, value) {});
  }
}
