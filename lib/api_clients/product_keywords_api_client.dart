import 'dart:convert';
import 'package:fpdart/fpdart.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:rewild_bot_front/core/constants/messages_constants.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/services/card_keywords_service.dart';
import 'package:rewild_bot_front/env.dart';

class ProductKeywordsApiClient implements CardKeywordsServiceApiClient {
  const ProductKeywordsApiClient();

  @override
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsForProducts({
    required String token,
    required List<int> skus,
  }) async {
    final url = Uri.parse('${ServerConstants.apiUrl}/getKeywordsForProduct');

    try {
      if (token.isEmpty || skus.isEmpty) {
        return left(RewildError(
          sendToTg: true,
          "Некорректные данные",
          source: "ProductKeywordsApiClient",
          name: "getKeywordsForProduct",
        ));
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'skus': skus,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode((utf8.decode(response.bodyBytes)));
        if (responseData['keywords'] == null ||
            responseData['keywords'] is! List) {
          return right([]);
        }

        final List<dynamic> keywordsData = responseData['keywords'];
        final keywords = keywordsData.map((keyword) {
          return KwByLemma.fromKwFreq(
            keyword: keyword['phrase'],
            freq: keyword['freq'],
            sku: keyword['sku'],
          );
        }).toList();

        return right(keywords);
      } else if (response.statusCode == 429) {
        return left(RewildError(
          sendToTg: false,
          MessagesConstants.rateLimitExceeded,
          source: "ProductKeywordsApiClient",
          name: "getKeywordsForProduct",
          args: [skus],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении ключевых слов: ${response.statusCode}",
          source: "ProductKeywordsApiClient",
          name: "getKeywordsForProduct",
          args: [skus],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "ProductKeywordsApiClient",
        name: "getKeywordsForProduct",
        args: [skus],
      ));
    }
  }
}
