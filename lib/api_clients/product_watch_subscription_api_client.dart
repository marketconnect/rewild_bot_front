import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/product_watch_delete_subscription_response.dart';
import 'package:rewild_bot_front/domain/entities/product_watch_subscription_response.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class ProductWatchSubscriptionApiClient {
  const ProductWatchSubscriptionApiClient();

  Future<Either<RewildError, ProductWatchSubscriptionResponse>>
      addProductWatchSubscription({
    required int productId,
    required String eventType,
    required int warehouseId,
    required int threshold,
    required bool lessThan,
  }) async {
    final url = Uri.parse("https://yourapi.com/addProductWatchSubscription");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product_id': productId,
          'event_type': eventType,
          'warehouse_id': warehouseId,
          'threshold': threshold,
          'less_than': lessThan,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return right(ProductWatchSubscriptionResponse(
          subscriptionId: data['subscription_id'],
          message: data['message'],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при добавлении подписки: ${response.statusCode}",
          source: "ProductWatchSubscriptionApiClient",
          name: "addProductWatchSubscription",
          args: [productId, eventType, warehouseId, threshold, lessThan],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "ProductWatchSubscriptionApiClient",
        name: "addProductWatchSubscription",
        args: [productId, eventType, warehouseId, threshold, lessThan],
      ));
    }
  }

  Future<Either<RewildError, ProductWatchDeleteSubscriptionResponse>>
      deleteProductWatchSubscription({
    required int productId,
    required String eventType,
  }) async {
    final url = Uri.parse("https://yourapi.com/deleteProductWatchSubscription");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product_id': productId,
          'event_type': eventType,
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
          "Ошибка при удалении подписки: ${response.statusCode}",
          source: "ProductWatchSubscriptionApiClient",
          name: "deleteProductWatchSubscription",
          args: [productId, eventType],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "ProductWatchSubscriptionApiClient",
        name: "deleteProductWatchSubscription",
        args: [productId, eventType],
      ));
    }
  }
}
