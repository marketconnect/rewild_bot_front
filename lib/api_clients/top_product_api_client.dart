import 'dart:convert';
import 'package:fpdart/fpdart.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/top_product.dart';
import 'package:rewild_bot_front/domain/services/top_products_service.dart';
import 'package:rewild_bot_front/env.dart';

class TopProductApiClient implements TopProductsServiceApiClient {
  const TopProductApiClient();

  @override
  Future<Either<RewildError, List<TopProduct>>> getTopProducts({
    required String token,
    required int subjectId,
  }) async {
    final url = Uri.parse('${ServerConstants.apiUrl}/getTopProducts');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
    };

    final body = {
      'subject_id': subjectId,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
        if (decodedResponse['top_products'] != null &&
            decodedResponse['top_products'] is List &&
            decodedResponse['top_products'].isNotEmpty) {
          final topProducts = (decodedResponse['top_products'] as List)
              .map((productJson) => TopProduct.fromJson(productJson))
              .toList();
          return right(topProducts);
        } else {
          return right([]);
        }
      } else if (response.statusCode == 401) {
        return left(RewildError(
          sendToTg: true,
          "Пользователь не авторизован",
          source: "TopProductApiClient",
          name: "getTopProducts",
          args: [],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка сервера: ${response.statusCode}",
          source: "TopProductApiClient",
          name: "getTopProducts",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: ${e.toString()}",
        source: "TopProductApiClient",
        name: "getTopProducts",
        args: [],
      ));
    }
  }
}
