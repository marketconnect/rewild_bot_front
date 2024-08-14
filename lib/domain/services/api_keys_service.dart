import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
import 'package:rewild_bot_front/domain/entities/user_seller.dart';
import 'package:rewild_bot_front/presentation/add_api_keys_screen/add_api_keys_view_model.dart';

abstract class ApiKeysServiceApiKeysDataProvider {
  Future<Either<RewildError, List<ApiKeyModel>>> getAllWBApiKeys(
      List<String> types, String sellerId);
  Future<Either<RewildError, void>> addWBApiKey(ApiKeyModel card);
  Future<Either<RewildError, void>> deleteWBApiKey(
      String apiKeyType, String sellerId);
}

// advert
// abstract class ApiKeysServiceAdvertApiClient {
//   Future<Either<RewildError, int>> balance({required String token});
// }

// // Review
// abstract class ApiKeysServiceReviewApiClient {
//   Future<Either<RewildError, int>> getCountUnansweredReviews(
//       {required String token});
// }

// Analytics
// abstract class ApiKeysServiceAnalyticsApiClient {
//   Future<Either<RewildError, bool>> fetchExciseReport({
//     required String token,
//   });
// }

// Statistics
// abstract class ApiKeysServiceStatisticsApiClient {
//   Future<Either<RewildError, List<Income>>> fetchIncomes(
//       {required String token, required DateTime dateFrom});
// }

// Content
// abstract class ApiKeysServiceContentApiClient {
//   Future<Either<RewildError, bool>> fetchCardLimits({required String token});
// }

// active seller
abstract class ApiKeysServiceActiveSellerDataProvider {
  Future<Either<RewildError, List<UserSeller>>> getActive();
  Future<Either<RewildError, List<UserSeller>>> getAll();
  Future<Either<RewildError, void>> setActive(String sellerId);
  Future<Either<RewildError, void>> addOne(UserSeller seller);
  Future<Either<RewildError, void>> rename(String sellerId, String sellerName);
}

class ApiKeysService implements AddApiKeysScreenApiKeysService {
  final StreamController<Map<ApiKeyType, String>> apiKeyExistsStreamController;
  final ApiKeysServiceApiKeysDataProvider apiKeysDataProvider;
  final ApiKeysServiceActiveSellerDataProvider activeSellerDataProvider;
  // final ApiKeysServiceAdvertApiClient advertApiClient;
  // final ApiKeysServiceReviewApiClient reviewApiClient;
  // final ApiKeysServiceStatisticsApiClient statisticsApiClient;
  // final ApiKeysServiceAnalyticsApiClient analyticsApiClient;
  // final ApiKeysServiceContentApiClient contentApiClient;

  ApiKeysService(
      {required this.apiKeysDataProvider,
      // required this.advertApiClient,
      required this.activeSellerDataProvider,
      // required this.reviewApiClient,
      // required this.statisticsApiClient,
      // required this.analyticsApiClient,
      // required this.contentApiClient,
      required this.apiKeyExistsStreamController});
  static const Map<ApiKeyType, String> _types = ApiKeyConstants.apiKeyTypes;

  // Future<Either<RewildError, UserSeller>> getActiveSeller() async {
  //   final activeSellerEither = await activeSellerDataProvider.getActive();
  //   if (activeSellerEither.isLeft()) {
  //     return left(
  //         activeSellerEither.fold((l) => l, (r) => throw UnimplementedError()));
  //   }
  //   final activeSeller =
  //       activeSellerEither.fold((l) => throw UnimplementedError(), (r) => r);
  //   return right(activeSeller.first);
  // }

  @override
  Future<Either<RewildError, List<ApiKeyModel>>> getAll({
    required List<String> types,
  }) async {
    // Get active seller
    final activeSellerOrElse = await activeSellerDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);

