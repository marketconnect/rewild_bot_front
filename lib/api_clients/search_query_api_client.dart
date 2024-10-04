import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/messages_constants.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/services/wb_search_suggestion_service.dart';

class SearchQueryApiClient
    implements WbSearchSuggestionServiceSearchQueryApiClient {
  const SearchQueryApiClient();

  @override
  Future<Either<RewildError, List<(String, int)>>> getSearchQuery(
      {required String token, required List<String> queries}) async {
    final url = Uri.parse('https://rewild.website/api/getSearchQuery');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'queries': queries});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> frequencies = data['frequencies'];

        List<(String, int)> result = [];
        for (int i = 0; i < frequencies.length; i++) {
          result.add((queries[i], frequencies[i] as int));
        }
        return right(result);
      } else if (response.statusCode == 429) {
        return left(RewildError(
          sendToTg: false,
          MessagesConstants.rateLimitExceeded,
          source: "SearchQueryApiClient",
          name: "getSearchQuery",
          args: [queries],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении данных: ${response.statusCode}",
          source: "SearchQueryApiClient",
          name: "getSearchQuery",
          args: [queries],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SearchQueryApiClient",
        name: "getSearchQuery",
        args: [queries],
      ));
    }
  }
}
