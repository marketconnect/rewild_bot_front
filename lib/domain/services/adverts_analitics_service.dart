import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
import 'package:rewild_bot_front/domain/entities/campaign_data.dart';
import 'package:rewild_bot_front/domain/entities/user_seller.dart';
import 'package:rewild_bot_front/presentation/adverts/advert_analitics_screen/advert_analitics_view_model.dart';

abstract class AdvertsAnaliticsServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getWBApiKey(
      {required String type, required String sellerId});
}

// Api
abstract class AdvertAnaliticsServiceAnaliticsApiClient {
  Future<Either<RewildError, CampaignData?>> getSingleCampaignDataByInterval({
    required int campaignId,
    required (String, String) interval,
    required String token,
  });
}

// active seller
abstract class AdvertsAnaliticsActiveSellerDataProvider {
  Future<Either<RewildError, List<UserSeller>>> getActive();
}

class AdvertsAnaliticsService
    implements
        // AdvertsAnaliticsNavigationAnaliticsService,

        AdvertAnaliticsAdvertsAnaliticsService {
  final AdvertsAnaliticsServiceApiKeyDataProvider apiKeyDataProvider;
  final AdvertsAnaliticsActiveSellerDataProvider activeSellerDataProvider;
  final AdvertAnaliticsServiceAnaliticsApiClient apiClient;
  const AdvertsAnaliticsService(
      {required this.apiKeyDataProvider,
      required this.apiClient,
      required this.activeSellerDataProvider});

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
    final apiKey = await apiKeyDataProvider.getWBApiKey(
        type: ApiKeyConstants.apiKeyTypes[ApiKeyType.promo]!,
        sellerId: activeSeller.first.sellerId);

    final tokenEither = apiKey.fold((l) => null, (r) => r);
    if (tokenEither == null) {
      return right(false);
    }
    if (tokenEither.token.isEmpty) {
      return right(false);
    }
    return right(true);
  }

  @override
  Future<Either<RewildError, CampaignData?>> getCampaignDataByInterval(
      {required int campaignId, required (String, String) interval}) async {
    // Get active seller
    final activeSellerOrElse = await activeSellerDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);

    // Get Api key
    final apiKey = await apiKeyDataProvider.getWBApiKey(
        type: ApiKeyConstants.apiKeyTypes[ApiKeyType.promo]!,
        sellerId: activeSeller.first.sellerId);

    final tokenEither = apiKey.fold((l) => null, (r) => r);
    if (tokenEither == null) {
      return left(RewildError('',
          sendToTg: true,
          source: 'AdvertsAnaliticsService',
          name: 'getCampaignDataByInterval',
          args: [campaignId, interval]));
    }
    final token = tokenEither.token;
    return await apiClient.getSingleCampaignDataByInterval(
        campaignId: campaignId, interval: interval, token: token);
  }
}