    // Get Api key
    final apiKeysResult = await apiKeysDataProvider.getAllWBApiKeys(
        types, activeSeller.first.sellerId);
    return apiKeysResult;
  }

  // Function to delete api key and update stream
  @override
  Future<Either<RewildError, void>> deleteApiKey(
      {required ApiKeyModel apiKey}) async {
    final deleteResult = await apiKeysDataProvider.deleteWBApiKey(
      apiKey.type,
      apiKey.sellerId,
    );
    if (deleteResult.isLeft()) {
      return deleteResult;
    }

    if (apiKey.type == ApiKeyConstants.apiKeyTypes[ApiKeyType.promo]!) {
      apiKeyExistsStreamController.add({ApiKeyType.promo: ""});
    }

    if (apiKey.type == ApiKeyConstants.apiKeyTypes[ApiKeyType.question]!) {
      apiKeyExistsStreamController.add({ApiKeyType.question: ""});
    }

    return right(null);
  }

  // Function to add api key and update stream
  @override
  Future<Either<RewildError, bool>> add(
      {required String key,
      required String type,
      required String sellerId,
      required DateTime expiryDate,
      required String tokenReadOrWrite,
      required String sellerName}) async {
    // check either seller exists
    final sellerResultEither = await activeSellerDataProvider.getAll();
    if (sellerResultEither.isLeft()) {
      return left(RewildError(
        sendToTg: true,
        sellerResultEither.fold((l) => l.message, (r) => ""),
        source: runtimeType.toString(),
        name: 'add',
        args: [sellerId],
      ));
    }
    final sellersIds =
        sellerResultEither.fold((l) => throw UnimplementedError(), (r) => r);
    // new seller
    if (!sellersIds.any((element) => element.sellerId == sellerId)) {
      final addResEither = await _addNewSeller(UserSeller(
        sellerId: sellerId,
        sellerName: sellerName,
        isActive: true,
      ));
      if (addResEither.isLeft()) {
        return left(
            addResEither.fold((l) => l, (r) => throw UnimplementedError()));
      }
    }

    final apiKey = ApiKeyModel(
        token: key,
        type: type,
        sellerId: sellerId,
        expiryDate: expiryDate,
        tokenReadOrWrite: tokenReadOrWrite);
    // Determine the ApiKeyType based on the string type
    final apiKeyType = ApiKeyConstants.apiKeyTypes.entries
        .firstWhere((entry) => entry.value == type,
            orElse: () => const MapEntry(ApiKeyType.stat, ""))
        .key;

    final addApiKeyResult = await apiKeysDataProvider.addWBApiKey(apiKey);

    return addApiKeyResult.fold((l) => left(l), (r) {
      apiKeyExistsStreamController.add({apiKeyType: key});

      return right(true);
    });
  }

  // set current user

  // add seller
  Future<Either<RewildError, void>> _addNewSeller(UserSeller seller) async {
    final sellerResultEither = await activeSellerDataProvider.addOne(seller);

    if (sellerResultEither.isLeft()) {
      return left(RewildError(
        sendToTg: true,
        sellerResultEither.fold((l) => l.message, (r) => ""),
        source: runtimeType.toString(),
        name: 'add',
        args: [seller.sellerId],
      ));
    }

    // make active
    final makeActiveResult =
        await activeSellerDataProvider.setActive(seller.sellerId);
    if (makeActiveResult.isLeft()) {
      return left(RewildError(
        sendToTg: true,
        makeActiveResult.fold((l) => l.message, (r) => ""),
        source: runtimeType.toString(),
        name: 'add',
        args: [seller.sellerId],
      ));
    }
    return right(null);
  }

  @override
  Future<Either<RewildError, List<UserSeller>>> getAllUserSellers() async {
    return await activeSellerDataProvider.getAll();
  }

  @override
  Future<Either<RewildError, void>> setActiveUserSeller(String id) async {
    // get keys for the seller

    final keysForSellerResult = await apiKeysDataProvider.getAllWBApiKeys(
        _types.entries.map((e) => e.value).toList(), id);
    if (keysForSellerResult.isLeft()) {
      return left(RewildError(
        sendToTg: true,
        keysForSellerResult.fold((l) => l.message, (r) => ""),
        source: runtimeType.toString(),
        name: 'add',
        args: [id],
      ));
    }

    //
    final keysForSeller =
        keysForSellerResult.fold((l) => throw UnimplementedError(), (r) => r);

    // notify subscribers for existing keys
    for (final apiKey in keysForSeller) {
      ApiKeyType apiKeyType = _getType(apiKey);

      apiKeyExistsStreamController.add({apiKeyType: apiKey.token});
    }

    // notify subscribers for missing keys
    for (final type in ApiKeyConstants.apiKeyTypes.keys) {
      if (!keysForSeller.any((element) => _getType(element) == type)) {
        apiKeyExistsStreamController.add({type: ""});
      }
    }
    return await activeSellerDataProvider.setActive(id);
  }

  ApiKeyType _getType(ApiKeyModel apiKey) {
    final apiKeyType = _types.entries
        .where((element) => element.value == apiKey.type)
        .first
        .key;
    return apiKeyType;
  }

  @override
  Future<Either<RewildError, void>> renameSeller(String id, String name) async {
    return await activeSellerDataProvider.rename(id, name);
  }
}
