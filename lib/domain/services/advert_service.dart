import 'dart:async';

import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/constants/advertising_constants.dart';
import 'package:rewild_bot_front/core/constants/api_key_constants.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/advert_base.dart';
import 'package:rewild_bot_front/domain/entities/api_key_model.dart';
import 'package:rewild_bot_front/domain/entities/stream_advert_event.dart';
import 'package:rewild_bot_front/domain/entities/user_seller.dart';

import 'package:rewild_bot_front/presentation/adverts/all_adverts_stat_screen/all_adverts_stat_screen_view_model.dart';
import 'package:rewild_bot_front/presentation/adverts/all_adverts_words_screen/all_adverts_words_view_model.dart';
import 'package:rewild_bot_front/presentation/adverts/campaign_managment_screen/campaign_managment_view_model.dart';
import 'package:rewild_bot_front/presentation/adverts/single_auto_words_screen/single_auto_words_view_model.dart';
import 'package:rewild_bot_front/presentation/main_navigation_screen/main_navigation_view_model.dart';
import 'package:rewild_bot_front/presentation/home/report_screen/report_view_model.dart';
import 'package:rewild_bot_front/presentation/root_adverts_screen/root_adverts_screen_view_model.dart';

// API
abstract class AdvertServiceAdvertApiClient {
  Future<Either<RewildError, int>> depositCampaignBudget({
    required String token,
    required int campaignId,
    required int sum,
    bool returnResponse = false,
  });
  Future<Either<RewildError, Map<(int aType, int aStatus), List<int>>>>
      typeStatusIDs({required String token});
  Future<Either<RewildError, List<Advert>>> getAdverts(
      {required String token, required List<int> ids, int? status, int? type});

  Future<Either<RewildError, int>> getCompanyBudget(
      {required String token, required int campaignId});
  Future<Either<RewildError, int>> balance({required String token});

  Future<Either<RewildError, int>> getExpensesSum({
    required String token,
    required DateTime from,
    required DateTime to,
  });

  // Post
  Future<Either<RewildError, bool>> pauseAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> startAdvert(
      {required String token, required int campaignId});
  Future<Either<RewildError, bool>> changeCpm(
      {required String token,
      required int campaignId,
      required int type,
      required int cpm,
      required int param,
      int? instrument});
}

// Api key
abstract class AdvertServiceApiKeyDataProvider {
  Future<Either<RewildError, ApiKeyModel?>> getWBApiKey(
      {required String type, required String sellerId});
}

// active seller
abstract class AdvertServiceActiveSellerDataProvider {
  Future<Either<RewildError, List<UserSeller>>> getActive();
}

