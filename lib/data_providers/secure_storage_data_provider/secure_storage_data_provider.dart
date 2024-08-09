import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
import 'package:rewild_bot_front/domain/services/api_keys_service.dart';

class SecureStorageProvider implements ApiKeysServiceApiKeysDataProvider {
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

  static Future<Either<RewildError, void>> updateUserInfoInBg(
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

  static Future<Either<RewildError, String?>> getServerTokenInBg() async {
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

  static Future<Either<RewildError, bool>> tokenNotExpiredInBg() async {
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
  // @override
  // Future<Either<RewildError, String?>> getUsername() async {

  //   try {
  //     final resultEither = await _read(key: 'username');
  //     if (resultEither.isLeft()) {
  //       return resultEither;
  //     }
  //     final username =
  //         resultEither.fold((l) => throw UnimplementedError(), (r) => r);
  //     if (username == null) {
  //       var uuid = const Uuid();
  //       final deviceId = uuid.v4();

  //       // Save username
  //       final result = await _write(key: 'username', value: deviceId);
  //       if (result.isLeft()) {
  //         return left(result.fold((l) => l, (r) => throw UnimplementedError()));
  //       }

  //       return right(deviceId);
  //     } else {
  //       return right(username);
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: true,
  //       e.toString(),
  //       source: runtimeType.toString(),
  //       name: 'getUsername',
  //       args: [],
  //     ));
  //   }
  // }

  // static Future<Either<RewildError, String?>> getUsernameInBg() async {
  //   // May be deviceId already exists
  //   try {
  //     final resultEither = await _read(key: 'username');
  //     if (resultEither.isLeft()) {
  //       return resultEither;
  //     }
  //     final username =
  //         resultEither.fold((l) => throw UnimplementedError(), (r) => r);
  //     if (username == null) {
  //       var uuid = const Uuid();
  //       final deviceId = uuid.v4();

  //       // Save username

  //       final result = await _write(key: 'username', value: deviceId);
  //       if (result.isLeft()) {
  //         return left(result.fold((l) => l, (r) => throw UnimplementedError()));
  //       }

  //       return right(deviceId);
  //     } else {
  //       return right(username);
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: true,
  //       e.toString(),
  //       source: 'SecureStorageProvider',
  //       name: 'getUsername',
  //       args: [],
  //     ));
  //   }
  // }

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
      result.fold((l) => left(l), (r) {
        if (r != null) {
          try {
            final apiKey = ApiKeyModel.fromJson(jsonDecode(r));
            // Check if API key is expired
            if (apiKey.expiryDate.isAfter(DateTime.now())) {
              apiKeys.add(apiKey);
            }
          } catch (e) {
            return left(RewildError(
              sendToTg: true,
              e.toString(),
              source: runtimeType.toString(),
              name: 'getAllWBApiKeys',
              args: [],
            ));
          }
        }
      });
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
        source: runtimeType.toString(),
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
        source: runtimeType.toString(),
        name: 'storeUserBalance',
      ));
    }
  }

  // Retrieve the balance
  @override
  Future<Either<RewildError, double>> getUserBalance() async {
    try {
      String? value = await _secureStorage.read(
        key: 'user_balance',
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      );
      if (value != null) {
        return right(double.parse(value));
      }
      return right(0);
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        e.toString(),
        source: runtimeType.toString(),
        name: 'getUserBalance',
      ));
    }
  }

  // Add the balance
  @override
  Future<Either<RewildError, void>> addBalance(double amountToAdd) async {
    Either<RewildError, double> currentBalanceResult = await getUserBalance();
    return currentBalanceResult.match(
      (error) => left(error),
      (currentBalance) {
        double updatedBalance = currentBalance + amountToAdd;
        return storeUserBalance(updatedBalance);
      },
    );
  }

  // Subtract the balance
  @override
  Future<Either<RewildError, void>> subtractBalance(
      double amountToSubtract) async {
    Either<RewildError, double> currentBalanceResult = await getUserBalance();
    return currentBalanceResult.match(
      (error) => left(error),
      (currentBalance) {
        double updatedBalance = currentBalance - amountToSubtract;
        return storeUserBalance(updatedBalance);
      },
    );
  }

  // Function to write data to secure storage ==================================
  static Future<Either<RewildError, void>> _write(
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
        source: 'secureStorage',
        name: '_write',
        args: [key, value],
      ));
    }
  }

  // Function to get API key from secure storage in the background
  static Future<Either<RewildError, ApiKeyModel?>> getApiKeyFromBackground(
      String type, String sellerId) async {
    final result = await _read(key: '${type}_$sellerId');

    return result.fold((l) => left(l), (r) {
      if (r == null) {
        return right(null);
      }

      return right(ApiKeyModel.fromJson(jsonDecode(r)));
    });
  }

  // Function to read a value from secure storage
  static Future<Either<RewildError, String?>> _read(
      {required String key}) async {
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
}
