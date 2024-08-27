import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/commission_model.dart';

import 'package:rewild_bot_front/domain/entities/tariff_model.dart';
import 'package:rewild_bot_front/domain/services/commission_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CommissionApiClient
    implements
        UpdateServiceTariffApiClient,
        CommissionServiceCommissionApiClient {
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
          source: "CommissionApiClient",
          name: "get",
          args: [id],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "CommissionApiClient",
        name: "get",
        args: [id],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<TariffModel>>> getTarrifs({
    required String token,
  }) async {
    final url = Uri.parse('https://rewild.website/api/getTariffsV2');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Изменено на 'tariffs'
        if (responseData['tariffs'] is List) {
          final tariffs = (responseData['tariffs'] as List).map((item) {
            return TariffModel(
              deliveryBase: item['deliveryBase'] as double,
              deliveryLiter: item['deliveryLiter'] as double,
              storageBase: item['storageBase'] == null
                  ? 0.0
                  : item['storageBase'] as double,
              storageLiter: item['storageLiter'] == null
                  ? 0.0
                  : item['storageLiter'] as double,
              warehouseId: item['warehouseId'] ?? 0,
              warehouseType: item['warehouseType'] as String,
            );
          }).toList();

          return right(tariffs);
        } else {
          return left(RewildError(
            sendToTg: true,
            "Неверный формат данных: ожидается список тарифов",
            source: "CommissionApiClient",
            name: "getTarrifs",
            args: [],
          ));
        }
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении тарифов: ${response.statusCode}",
          source: "CommissionApiClient",
          name: "getTarrifs",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "CommissionApiClient",
        name: "getTarrifs",
        args: [],
      ));
    }
  }
}
