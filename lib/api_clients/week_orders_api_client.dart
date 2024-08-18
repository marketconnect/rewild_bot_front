import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:rewild_bot_front/.env.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/order_model.dart';
import 'package:rewild_bot_front/domain/services/week_orders_service.dart';

class WeekOrdersApiClient implements WeekOrdersServiceWeekOrdersApiClient {
  const WeekOrdersApiClient();

  @override
  Future<Either<RewildError, List<OrderModel>>> getOrdersFromTo({
    required String token,
    required List<int> skus,
  }) async {
    try {
      if (token.isEmpty || skus.isEmpty) {
        return left(RewildError(
          sendToTg: true,
          "Некорректные данные",
          source: runtimeType.toString(),
          name: "getOrdersFromTo",
        ));
      }

      final url = Uri.parse('https://rewild.website/api/getOrdersFromTo');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
      };

      final body = jsonEncode({'skus': skus});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as List;
        final orders = responseData
            .map((order) => OrderModel.fromMap(order as Map<String, dynamic>))
            .toList();
        return right(orders);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка сервера: ${response.statusCode}",
          source: runtimeType.toString(),
          name: "getOrdersFromTo",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: ${e.toString()}",
        source: runtimeType.toString(),
        name: "getOrdersFromTo",
        args: [],
      ));
    }
  }
}
