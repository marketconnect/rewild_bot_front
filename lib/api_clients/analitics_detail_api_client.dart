import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/api_helpers/analitics_detail_api_helper.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/fetch_analitics_detail_result.dart';

class AnaliticsApiClient {
  const AnaliticsApiClient();
  Future<Either<RewildError, FetchDetailResult>> fetchDetail({
    required String token,
    required DateTime begin,
    required DateTime end,
    List<int>? nmIDs,
    int? page,
  }) async {
    final String beginFormatted = formatDateForAnaliticsDetail(begin);
    final String endFormatted = formatDateForAnaliticsDetail(end);
    const String url =
        'https://seller-analytics-api.wildberries.ru/api/v2/nm-report/detail';
    final Uri uri = Uri.parse(url);

    final Map<String, Object?> body = {
      // "nmIDs": nmIDs,
      "orderBy": {"field": "orders", "mode": "desc"},

      "period": {
        "begin": beginFormatted,
        "end": endFormatted,
      },
    };

    if (nmIDs != null && nmIDs.isNotEmpty) {
      body['nmIDs'] = nmIDs;
    }

    body['page'] = page ?? 1;

    final jsonBody = json.encode(body);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token,
    };

    try {
      final response = await http.post(uri, headers: headers, body: jsonBody);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        List<AnaliticsDetail> details = (responseBody['data']['cards'] as List)
            .map((e) => AnaliticsDetail.fromJson(e))
            .toList();
        bool isNextPage = responseBody['data']['isNextPage'] ?? false;
        final page = responseBody['data']['page'] ?? 1;
        return Right(FetchDetailResult(
            details: details, isNextPage: isNextPage, page: page));
      } else {
        String errorDescription = AnalyticsApiHelper
                .detail.statusCodeDescriptions[response.statusCode] ??
            "Unknown error";
        return Left(RewildError(
          errorDescription,
          sendToTg: false,
          error: errorDescription,
          source: "AnaliticsDetailApiClient",
          name: "fetchDetail",
        ));
      }
    } catch (e) {
      return Left(RewildError(
        "Exception during fetch: $e",
        sendToTg: false,
        error: e.toString(),
        source: "AnaliticsDetailApiClient",
        name: "fetchDetail",
      ));
    }
  }

  Future<Either<RewildError, bool>> fetchExciseReport({
    required String token,
  }) async {
    final apiHelper = AnalyticsApiHelper.exciseReport;
    const String baseUrl = 'https://seller-analytics-api.wildberries.ru';
    const String path = '/api/v1/analytics/excise-report';

    // Generate dateFrom and dateTo
    final now = DateTime.now();
    final dateFrom = DateTime(now.year, now.month, 1)
        .toString()
        .split(' ')[0]; // Format: YYYY-MM-DD
    final dateTo = DateTime(now.year, now.month, now.day)
        .toString()
        .split(' ')[0]; // Format: YYYY-MM-DD

    // Construct the query parameters
    // Construct the full URL including query parameters
    final Uri uri =
        Uri.parse("$baseUrl$path?dateFrom=$dateFrom&dateTo=$dateTo");

    // Define request headers including the Authorization token
    final Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": token,
      "Content-Type": "application/json",
    };

    // Define the request body as a JSON-encoded string
    final String body = jsonEncode({
      "countries": ["AM", "RU"]
    });

    try {
      // Make the POST request
      final http.Response response =
          await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Assuming the response is successful and returns the expected data
        return const Right(true);
      } else {
        String errorDescription =
            apiHelper.statusCodeDescriptions[response.statusCode] ??
                "Unknown error";
        return Left(RewildError(
          sendToTg: false,
          errorDescription,
          source: "AnaliticApiClient",
          name: "fetchExciseReport",
          error: errorDescription,
        ));
      }
    } catch (e) {
      return Left(RewildError(
        sendToTg: false,
        "Exception during fetch: $e",
        source: "AnaliticApiClient",
        name: "fetchExciseReport",
        error: e.toString(),
      ));
    }
  }
}
