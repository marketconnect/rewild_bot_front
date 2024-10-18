import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/wh_coeffs.dart';
import 'package:rewild_bot_front/domain/services/wf_cofficient_service.dart';
import 'package:rewild_bot_front/env.dart';

class WhCoefficientsApiClient
    implements WfCofficientServiceWfCofficientApiClient {
  const WhCoefficientsApiClient();

  @override
  Future<Either<RewildError, void>> subscribe({
    required String token,
    required int warehouseId,
    required double threshold,
  }) async {
    final url = Uri.parse("${ServerConstants.apiUrl}/subscribe");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'warehouse_id': warehouseId,
          'threshold': threshold,
        }),
      );

      if (response.statusCode == 200) {
        return right(null);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при подписке: ${response.statusCode}",
          source: "WhCoefficientsApiClient",
          name: "subscribe",
          args: [warehouseId, threshold],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "WhCoefficientsApiClient",
        name: "subscribe",
        args: [warehouseId, threshold],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> unsubscribe({
    required String token,
    required int warehouseId,
  }) async {
    final url = Uri.parse("${ServerConstants.apiUrl}/unsubscribe");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'warehouse_id': warehouseId,
        }),
      );

      if (response.statusCode == 200) {
        return right(null);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при отмене подписки: ${response.statusCode}",
          source: "WhCoefficientsApiClient",
          name: "unsubscribe",
          args: [warehouseId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "WhCoefficientsApiClient",
        name: "unsubscribe",
        args: [warehouseId],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<WarehouseCoeffs>>> getAllWarehouses({
    required String token,
  }) async {
    final url = Uri.parse("${ServerConstants.apiUrl}/getAllWarehouses");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
        List<WarehouseCoeffs> warehouses = (data['warehouses'] as List)
            .map((warehouse) =>
                WarehouseCoeffs.fromJson(warehouse as Map<String, dynamic>))
            .toList();
        print(warehouses);
        return right(warehouses);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении списка складов: ${response.statusCode}",
          source: "WhCoefficientsApiClient",
          name: "getAllWarehouses",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "WhCoefficientsApiClient",
        name: "getAllWarehouses",
        args: [],
      ));
    }
  }
}
