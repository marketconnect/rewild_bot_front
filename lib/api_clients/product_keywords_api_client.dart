import 'dart:convert';
import 'package:fpdart/fpdart.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/services/card_keywords_service.dart';

class ProductKeywordsApiClient implements CardKeywordsServiceApiClient {
  const ProductKeywordsApiClient();

  @override
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsForProducts({
    required String token,
    required List<int> skus,
  }) async {
    final url = Uri.parse('https://rewild.website/api/getKeywordsForProduct');

    try {
      if (token.isEmpty || skus.isEmpty) {
        return left(RewildError(
          sendToTg: true,
          "Некорректные данные",
          source: runtimeType.toString(),
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
        final responseData = jsonDecode(response.body);
        if (responseData['keywords'] == null ||
            responseData['keywords'] is! List) {
          throw Exception("Invalid response format: ${response.body}");
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
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении ключевых слов: ${response.statusCode}",
          source: runtimeType.toString(),
          name: "getKeywordsForProduct",
          args: [skus],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "getKeywordsForProduct",
        args: [skus],
      ));
    }
  }
}
