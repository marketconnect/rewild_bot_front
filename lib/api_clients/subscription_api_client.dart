import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/subscription_api_models.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:rewild_bot_front/domain/services/subscription_service.dart';

class SubscriptionApiClient
    implements SubscriptionServiceSubscriptionApiClient {
  const SubscriptionApiClient();

  // Добавляем новые методы ниже...

  @override
  Future<Either<RewildError, AddSubscriptionV2Response>> addSubscriptionV2({
    required String token,
    required String subscriptionType,
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse("https://rewild.website/api/addSubscriptionV2");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subscriptionType': subscriptionType,
          'startDate': startDate,
          'endDate': endDate,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return right(AddSubscriptionV2Response(
          err: data['err'],
          subscriptionId: data['subscription_id'],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при добавлении подписки V2: ${response.statusCode}",
          source: "SubscriptionApiClient",
          name: "addSubscriptionV2",
          args: [subscriptionType, startDate, endDate],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SubscriptionApiClient",
        name: "addSubscriptionV2",
        args: [subscriptionType, startDate, endDate],
      ));
    }
  }

  @override
  Future<Either<RewildError, SubscriptionV2Response>> getSubscriptionV2({
    required String token,
  }) async {
    final url = Uri.parse("https://rewild.website/api/getSubscriptionV2");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return right(SubscriptionV2Response(
          id: data['id'],
          subscriptionTypeName: data['subscription_type_name'],
          startDate: data['start_date'],
          endDate: data['end_date'],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении подписки V2: ${response.statusCode}",
          source: "SubscriptionApiClient",
          name: "getSubscriptionV2",
          args: [token],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SubscriptionApiClient",
        name: "getSubscriptionV2",
        args: [token],
      ));
    }
  }

  @override
  Future<Either<RewildError, UpdateSubscriptionV2Response>>
      updateSubscriptionV2({
    required String token,
    required int subscriptionID,
    required String subscriptionType,
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse("https://rewild.website/api/updateSubscriptionV2");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subscriptionID': subscriptionID,
          'subscriptionType': subscriptionType,
          'startDate': startDate,
          'endDate': endDate,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return right(UpdateSubscriptionV2Response(
          err: data['err'],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при обновлении подписки V2: ${response.statusCode}",
          source: "SubscriptionApiClient",
          name: "updateSubscriptionV2",
          args: [subscriptionID, subscriptionType, startDate, endDate],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SubscriptionApiClient",
        name: "updateSubscriptionV2",
        args: [subscriptionID, subscriptionType, startDate, endDate],
      ));
    }
  }

  @override
  Future<Either<RewildError, ExtendSubscriptionV2Response>>
      extendSubscriptionV2({
    required String token,
    required int subscriptionId,
    required String newEndDate,
  }) async {
    final url = Uri.parse("https://rewild.website/api/extendSubscriptionV2");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subscription_id': subscriptionId,
          'new_end_date': newEndDate,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return right(ExtendSubscriptionV2Response(
          err: data['err'],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при продлении подписки V2: ${response.statusCode}",
          source: "SubscriptionApiClient",
          name: "extendSubscriptionV2",
          args: [subscriptionId, newEndDate],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SubscriptionApiClient",
        name: "extendSubscriptionV2",
        args: [subscriptionId, newEndDate],
      ));
    }
  }

  @override
  Future<Either<RewildError, AddCardsToSubscriptionResponse>>
      addCardsToSubscription({
    required String token,
    required List<CardToSubscription> cards,
  }) async {
    final url = Uri.parse("https://rewild.website/api/addCardsToSubscription");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cards': cards
              .map((card) => {
                    'sku': card.sku,
                    'name': card.name,
                    'image': card.image,
                  })
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return right(AddCardsToSubscriptionResponse(
          err: data['err'],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при добавлении карт в подписку: ${response.statusCode}",
          source: "SubscriptionApiClient",
          name: "addCardsToSubscription",
          args: [cards],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SubscriptionApiClient",
        name: "addCardsToSubscription",
        args: [cards],
      ));
    }
  }

  @override
  Future<Either<RewildError, RemoveCardFromSubscriptionResponse>>
      removeCardFromSubscription({
    required String token,
    required int sku,
  }) async {
    final url =
        Uri.parse("https://rewild.website/api/removeCardFromSubscription");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sku': sku,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return right(RemoveCardFromSubscriptionResponse(
          err: data['err'],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при удалении карты из подписки: ${response.statusCode}",
          source: "SubscriptionApiClient",
          name: "removeCardFromSubscription",
          args: [sku],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SubscriptionApiClient",
        name: "removeCardFromSubscription",
        args: [sku],
      ));
    }
  }
}
