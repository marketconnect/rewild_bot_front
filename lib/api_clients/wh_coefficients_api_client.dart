import 'dart:convert';
import 'package:fpdart/fpdart.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';

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
    required int chatId,
    required UserSubscription sub,
  }) async {
    final url = Uri.parse("${ServerConstants.apiUrl}/subscribe");
    try {
      DateTime parsedFromDate = DateFormat('dd.MM.yyyy').parse(sub.fromDate);
      DateTime parsedToDate = DateFormat('dd.MM.yyyy').parse(sub.toDate);
      final dateFrom = formatDateForAnaliticsDetail(parsedFromDate);
      final dateTo = formatDateForAnaliticsDetail(parsedToDate);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'warehouse_id': sub.warehouseId,
          'box_type_id': sub.boxTypeId,
          'threshold': sub.threshold,
          'from_date': dateFrom,
          'to_date': dateTo,
          'chat_id': chatId
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
          args: [sub.warehouseId, sub.threshold],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "WhCoefficientsApiClient",
        name: "subscribe",
        args: [sub.warehouseId, sub.threshold],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> unsubscribe({
    required String token,
    required int warehouseId,
    required int boxTypeId,
    required int chatId,
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
          'box_type_id': boxTypeId,
          'chat_id': chatId
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
  Future<Either<RewildError, GetAllWarehousesResp>> getAllWarehouses({
    required String token,
    required int chatId,
  }) async {
    final url = Uri.parse("${ServerConstants.apiUrl}/getAllWarehouses");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'chat_id': chatId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final resp = GetAllWarehousesResp.fromJson(data);
        return right(resp);
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
