import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/api_helpers/wb_search_suggestion_api_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/services/wb_search_suggestion_service.dart';

class WBSearchSuggestionApiClient
    implements WBSearchSuggestionServiceApiClient {
  const WBSearchSuggestionApiClient();
  @override
  Future<Either<RewildError, List<String>>> fetchSuggestions({
    required String query,
    String gender = "common",
    String locale = "ru",
    String lang = "ru",
  }) async {
    final params = {
      "query": query,
      "gender": gender,
      "locale": locale,
      "lang": lang,
    };
    final uri = WBSearchSuggestionApiHelper.buildUri(params);

    try {
      final response =
          await http.get(uri, headers: WBSearchSuggestionApiHelper.headers);

      if (response.statusCode == 200) {
        final data =
            json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        // Filter entries where 'type' is 'suggest' and map them to their 'name'
        final List<String> suggestions = data
            .where((item) => item['type'] == 'suggest')
            .map((item) => item['name'] as String)
            .toList();
        return Right(suggestions);
      } else if (response.statusCode == 204) {
        return right([]);
      } else {
        return Left(RewildError(
          sendToTg: false,
          "Error during fetch: ${response.statusCode}",
          source: runtimeType.toString(),
          name: "fetchSuggestions",
          args: [query, gender, locale, lang],
        ));
      }
    } catch (e) {
      return Left(RewildError(
        sendToTg: false,
        "Error during fetch: $e",
        source: runtimeType.toString(),
        name: "fetchSuggestions",
        args: [query, gender, locale, lang],
      ));
    }
  }
}