class AdvertService
    implements
        MainNavigationAdvertService,
        SingleAutoWordsAdvertService,
        RootAdvertsAdvertService,
        AllAdvertsStatScreenAdvertService,
        ReportAdvertService,
        AllAdvertsWordsAdvertService,
        CampaignManagementAdvertService {
  final AdvertServiceAdvertApiClient advertApiClient;
  final AdvertServiceApiKeyDataProvider apiKeysDataProvider;
  final StreamController<StreamAdvertEvent> updatedAdvertStreamController;
  final AdvertServiceActiveSellerDataProvider activeSellersDataProvider;

  AdvertService(
      {required this.advertApiClient,
      required this.apiKeysDataProvider,
      required this.activeSellersDataProvider,
      required this.updatedAdvertStreamController});

  static final keyType = ApiKeyConstants.apiKeyTypes[ApiKeyType.promo] ?? "";

  // Function to get token string
  @override
  Future<Either<RewildError, String?>> getApiKey() async {
    // Get active seller
    final activeSellerOrElse = await activeSellersDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);

    // Get Api key
    final tokenResult = await apiKeysDataProvider.getWBApiKey(
        type: keyType, sellerId: activeSeller.first.sellerId);

    return tokenResult.fold((l) => left(l), (r) async {
      if (r == null) {
        return right(null);
      }
      return right(r.token);
    });
  }

  @override
  Future<Either<RewildError, int>> getExpensesSum({
    required DateTime from,
    required DateTime to,
  }) async {
    // Get active seller
    final activeSellerOrElse = await activeSellersDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);
    final tokenResult = await apiKeysDataProvider.getWBApiKey(
        type: keyType, sellerId: activeSeller.first.sellerId);
    if (tokenResult.isLeft()) {
      return left(
          tokenResult.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final token = tokenResult.fold((l) => throw UnimplementedError(), (r) => r);
    if (token == null) {
      return left(RewildError(
        'Токен отсутствует',
        sendToTg: true,
        source: "AdvertService",
        name: "depositCampaignBudget",
        args: [from, to],
      ));
    }
    return await advertApiClient.getExpensesSum(
      token: token.token,
      from: from,
      to: to,
    );
  }

  // budget
  @override
  Future<Either<RewildError, int>> depositCampaignBudget({
    required int campaignId,
    required int sum,
  }) async {
    // Get active seller
    final activeSellerOrElse = await activeSellersDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);
    final tokenResult = await apiKeysDataProvider.getWBApiKey(
        type: keyType, sellerId: activeSeller.first.sellerId);
    if (tokenResult.isLeft()) {
      return left(
          tokenResult.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final token = tokenResult.fold((l) => throw UnimplementedError(), (r) => r);
    if (token == null) {
      return left(RewildError(
        'Токен отсутствует',
        sendToTg: true,
        source: "AdvertService",
        name: "depositCampaignBudget",
        args: [campaignId, sum],
      ));
    }
    return await advertApiClient.depositCampaignBudget(
      token: token.token,
      campaignId: campaignId,
      sum: sum,
    );
  }

  // Function to get ballance with token
  @override
  Future<Either<RewildError, int?>> getBallance({required String token}) async {
    final balanceResult = await advertApiClient.balance(token: token);

    return balanceResult.fold((l) => left(l), (r) {
      return right(r);
    });
  }

  // Function to get budget of a campaign by id
  @override
  Future<Either<RewildError, int>> getBudget(
      {required String token, required int campaignId}) async {
    final result = await advertApiClient.getCompanyBudget(
        token: token, campaignId: campaignId);
    return result;
  }

  // Function to get ids of all adverts filtered by types or not
  Future<Either<RewildError, List<int>>> _getAllCompaniesIdsFiltered(
      {required String token, List<int>? types, List<int>? statuses}) async {
    // get ids of all adverts grouped by type and status
    final typeStatusIdsEither =
        await advertApiClient.typeStatusIDs(token: token);
    if (typeStatusIdsEither is Left) {
      return left(typeStatusIdsEither.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }

    // since wb count endpoints do not provide any filtering
    // and wb /adv/v1/promotion/adverts privides filtering by type and status
    // but only one type and one status at a time that leads to making a lot of requests
    // the filtering implemented in this code

    final typeStatusIds =
        typeStatusIdsEither.fold((l) => throw UnimplementedError(), (r) => r);

    // if there are no some types and statuses specified
    if (types == null && statuses == null) {
      return right(
          typeStatusIds.entries.expand((element) => element.value).toList());
    }

    // if some types are specified
    if (types != null && statuses == null) {
      final res = typeStatusIds.entries
          .where((element) => types.contains(element.key.$1))
          .expand((element) => element.value)
          .toList();

      return right(res);
    }

    // if some statuses are specified
    if (types == null && statuses != null) {
      return right(typeStatusIds.entries
          .where((element) => statuses.contains(element.key.$2))
          .expand((element) => element.value)
          .toList());
    }

    // types != null && statuses != null
    return right(typeStatusIds.entries
        .where((element) =>
            types!.contains(element.key.$1) &&
            statuses!.contains(element.key.$2))
        .expand((element) => element.value)
        .toList());
  }

  @override
  Future<Either<RewildError, Advert>> getAdvert(
      {required String token, required int campaignId}) async {
    final advInfoResult =
        await advertApiClient.getAdverts(token: token, ids: [campaignId]);
    return advInfoResult.fold((l) => left(l), (r) {
      return right(r.first);
    });
  }

  @override
  Future<Either<RewildError, bool>> setCpm(
      {required int campaignId,
      required int type,
      required int cpm,
      required int param,
      int? instrument}) async {
    // Get active seller
    final activeSellerOrElse = await activeSellersDataProvider.getActive();
    if (activeSellerOrElse.isLeft()) {
      return left(
          activeSellerOrElse.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final activeSeller =
        activeSellerOrElse.fold((l) => throw UnimplementedError(), (r) => r);
    final tokenResult = await apiKeysDataProvider.getWBApiKey(
        type: keyType, sellerId: activeSeller.first.sellerId);
    if (tokenResult.isLeft()) {
      return left(
          tokenResult.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final token = tokenResult.fold((l) => throw UnimplementedError(), (r) => r);
    if (token == null) {
      return left(RewildError(
        'Токен отсутствует',
        sendToTg: true,
        source: "AdvertService",
        name: "setCpm",
        args: [campaignId, type, cpm, param, instrument],
      ));
    }

    final changeCpmResult = await advertApiClient.changeCpm(
        token: token.token,
        campaignId: campaignId,
        type: type,
        cpm: cpm,
        param: param,
        instrument: instrument);

    return changeCpmResult.fold((l) => left(l), (r) {
      updatedAdvertStreamController.add(
          StreamAdvertEvent(campaignId: campaignId, cpm: cpm, status: null));
      return right(r);
    });
  }

  @override
  Future<Either<RewildError, List<Advert>>> getAllAdverts(
      {required String token}) async {
    // get ids of all adverts filtered by statuses (paused and active)
    final allAdvertsIdsResult = await _getAllCompaniesIdsFiltered(
        token: token, statuses: AdvertStatusConstants.useable);

    // get Advert for all the filtered by statuses (paused and active) ids
    return allAdvertsIdsResult.fold((l) => left(l), (r) async {
      return await advertApiClient.getAdverts(token: token, ids: r);
    });
  }

  @override
  Future<Either<RewildError, List<Advert>>> getAll(
      {required String token, List<int>? types}) async {
    // get ids of all adverts filtered by types if types is not null
    final allAdvertsIdsResult =
        await _getAllCompaniesIdsFiltered(token: token, types: types);
    if (allAdvertsIdsResult is Left) {
      return left(allAdvertsIdsResult.fold(
          (l) => l, (r) => throw UnimplementedError()));
    }
    // get campaigns ids for all the filtered by types ids
    final allAdvertsIds =
        allAdvertsIdsResult.fold((l) => throw UnimplementedError(), (r) => r);

    return await advertApiClient.getAdverts(token: token, ids: allAdvertsIds);
    // return allAdvertsIdsResult.fold((l) => left(l), (r) async {
    //   return await advertApiClient.getAdverts(token: token, ids: r);
    // });
  }

  @override
  Future<Either<RewildError, bool>> checkAdvertIsActive(
      {required String token, required int campaignId}) async {
    final getAdvertsResult =
        await advertApiClient.getAdverts(token: token, ids: [campaignId]);

    return getAdvertsResult.fold((l) => left(l), (r) {
      final status = r.first.status;

      updatedAdvertStreamController.add(
          StreamAdvertEvent(campaignId: campaignId, cpm: null, status: status));
      return right(status == AdvertStatusConstants.active);
    });
  }

  @override
  Future<Either<RewildError, bool>> startAdvert(
      {required String token, required int campaignId}) async {
    final result = await _tryChangeAdvertStatus(
      token: token,
      campaignId: campaignId,
      func: advertApiClient.startAdvert,
    );

    return result;
  }

  @override
  Future<Either<RewildError, bool>> stopAdvert(
      {required String token, required int campaignId}) async {
    final result = await _tryChangeAdvertStatus(
      token: token,
      campaignId: campaignId,
      func: advertApiClient.pauseAdvert,
    );

    return result;
  }

  Future<Either<RewildError, bool>> _tryChangeAdvertStatus(
      {required String token,
      required int campaignId,
      required Future<Either<RewildError, bool>> Function(
              {required String token, required int campaignId})
          func}) async {
    bool done = false;
    int cont = 0;
    while (!done) {
      if (cont >= 20) {
        break;
      }
      // try to change the status of the advert
      final result = await func(token: token, campaignId: campaignId);
      result.fold((l) => left(l), (r) {
        // if the status changed
        done = r;
        cont++;
      });
    }
    return right(done);
  }
}
