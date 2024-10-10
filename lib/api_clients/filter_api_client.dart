import 'dart:convert';

import 'package:fpdart/fpdart.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:rewild_bot_front/core/constants/messages_constants.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/keyword_by_lemma.dart';
import 'package:rewild_bot_front/domain/entities/lemma_by_filter.dart';
import 'package:rewild_bot_front/domain/services/filter_values_service.dart';

class FilterApiClient implements FilterServiceFilterApiClient {
  const FilterApiClient();

  // @override
  // Future<Either<RewildError, List<String>>> getFilterValues({
  //   required String token,
  //   required String filterName,
  // }) async {
  //   try {
  //     final uri = Uri.parse(
  //         'https://rewild.website/api/getFilterValues?filterName=$filterName');
  //     final response = await http.get(uri, headers: {
  //       'Authorization': token,
  //     });

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);
  //       return right(List<String>.from(data));
  //     }
  //      else {
  //       return left(RewildError(
  //         sendToTg: true,
  //         "Ошибка HTTP: ${response.statusCode}",
  //         source: "FilterApiClient",
  //         name: "getFilterValues",
  //         args: [],
  //       ));
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: true,
  //       "Неизвестная ошибка: ${e.toString()}",
  //       source: "FilterApiClient",
  //       name: "getFilterValues",
  //       args: [],
  //     ));
  //   }
  // }

  @override
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsByLemmas({
    required String token,
    required List<int> lemmasIDs,
    required int filterID,
  }) async {
    try {
      final uri = Uri.parse('https://rewild.website/api/getKeywordsByLemmas');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'lemmasIDs': lemmasIDs,
          'filterID': filterID,
          'limit': 1000,
          'offset': 0,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json.containsKey('keywords')) {
          final List<dynamic> keywordsList = json['keywords'];
          return right(keywordsList.map((e) => KwByLemma.fromMap(e)).toList());
        } else {
          return left(RewildError(
            sendToTg: true,
            "Unexpected response structure: missing 'keywords'",
            source: "FilterApiClient",
            name: "getKeywordsByLemmas",
            args: [],
          ));
        }
      } else if (response.statusCode == 401) {
        return left(RewildError(
          sendToTg: false,
          MessagesConstants.statusUnauthorized,
          source: "FilterApiClient",
          name: "getKeywordsByLemmas",
          args: [],
        ));
      } else if (response.statusCode == 429) {
        return left(RewildError(
          sendToTg: false,
          MessagesConstants.rateLimitExceeded,
          source: "FilterApiClient",
          name: "getKeywordsByLemmas",
          args: [],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка HTTP: ${response.statusCode}",
          source: "FilterApiClient",
          name: "getKeywordsByLemmas",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: ${e.toString()}",
        source: "FilterApiClient",
        name: "getKeywordsByLemmas",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<KwByLemma>>> getKeywordsByWords({
    required String token,
    required List<String> words,
  }) async {
    try {
      final uri = Uri.parse('https://rewild.website/api/getKeywordsByWords');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'words': words,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('keywords') &&
            responseData['keywords'] != null) {
          final List<dynamic> keywordList = responseData['keywords'];

          return right(keywordList.map((e) => KwByLemma.fromMap(e)).toList());
        } else {
          return right([]);
        }
      } else if (response.statusCode == 401) {
        return left(RewildError(
          sendToTg: false,
          MessagesConstants.statusUnauthorized,
          source: "FilterApiClient",
          name: "getKeywordsByWords",
          args: [],
        ));
      } else if (response.statusCode == 429) {
        return left(RewildError(
          sendToTg: false,
          MessagesConstants.rateLimitExceeded,
          source: "FilterApiClient",
          name: "getKeywordsByWords",
          args: [],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка HTTP: ${response.statusCode}",
          source: "FilterApiClient",
          name: "getKeywordsByWords",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: ${e.toString()}",
        source: "FilterApiClient",
        name: "getKeywordsByWords",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<LemmaByFilterId>>> getLemmasByFilterId({
    required String token,
    required int filterID,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final uri = Uri.parse('https://rewild.website/api/getLemmasByFilterID');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'filterID': filterID,
          'limit': limit,
          'offset': offset,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check if 'lemmas' key is present in the JSON and is a List
        if (jsonResponse.containsKey('lemmas') &&
            jsonResponse['lemmas'] is List) {
          final List<dynamic> data = jsonResponse['lemmas'];
          return right(data.map((e) => LemmaByFilterId.fromMap(e)).toList());
        } else {
          return left(RewildError(
            sendToTg: true,
            "Unexpected response format",
            source: "FilterApiClient",
            name: "getLemmasByFilterId",
            args: [],
          ));
        }
      } else if (response.statusCode == 401) {
        return left(RewildError(
          sendToTg: false,
          MessagesConstants.statusUnauthorized,
          source: "FilterApiClient",
          name: "getLemmasByFilterId",
          args: [],
        ));
      } else if (response.statusCode == 429) {
        return left(RewildError(
          sendToTg: false,
          MessagesConstants.rateLimitExceeded,
          source: "FilterApiClient",
          name: "getLemmasByFilterId",
          args: [],
        ));
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка HTTP: ${response.statusCode}",
          source: "FilterApiClient",
          name: "getLemmasByFilterId",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: ${e.toString()}",
        source: "FilterApiClient",
        name: "getLemmasByFilterId",
        args: [],
      ));
    }
  }
}
