import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
import 'package:rewild_bot_front/domain/entities/realization_report.dart';
import 'package:rewild_bot_front/domain/entities/user_seller.dart';
import 'package:rewild_bot_front/presentation/home/report_screen/report_view_model.dart';

// Api key
abstract class RealizationReportServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getWBApiKey(
      {required String type, required String sellerId});
}

// Reports
abstract class RealizationReportServiceStatisticsApiClient {
  Future<Either<RewildError, List<RealizationReport>>>
      fetchReportDetailByPeriod({
    required String token,
    required String dateFrom,
    required String dateTo,
    int limit = 100000,
    int rrdid = 0,
  });
}

// active seller
abstract class RealizationReportServiceActiveSellerDataProvider {
  Future<Either<RewildError, List<UserSeller>>> getActive();
}

class RealizationReportService implements ReportRealizationReportService {
  final RealizationReportServiceStatisticsApiClient statisticsApiClient;
  final RealizationReportServiceApiKeyDataProvider apiKeyDataProvider;
  final RealizationReportServiceActiveSellerDataProvider
      activeSellerDataProvider;

  const RealizationReportService(
      {required this.statisticsApiClient,
      required this.apiKeyDataProvider,
      required this.activeSellerDataProvider});
  static final keyType = ApiKeyConstants.apiKeyTypes[ApiKeyType.stat] ?? "";

  @override
  Future<Either<RewildError, bool>> apiKeyExists() async {
    // Get active seller
    final activeSellerOrElse = await activeSellerDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);

    // Get Api key
    final either = await apiKeyDataProvider.getWBApiKey(
        type: keyType, sellerId: activeSeller.first.sellerId);

    return either.fold((l) => left(l), (r) {
      if (r == null) {
        return right(false);
      }
      return right(true);
    });
  }

  @override
  Future<Either<RewildError, List<RealizationReport>>>
      fetchReportDetailByPeriod({
    required String dateFrom,
    required String dateTo,
    int limit = 100000,
    int rrdid = 0,
  }) async {
    // Get active seller
    final activeSellerOrElse = await activeSellerDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);

    // Get Api key
    final apiKeyEither = await apiKeyDataProvider.getWBApiKey(
        type: keyType, sellerId: activeSeller.first.sellerId);

    if (apiKeyEither.isLeft()) {
      return left(RewildError('Api key not found',
          name: 'fetchReportDetailByPeriod',
          sendToTg: true,
          source: "RealizationReportService",
          args: []));
    }

    final token =
        apiKeyEither.fold((l) => throw UnimplementedError(), (r) => r);
    if (token == null) {
      return left(RewildError('Api key not found',
          name: 'fetchReportDetailByPeriod',
          sendToTg: true,
          source: "RealizationReportService",
          args: []));
    }
    final result = await statisticsApiClient.fetchReportDetailByPeriod(
        token: token.token,
        dateFrom: dateFrom,
        dateTo: dateTo,
        limit: limit,
        rrdid: rrdid);
    return result;
  }
}
