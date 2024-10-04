import 'dart:convert';

import 'package:fpdart/fpdart.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:rewild_bot_front/core/utils/api_helpers/wb_content_api_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/card_catalog.dart';
import 'package:rewild_bot_front/domain/entities/subj_characteristic.dart';
import 'package:rewild_bot_front/domain/services/content_service.dart';

class WbContentApiClient implements ContentServiceWbContentApiClient {
  const WbContentApiClient();

  @override
  Future<Either<RewildError, CardCatalog>> fetchNomenclatures({
    required String token,
  }) async {
    const url =
        "https://suppliers-api.wildberries.ru/content/v2/get/cards/list";
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
    };

    final body = jsonEncode({
      "settings": {
        "cursor": {
          "limit": 100,
        },
        "filter": {
          "withPhoto": 1,
        },
      },
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final cardCatalog = CardCatalog.fromJson(data);
        return Right(cardCatalog);
      } else {
        return Left(RewildError(
          response.statusCode.toString(),
          source: "WbContentApiClient",
          name: "fetchNomenclatures",
          args: [],
          sendToTg: true,
        ));
      }
    } catch (e) {
      return Left(RewildError(
        e.toString(),
        source: "WbContentApiClient",
        name: "fetchNomenclatures",
        args: [],
        sendToTg: true,
      ));
    }
  }

  Future<Either<RewildError, bool>> fetchCardLimits(
      {required String token}) async {
    try {
      final apiHelper = WbContentApiHelper.getCardsLimits;
      final response = await apiHelper.get(token, {});

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        final errString =
            apiHelper.errResponse(statusCode: response.statusCode);
        return Left(RewildError(
          errString,
          source: "WbContentApiClient",
          name: "fetchCardLimits",
          args: [token],
          sendToTg: true,
        ));
      }
    } catch (e) {
      return Left(RewildError("Exception during fetch: $e",
          source: "WbContentApiClient",
          name: "fetchCardLimits",
          args: [token],
          sendToTg: true));
    }
  }

  @override
  Future<Either<RewildError, bool>> updateProductCard({
    required String token,
    required int nmID,
    required String vendorCode,
    required List<CardItemSize> sizes,
    required Dimension dimension,
    String? title,
    String? description,
    List<Characteristic>? characteristics,
  }) async {
    final Uri uri = Uri.parse(
        'https://suppliers-api.wildberries.ru/content/v2/cards/update');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token,
    };
    Map<String, Object> cardUpdates = {
      "nmID": nmID,
      'vendorCode': vendorCode,
      "dimensions": {
        "length": dimension.length,
        "width": dimension.width,
        "height": dimension.height,
      },
      'sizes': sizes.map((e) => e.toMap()).toList(),
    };

    if (title != null) {
      cardUpdates['title'] = title;
    }
    if (description != null) {
      cardUpdates['description'] = description;
    }
    if (characteristics != null) {
      cardUpdates['characteristics'] =
          characteristics.map((e) => e.toMap()).toList();
    }
    final body = jsonEncode([cardUpdates]);
    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final error = data['error'];
        if (error) {
          return Left(RewildError(data['errorText'].toString(),
              name: "updateProductCard",
              args: [token, cardUpdates],
              sendToTg: true));
        }

        return const Right(true);
      } else {
        // Extract error details if available, otherwise provide a general error
        final errorDetails = jsonDecode(response.body);
        final errorText = errorDetails['errorText'] ??
            'Unknown error during product card update.';
        return Left(RewildError(errorText,
            source: "WbContentApiClient",
            name: "updateProductCard",
            args: [token, cardUpdates],
            sendToTg: true));
      }
    } catch (e) {
      return Left(RewildError(e.toString(),
          source: "WbContentApiClient",
          name: "updateProductCard",
          args: [token, cardUpdates],
          sendToTg: true));
    }
  }

  @override
  Future<Either<RewildError, bool>> updateMediaFiles({
    required String token,
    required int nmId,
    required List<String> mediaUrls,
  }) async {
    final Uri uri =
        Uri.parse('https://suppliers-api.wildberries.ru/content/v3/media/save');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
    };
    try {
      final body = jsonEncode({
        "nmId": nmId,
        "data": mediaUrls,
      });
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Assuming successful update returns true
        return const Right(true);
      } else {
        // Handle API error responses
        // String errString = WbContentApiHelper.updateMediaFiles
        //     .errResponse(statusCode: response.statusCode);

        final errorDetails = jsonDecode(utf8.decode(response.bodyBytes));
        final errString = errorDetails['errorText'] ??
            WbContentApiHelper.updateMediaFiles
                .errResponse(statusCode: response.statusCode);

        return Left(RewildError(
          sendToTg: true,
          errString,
          source: "WbContentApiClient",
          name: "updateMediaFiles",
          args: [nmId, mediaUrls],
        ));
      }
    } catch (e) {
      // Handle exceptions during the request
      return Left(RewildError(
        sendToTg: true,
        "Exception during media files update: $e",
        source: "WbContentApiClient",
        name: "updateMediaFiles",
        args: [nmId, mediaUrls],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubjCharacteristic>>>
      fetchSubjectCharacteristics({
    required String token,
    required int subjectId,
    String? locale,
  }) async {
    final String url =
        'https://suppliers-api.wildberries.ru/content/v2/object/charcs/$subjectId';
    final Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json',
    };

    // Include locale in the query parameters if provided
    final Map<String, String> queryParams = {};
    if (locale != null) {
      queryParams['locale'] = locale;
    }
    final Uri uri = Uri.parse(url).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(utf8.decode(response.bodyBytes))['data'];
        final List<SubjCharacteristic> characteristics = data
            .map((dynamic item) =>
                SubjCharacteristic.fromJson(item as Map<String, dynamic>))
            .toList();
        return Right(characteristics);
      } else {
        return Left(RewildError(
            "Failed to fetch subject characteristics. Status code: ${response.statusCode}",
            source: "WbContentApiClient",
            name: "fetchSubjectCharacteristics",
            args: [subjectId, locale],
            sendToTg: true));
      }
    } catch (e) {
      return Left(RewildError(
          "Exception during fetching subject characteristics",
          source: "WbContentApiClient",
          name: "fetchSubjectCharacteristics",
          args: [subjectId, locale],
          sendToTg: true));
    }
  }
}
