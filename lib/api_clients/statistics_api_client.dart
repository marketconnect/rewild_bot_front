import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/utils/api_helpers/statistics_api_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/income.dart';
import 'package:rewild_bot_front/domain/entities/realization_report.dart';
import 'package:rewild_bot_front/domain/services/realization_report_service.dart';

class StatisticsApiClient
    implements RealizationReportServiceStatisticsApiClient {
  const StatisticsApiClient();
  @override
  Future<Either<RewildError, List<RealizationReport>>>
      fetchReportDetailByPeriod({
    required String token,
    required String dateFrom,
    required String dateTo,
    int limit = 100000,
    int rrdid = 0,
  }) async {
    final apiHelper = StatisticsApiHelper.reportDetailByPeriod;

    final Map<String, String> params = {
      'dateFrom': '${dateFrom}T00:00:00Z',
      'dateTo': '${dateTo}T23:59:59Z',
      'limit': limit.toString(),
      'rrdid': rrdid.toString(),
    };

    try {
      final response = await apiHelper.get(token, params);
      if (response.statusCode == 200) {
        if (response.body == "null") {
          return const Right([]);
        }
        List<dynamic> jsonData = json.decode(response.body);

        List<RealizationReport> reports = jsonData
            .map((jsonItem) => RealizationReport.fromJson(jsonItem))
            .toList();
        return Right(reports);
      } else {
        String errorDescription =
            apiHelper.errResponse(statusCode: response.statusCode);
        return Left(RewildError(errorDescription,
            source: "SupplierApiClient",
            name: "fetchReportDetailByPeriod",
            sendToTg: false));
      }
    } catch (e) {
      return Left(RewildError("Exception during fetch: $e",
          source: "SupplierApiClient",
          name: "fetchReportDetailByPeriod",
          sendToTg: false));
    }
  }

  @override
  Future<Either<RewildError, List<Income>>> fetchIncomes(
      {required String token, required DateTime dateFrom}) async {
    final String formattedDateFrom =
        '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(dateFrom)}Z';

    final apiHelper = StatisticsApiHelper.incomes;

    try {
      final response = await apiHelper.get(
        token,
        {'dateFrom': formattedDateFrom},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Income> incomes =
            jsonData.map((jsonItem) => Income.fromJson(jsonItem)).toList();
        return Right(incomes);
      } else {
        final errString =
            apiHelper.errResponse(statusCode: response.statusCode);
        return Left(RewildError(errString,
            source: "SupplierApiClient",
            name: "fetchIncomes",
            sendToTg: false));
      }
    } catch (e) {
      return Left(RewildError("Exception during fetch: $e",
          source: "SupplierApiClient", name: "fetchIncomes", sendToTg: false));
    }
  }
}
