import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/commission_model.dart';
import 'package:rewild_bot_front/domain/entities/hive/tariff.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CommissionApiClient implements UpdateServiceTariffApiClient {
  const CommissionApiClient();

  @override
  Future<Either<RewildError, CommissionModel>> get({
    required String token,
    required int id,
  }) async {
    final url = Uri.parse('https://rewild.website/api/getCommission');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'id': id});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final commission = CommissionModel(
          id: id,
          category: responseData['category'],
          subject: responseData['subject'],
          commission: responseData['commission'],
          fbs: responseData['fbs'],
          fbo: responseData['fbo'],
        );
        return right(commission);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении комиссии: ${response.statusCode}",
          source: runtimeType.toString(),
          name: "get",
          args: [id],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "get",
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<Tariff>>> getTarrifs({
    required String token,
  }) async {
    final url = Uri.parse('https://rewild.website/api/getTariffs');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final tariffs = (responseData['tariff'] as List)
            .map((item) => Tariff(
                  coef: item['coef'],
                  storeId: item['storeId'],
                  type: item['type'],
                  wh: item['wh'],
                ))
            .toList();

        return right(tariffs);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении тарифов: ${response.statusCode}",
          source: runtimeType.toString(),
          name: "getTarrifs",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "getTarrifs",
        args: [],
      ));
    }
  }
}
