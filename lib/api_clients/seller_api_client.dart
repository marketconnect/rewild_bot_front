import 'dart:convert';

import 'package:fpdart/fpdart.dart';

import 'package:http/http.dart' as http;
import 'package:rewild_bot_front/.env.dart';
import 'package:rewild_bot_front/core/utils/api_helpers/seller_api_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/domain/entities/seller_model.dart';
import 'package:rewild_bot_front/domain/services/seller_service.dart';

class SellerApiClient implements SellerServiceSelerApiClient {
  const SellerApiClient();
  @override
  Future<Either<RewildError, SellerModel>> get(
      {required int supplierId}) async {
    try {
      await sendMessageToTelegramBot(
          TBot.tBotErrorToken, TBot.tBotErrorChatId, 'supplierId $supplierId');
      final uri = Uri.parse('https://rewild.website/api/seller/$supplierId');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SellerModel resultSeller = SellerModel.fromJson(data);
        await sendMessageToTelegramBot(
            TBot.tBotErrorToken, TBot.tBotErrorChatId, 'supplierId data $data');
        return right(resultSeller);
      } else {
        final wbApiHelper = SellerApiHelper.get;
        final errString = wbApiHelper.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          sendToTg: false,
          errString,
          source: "SellerApiClient",
          name: "get",
          args: [supplierId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: false,
        "Ошибка при обращении к WB: $e",
        source: "SellerApiClient",
        name: "get",
        args: [supplierId],
      ));
    }
  }
}
