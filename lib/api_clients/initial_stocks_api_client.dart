import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/initial_stock_model.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class InitialStocksApiClient
    implements UpdateServiceInitialStockModelApiClient {
  const InitialStocksApiClient();

  @override
  Future<Either<RewildError, List<InitialStockModel>>> get({
    required String token,
    required List<int> skus,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final url = Uri.parse('https://rewild.website/api/getStocks');
    final dateToSave = dateFrom.add(const Duration(seconds: 6));

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'skus': skus,
      'from': dateFrom.millisecondsSinceEpoch,
      'to': dateTo.millisecondsSinceEpoch,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['stocks'] == null || responseData['stocks'] is! List) {
          throw Exception("Invalid response format: ${response.body}");
        }

        final List<dynamic> stocksData = responseData['stocks'];
        final initialStocks = stocksData.map((stock) {
          return InitialStockModel(
            nmId: stock['sku'] as int,
            wh: stock['wh'] as int,
            sizeOptionId: stock['sizeOptionId'] as int,
            date: dateToSave,
            qty: stock['qty'] as int,
          );
        }).toList();

        return right(initialStocks);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении запасов: ${response.statusCode}",
          source: "InitialStocksApiClient",
          name: "get",
          args: [skus, dateFrom, dateTo],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "InitialStocksApiClient",
        name: "get",
        args: [skus, dateFrom, dateTo],
      ));
    }
  }
}
