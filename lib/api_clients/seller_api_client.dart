import 'dart:convert';

import 'package:fpdart/fpdart.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import 'package:rewild_bot_front/core/utils/api_helpers/seller_api_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/seller_model.dart';
import 'package:rewild_bot_front/domain/services/seller_service.dart';
import 'package:rewild_bot_front/env.dart';

class SellerApiClient implements SellerServiceSelerApiClient {
  const SellerApiClient();
  @override
  Future<Either<RewildError, SellerModel>> get(
      {required int supplierId}) async {
    try {
      final uri = Uri.parse('${ServerConstants.apiUrl}/seller/$supplierId');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('application/json') ==
            true) {
          final data = jsonDecode(response.body);
          SellerModel resultSeller = SellerModel.fromJson(data);
          return right(resultSeller);
        } else {
          return right(SellerModel(supplierId: 0, name: ""));
        }
      } else {
        // Обработка неуспешных статусов
        final wbApiHelper = SellerApiHelper.get;
        final errString = wbApiHelper.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          sendToTg: true,
          errString,
          source: "SellerApiClient",
          name: "get",
          args: [supplierId],
        ));
      }
    } catch (e) {
      // Общая обработка ошибок
      return left(RewildError(
        sendToTg: true,
        "Ошибка при обращении к WB: $e",
        source: "SellerApiClient",
        name: "get",
        args: [supplierId],
      ));
    }
  }
}
