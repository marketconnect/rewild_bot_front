import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/prices.dart';
import 'package:rewild_bot_front/domain/services/price_service.dart';
import 'package:rewild_bot_front/domain/services/tariff_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';
import 'package:rewild_bot_front/env.dart';

class PriceApiClient
    implements
        UpdateServiceAverageLogisticsApiClient,
        PriceServicePriceApiClient,
        TariffServiceAverageLogisticsApiClient {
  const PriceApiClient();

  @override
  Future<Either<RewildError, int>> addSubscriptionInfo({
    required String token,
    required int price,
  }) async {
    final url = Uri.parse('${ServerConstants.apiUrl}/addSubscriptionInfo');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'price': price});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return right(responseData['price']);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при добавлении информации о подписке: ${response.statusCode}",
          source: "PriceApiClient",
          name: "addSubscriptionInfo",
          args: [price],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "PriceApiClient",
        name: "addSubscriptionInfo",
        args: [price],
      ));
    }
  }

  @override
  Future<Either<RewildError, Prices>> getCurrentPrice({
    required String token,
  }) async {
    final url = Uri.parse('${ServerConstants.apiUrl}/getPrice');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return right(Prices.fromMap(responseData));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении текущей цены: ${response.statusCode}",
          source: "PriceApiClient",
          name: "getCurrentPrice",
          args: [],
        ));
      }
    } catch (e, stackTrace) {
      return left(RewildError(
        sendToTg: true,
        "Error occurred during getCurrentPrice: ${e.toString()}",
        source: "PriceApiClient",
        name: "getCurrentPrice",
        args: [stackTrace.toString()],
      ));
    }
  }
}
