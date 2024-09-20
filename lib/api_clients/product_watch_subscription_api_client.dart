import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/get_all_subscriptions_for_user_response.dart';

import 'package:rewild_bot_front/domain/entities/product_watch_delete_subscription_response.dart';
import 'package:rewild_bot_front/domain/entities/product_watch_subscription_response.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:rewild_bot_front/domain/services/notification_service.dart';

class ProductWatchSubscriptionApiClient
    implements NotificationServiceProductWatchSubscriptionApiClient {
  const ProductWatchSubscriptionApiClient();

  @override
  Future<Either<RewildError, ProductWatchSubscriptionResponse>>
      addProductWatchSubscription({
    required String token,
    required String endDate,
    required List<Map<String, dynamic>> subscriptions,
  }) async {
    final url =
        Uri.parse("https://rewild.website/api/addProductWatchSubscription");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'end_date': endDate,
          'subscriptions': subscriptions,
        }),
      );
      print("addProductWatchSubscription: $subscriptions");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return right(ProductWatchSubscriptionResponse(
          qty: data['qty'],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при добавлении подписок: ${response.statusCode}",
          source: "ProductWatchSubscriptionApiClient",
          name: "addProductWatchSubscription",
          args: [subscriptions],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "ProductWatchSubscriptionApiClient",
        name: "addProductWatchSubscription",
        args: [subscriptions],
      ));
    }
  }

  @override
  Future<Either<RewildError, ProductWatchDeleteSubscriptionResponse>>
      deleteProductWatchSubscription({
    required String token,
    required List<Map<String, dynamic>> subscriptions,
  }) async {
    final url =
        Uri.parse("https://rewild.website/api/deleteProductWatchSubscription");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'subscriptions': subscriptions,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return right(ProductWatchDeleteSubscriptionResponse(
          message: data['message'],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при удалении подписок: ${response.statusCode}",
          source: "ProductWatchSubscriptionApiClient",
          name: "deleteProductWatchSubscription",
          args: [subscriptions],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "ProductWatchSubscriptionApiClient",
        name: "deleteProductWatchSubscription",
        args: [subscriptions],
      ));
    }
  }

  @override
  Future<Either<RewildError, GetAllSubscriptionsForUserAndProductResponse>>
      getAllSubscriptionsForUserAndProduct({
    required String token,
    required int productId,
  }) async {
    final url = Uri.parse(
        "https://rewild.website/api/getAllSubscriptionsForUserAndProduct");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': productId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Проверка на пустой ответ
        if (data.isEmpty) {
          return right(
              GetAllSubscriptionsForUserAndProductResponse(subscriptions: []));
        }

        return right(
            GetAllSubscriptionsForUserAndProductResponse.fromJson(data));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении всех подписок: ${response.statusCode}",
          source: "ProductWatchSubscriptionApiClient",
          name: "getAllSubscriptionsForUserAndProduct",
          args: [token, productId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "ProductWatchSubscriptionApiClient",
        name: "getAllSubscriptionsForUserAndProduct",
        args: [token, productId],
      ));
    }
  }
}
