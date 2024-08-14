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
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'skus': skus,
      'from': dateFrom.toIso8601String(),
      'to': dateTo.toIso8601String(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final initialStocks = responseData.map((stock) {
          return InitialStockModel(
            nmId: stock['sku'],
            wh: stock['wh'],
            sizeOptionId: stock['sizeOptionId'],
            date: DateTime.parse(stock['date']),
            qty: stock['qty'],
          );
        }).toList();

        return right(initialStocks);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении запасов: ${response.statusCode}",
          source: runtimeType.toString(),
          name: "get",
          args: [skus, dateFrom, dateTo],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "get",
        args: [skus, dateFrom, dateTo],
      ));
    }
  }

  static Future<Either<RewildError, List<InitialStockModel>>> getInBackground({
    required String token,
    required List<int> skus,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final url = Uri.parse('https://rewild.website/api/getStocks');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'skus': skus,
      'from': dateFrom.toIso8601String(),
      'to': dateTo.toIso8601String(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final initialStocks = responseData.map((stock) {
          return InitialStockModel(
            nmId: stock['sku'],
            wh: stock['wh'],
            sizeOptionId: stock['sizeOptionId'],
            date: DateTime.parse(stock['date']),
            qty: stock['qty'],
          );
        }).toList();

        return right(initialStocks);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении запасов: ${response.statusCode}",
          source: "InitialStocksApiClient",
          name: "getInBackground",
          args: [skus, dateFrom, dateTo],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "InitialStocksApiClient",
        name: "getInBackground",
        args: [skus, dateFrom, dateTo],
      ));
    }
  }
}
