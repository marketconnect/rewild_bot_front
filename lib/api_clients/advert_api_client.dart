import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:rewild_bot_front/core/constants/advertising_constants.dart';
import 'package:rewild_bot_front/core/utils/api_helpers/wb_advert_seller_api_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/advert_auto_model.dart';
import 'package:rewild_bot_front/domain/entities/advert_base.dart';
import 'package:rewild_bot_front/domain/entities/advert_search_plus_catalogue_model.dart';
import 'package:rewild_bot_front/domain/entities/auto_campaign_stat.dart';
import 'package:rewild_bot_front/domain/entities/campaign_data.dart';
import 'package:rewild_bot_front/domain/services/advert_service.dart';

class AdvertApiClient implements AdvertServiceAdvertApiClient {
  const AdvertApiClient();

  @override
  Future<Either<RewildError, bool>> setSearchExcludedKeywords(
      {required String token,
      required int campaignId,
      required List<String> excludedKeywords}) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {'excluded': excludedKeywords};

      final wbApi = WbAdvertApiHelper.searchSetExcludedKeywords;
      final response = await wbApi.post(token, body, params);

      if (response.statusCode == 200) {
        return right(true);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
            sendToTg: true,
            errString,
            source: runtimeType.toString(),
            name: "setSearchExcludedKeywords",
            args: [campaignId, ...excludedKeywords]));
      }
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          "Ошибка при установке исключений для кампании в поиске: $e",
          source: runtimeType.toString(),
          name: "setSearchExcludedKeywords",
          args: [campaignId, ...excludedKeywords]));
    }
  }

  @override
  Future<Either<RewildError, bool>> setAutoSetExcluded(
      {required String token,
      required int campaignId,
      required List<String> excludedKw}) async {
    try {
      final params = {'id': campaignId.toString()};
      final body = {
        'excluded': excludedKw,
      };

      final wbApi = WbAdvertApiHelper.autoSetExcludedKeywords;

      final response = await wbApi.post(token, body, params);
      if (response.statusCode == 200) {
        return right(true);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          sendToTg: true,
          errString,
          source: runtimeType.toString(),
          name: "setAutoSetExcluded",
          args: [campaignId, ...excludedKw],
        ));
      }
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          "Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "setAutoSetExcluded",
          args: [campaignId.toString(), ...excludedKw]));
    }
  }

  @override
  Future<Either<RewildError, bool>> changeCpm(
      {required String token,
      required int campaignId,
      required int type,
      required int cpm,
      required int param,
      int? instrument}) async {
    try {
      final body = {
        'advertId': campaignId,
        'type': type,
        'cpm': cpm,
      };

      // param do not required for auto
      if (type != AdvertTypeConstants.auto) {
        body['param'] = param;
      }

      if (instrument != null) {
        body['instrument'] = instrument;
      }

      final wbApi = WbAdvertApiHelper.setCpm;
      final response = await wbApi.post(token, body);
      if (response.statusCode == 200) {
        return right(true);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
            sendToTg: false,
            errString,
            source: runtimeType.toString(),
            name: "changeCpm",
            args: [campaignId, type, cpm, param, instrument]));
      }
    } catch (e) {
      return left(RewildError(
          sendToTg: false,
          "Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "changeCpm",
          args: [campaignId, type, cpm, param, instrument]));
    }
  }

  @override
  Future<Either<RewildError, int>> getExpensesSum({
    required String token,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final wbApi = WbAdvertApiHelper.getExpensesHistory;
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      final String formattedFrom = dateFormat.format(from);
      final String formattedTo = dateFormat.format(to);
      // max interval is 31 days
      if (to.difference(from).inDays > 31) {
        return const Right(0);
      }
      //
      final Map<String, String> params = {
        'from': formattedFrom,
        'to': formattedTo,
      };

      final response = await wbApi.get(token, params);

      if (response.statusCode == 200) {
        final List<dynamic> expensesData = json.decode(response.body);

        final int totalSum = expensesData.fold<int>(
            0, (sum, item) => sum + (item['updSum'] as int));
        return Right(totalSum);
      } else {
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return Left(RewildError(
          sendToTg: true,
          errString,
          source: runtimeType.toString(),
          name: "getExpensesSum",
          args: [from, to],
        ));
      }
    } catch (e) {
      return Left(RewildError(
        sendToTg: true,
        "Исключение при запросе суммы затрат: $e",
        source: runtimeType.toString(),
        name: "getExpensesSum",
        args: [from, to],
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> pauseAdvert(
      {required String token, required int campaignId}) async {
    try {
      final params = {'id': campaignId.toString()};

      // final uri = Uri.https('advert-api.wb.ru', "/adv/v0/pause", params);

      final wbApi = WbAdvertApiHelper.pauseCampaign;
      final response = await wbApi.get(token, params);
      if (response.statusCode == 200) {
        return right(true);
      } else if (response.statusCode == 422) {
        //Статус кампании не изменен
        return right(false);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          sendToTg: false,
          errString,
          source: runtimeType.toString(),
          name: "pauseAdvert",
          args: [campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError(
          sendToTg: false,
          "Неизвестная ошибка",
          source: runtimeType.toString(),
          name: "pauseAdvert",
          args: [campaignId]));
    }
  }

  // max 300 requests per minute
  @override
  Future<Either<RewildError, bool>> startAdvert(
      {required String token, required int campaignId}) async {
    try {
      final params = {'id': campaignId.toString()};

      // final uri = Uri.https('advert-api.wb.ru', "/adv/v0/start", params);

      final wbApi = WbAdvertApiHelper.startCampaign;
      final response = await wbApi.get(token, params);
      if (response.statusCode == 200) {
        return right(true);
      } else if (response.statusCode == 422) {
        //Статус кампании не изменен
        return right(false);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );

        return left(RewildError(
          sendToTg: false,
          errString,
          source: runtimeType.toString(),
          name: "startAdvert",
          args: [campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError(
          sendToTg: false,
          "Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "startAdvert",
          args: [campaignId]));
    }
  }

  @override
  Future<Either<RewildError, int>> getCompanyBudget(
      {required String token, required int campaignId}) async {
    try {
      final params = {'id': campaignId.toString()};

      final wbApi = WbAdvertApiHelper.getCompanyBudget;

      final response = await wbApi.get(
        token,
        params,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) {
          return right(0);
        }

        return right(data['total']);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          sendToTg: false,
          errString,
          source: runtimeType.toString(),
          name: "getCompanyBudget",
          args: [campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError(
          sendToTg: false,
          "Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "getCompanyBudget",
          args: [campaignId]));
    }
  }

  @override
  Future<Either<RewildError, Map<(int aType, int aStatus), List<int>>>>
      typeStatusIDs({required String token}) async {
    try {
      final wbApi = WbAdvertApiHelper.getCampaigns;

      final response = await wbApi.get(
        token,
      );

      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));

        final adverts = stats['adverts'];
        if (adverts == null) {
          return right({});
        }
        Map<(int, int), List<int>> typeIds = {};
        for (final advert in adverts) {
          List<int> ids = [];
          final advertList = advert['advert_list'];
          if (advertList == null) {
            continue;
          }

          final type = advert['type'];
          final status = advert['status'];

          for (final a in advertList) {
            final id = a['advertId'];
            if (id == null) {
              continue;
            }
            ids.add(id);
          }
          if (typeIds.containsKey(type)) {
            typeIds[type]!.addAll(ids);
          } else {
            typeIds[(type, status)] = ids;
          }
        }

        return right(typeIds);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          sendToTg: false,
          errString,
          source: runtimeType.toString(),
          name: "count",
          args: [
            token,
          ],
        ));
      }
    } catch (e) {
      return left(RewildError(
          sendToTg: false,
          "Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "count",
          args: [
            token,
          ]));
    }
  }

  @override
  Future<Either<RewildError, int>> balance({required String token}) async {
    try {
      final wbApi = WbAdvertApiHelper.getBalance;
      final response = await wbApi.get(
        token,
      );
      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        final balance = stats['balance'];
        return right(balance);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          sendToTg: false,
          errString,
          source: runtimeType.toString(),
          name: "balance",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: false,
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "balance",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, AutoCampaignStatWord>> autoStatWords(
      {required String token, required int campaignId}) async {
    try {
      final params = {'id': campaignId.toString()};
      // final uri =
      //     Uri.https('advert-api.wb.ru', "/adv/v1/auto/stat-words", params);
      final wbApi = WbAdvertApiHelper.autoGetStatsWords;

      final response = await wbApi.get(token, params);
      if (response.statusCode == 200) {
        // Parse the JSON string into a Map
        Map<String, dynamic> jsonData =
            json.decode(utf8.decode(response.bodyBytes));
        final data = jsonData['words'];
        // Use the fromMap method
        AutoCampaignStatWord autoStatWord =
            AutoCampaignStatWord.fromMap(data, campaignId);

        return right(autoStatWord);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
            sendToTg: true,
            errString,
            source: runtimeType.toString(),
            name: "autoStatWords",
            args: [campaignId]));
      }
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          "Неизвестная ошибка: $e",
          source: runtimeType.toString(),
          name: "autoStatWords",
          args: [campaignId]));
    }
  }

  // @override
  // Future<Either<RewildError, SearchCampaignStat>> getSearchStat(
  //     {required String token, required int campaignId}) async {
  //   try {
  //     final params = {'id': campaignId.toString()};
  //     // final uri = Uri.https('advert-api.wb.ru', "/adv/v1/stat/words", params);
  //     final wbApi = WbAdvertApiHelper.searchGetStatsWords;
  //     final response = await wbApi.get(
  //       token,
  //       params,
  //     );
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> jsonData =
  //           json.decode(utf8.decode(response.bodyBytes));

  //       return right(SearchCampaignStat.fromJson(jsonData, campaignId));
  //     } else {
  //       final errString = wbApi.errResponse(
  //         statusCode: response.statusCode,
  //       );
  //       return left(RewildError(
  //         sendToTg: false,
  //         errString,
  //         source: runtimeType.toString(),
  //         name: "getSearchStat",
  //         args: [campaignId],
  //       ));
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: false,
  //       "Неизвестная ошибка $e",
  //       source: runtimeType.toString(),
  //       name: "getSearchStat",
  //       args: [campaignId],
  //     ));
  //   }
  // }

  @override
  Future<Either<RewildError, List<Advert>>> getAdverts(
      {required String token,
      required List<int> ids,
      int? status,
      int? type}) async {
    try {
      final body = ids;
      Map<String, String> params = {};
      if (status != null) {
        params['status'] = status.toString();
      }
      if (type != null) {
        params['type'] = type.toString();
      }
      final wbApi = WbAdvertApiHelper.getCampaignsInfo;

      final response = await wbApi.post(
        token,
        body,
        params,
      );

      if (response.statusCode == 200) {
        final stats = json.decode(utf8.decode(response.bodyBytes));
        List<Advert> res = [];
        for (final stat in stats) {
          final advStatus = stat['status'];

          if (advStatus != AdvertStatusConstants.active &&
              advStatus != AdvertStatusConstants.paused) {
            continue;
          }
          final advType = stat['type'];

          switch (advType) {
            case AdvertTypeConstants.auto:
              // auto
              res.add(AdvertAutoModel.fromJson(stat));
            case AdvertTypeConstants.searchPlusCatalog:
              // search+catalogue
              res.add(AdvertSearchPlusCatalogueModel.fromJson(stat));

            default:
              return left(RewildError(
                sendToTg: false,
                "Неизвестный тип кампании: $advType",
                source: runtimeType.toString(),
                name: "getAdverts",
                args: [ids],
              ));
          }
        }

        return right(res);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          sendToTg: false,
          errString,
          source: runtimeType.toString(),
          name: "getAdverts",
          args: [ids],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: false,
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "getAdverts",
        args: [ids],
      ));
    }
  }

  @override
  Future<Either<RewildError, int>> depositCampaignBudget({
    required String token,
    required int campaignId,
    required int sum,
    // required int type = 1,
    bool returnResponse = true,
  }) async {
    final apiHelper = WbAdvertApiHelper.depositBudget;

    final params = {
      'id': campaignId.toString(),
    };

    final body = {
      'sum': sum,
      'type': 0,
      'return': returnResponse,
    };

    try {
      final response = await apiHelper.post(token, body, params);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return Right(responseBody['total']);
      } else {
        String errorDescription =
            apiHelper.errResponse(statusCode: response.statusCode);
        return Left(RewildError(errorDescription,
            source: "AdvertApiClient",
            name: "depositCampaignBudget",
            sendToTg: false));
      }
    } catch (e) {
      return Left(RewildError("Exception during budget deposit: $e",
          source: "AdvertApiClient",
          name: "depositCampaignBudget",
          sendToTg: true));
    }
  }

  // wb api returns only one intreval per campaignId
  @override
  Future<Either<RewildError, CampaignData?>> getSingleCampaignDataByInterval({
    required int campaignId,
    required (String, String) interval,
    required String token,
  }) async {
    try {
      final params = [
        {
          "id": campaignId,
          "interval": {"begin": interval.$1, "end": interval.$2}
        }
      ];

      final response = await WbAdvertApiHelper.getFullStat.post(token, params);
      if (response.body == "") {
        return const Right(null);
      }

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);
        final List<CampaignData> campaigns = dataList
            .map((dynamic item) => CampaignData.fromJson(item))
            .toList();

        return Right(campaigns.first);
      } else {
        if (response.statusCode == 400) {
          return const Right(null);
        }
        // Обработка ошибок API
        return Left(RewildError(
          sendToTg: false,
          "Ошибка API: Статус ${response.statusCode}",
          source: runtimeType.toString(),
          name: "getSingleCampaignDataByInterval",
          args: [campaignId, interval],
        ));
      }
    } catch (e) {
      // Обработка исключений запроса
      return Left(RewildError(
        sendToTg: false,
        "Исключение при запросе данных кампании: $e",
        source: runtimeType.toString(),
        name: "getSingleCampaignDataByInterval",
        args: [campaignId, interval],
      ));
    }
  }

  static Future<Either<RewildError, int>> getCompanyBudgetInBackground(
      {required String token, required int campaignId}) async {
    try {
      final params = {'id': campaignId.toString()};
      final wbApi = WbAdvertApiHelper.getCompanyBudget;
      final response = await wbApi.get(
        token,
        params,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) {
          return right(0);
        }

        return right(data['total']);
      } else {
        final errString = wbApi.errResponse(
          statusCode: response.statusCode,
        );
        return left(RewildError(
          sendToTg: false,
          errString,
          source: "AdvertApiClient",
          name: "getCompanyBudgetInBackground",
          args: [campaignId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: false,
        "Неизвестная ошибка $e",
        source: "AdvertApiClient",
        name: "getCompanyBudgetInBackground",
        args: [campaignId],
      ));
    }
  }

// @override
  // Future<Either<RewildError, AdvertStatModel>> getAutoStat(
  //     {required String token, required int campaignId}) async {
  //   try {
  //     final params = {'id': campaignId.toString()};

  //     final wbApi = WbAdvertApiHelper.autoGetStat;
  //     final response = await wbApi.get(
  //       token,
  //       params,
  //     );

  //     if (response.statusCode == 200) {
  //       final stats = json.decode(utf8.decode(response.bodyBytes));
  //       return right(AdvertStatModel.fromJson(stats, campaignId));
  //     } else {
  //       final errString = wbApi.errResponse(
  //         statusCode: response.statusCode,
  //       );
  //       return left(RewildError(
  //         sendToTg: false,
  //         errString,
  //         source: runtimeType.toString(),
  //         name: "getAutoStat",
  //         args: [, campaignId],
  //       ));
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: false,
  //       "Неизвестная ошибка $e",
  //       source: runtimeType.toString(),
  //       name: "getAutoStat",
  //       args: [, campaignId],
  //     ));
  //   }
  // }

  // @override
  // Future<Either<RewildError, AdvertStatModel>> getSearchAndCatalogueStat(
  //     {required String token, required int campaignId}) async {
  //   try {
  //     final params = {'id': campaignId.toString()};

  //     final wbApi = WbAdvertApiHelper.searchCatalogueGetStat;
  //     final response = await wbApi.get(
  //       token,
  //       params,
  //     );

  //     if (response.statusCode == 200) {
  //       final stats = json.decode(utf8.decode(response.bodyBytes));
  //       return right(
  //           AdvertStatModel.fromJsonSearchAndcatalogue(stats, campaignId));
  //     } else {
  //       final errString = wbApi.errResponse(
  //         statusCode: response.statusCode,
  //       );
  //       return left(RewildError(
  //         sendToTg: false,
  //         errString,
  //         source: runtimeType.toString(),
  //         name: "getSearchAndCatalogueStat",
  //         args: [, campaignId],
  //       ));
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: false,
  //       "Неизвестная ошибка $e",
  //       source: runtimeType.toString(),
  //       name: "getSearchAndCatalogueStat",
  //       args: [, campaignId],
  //     ));
  //   }
  // }

  // @override
  // Future<Either<RewildError, List<FullAdvertStat>>> getFullStatForOne(
  //     {required String token,
  //     required int campaignId,
  //     required List<(String, String)> intervals}) async {
  //   try {
  //     // Create an array of campaign objects with intervals
  //     final params = intervals
  //         .map((interval) => {
  //               "id": campaignId,
  //               "interval": {"begin": interval.$1, "end": interval.$1}
  //             })
  //         .toList();

  //     final response = await WbAdvertApiHelper.getFullStat.post(token, params);
  //     if (response.statusCode == 200) {
  //       final statsList = json.decode(utf8.decode(response.bodyBytes)) as List;
  //       final models =
  //           statsList.map((e) => FullAdvertStat.fromJson(e)).toList();
  //       return right(models);
  //     } else {
  //       final errString = WbAdvertApiHelper.getFullStat.errResponse(
  //         statusCode: response.statusCode,
  //       );
  //       return left(RewildError(
  //         sendToTg: false,
  //         errString,
  //         source: "AdvertApiClient",
  //         name: "getFullStatInBackground",
  //         args: [, campaignId, intervals],
  //       ));
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: false,
  //       "Неизвестная ошибка $e",
  //       source: "AdvertApiClient",
  //       name: "getFullStatInBackground",
  //       args: [, campaignId, intervals],
  //     ));
  //   }
  // }
//  static Future<Either<RewildError, List<AdvertStatModel>>>
//       getFullStatInBackground(
//           {required String token, required List<int> campaignIds}) async {
//     try {
//       // Format the current date as 'yyyy-MM-dd'
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//       // Create an array of campaign objects with intervals
//       final campaigns = campaignIds
//           .map((id) => {
//                 "id": id,
//                 "interval": {"begin": "2019-01-01", "end": today}
//               })
//           .toList();

//       final response =
//           await WbAdvertApiHelper.getFullStat.post(token, campaigns);
//       if (response.statusCode == 200) {
//         final statsList = json.decode(utf8.decode(response.bodyBytes)) as List;
//         final models = statsList
//             .map((e) => AdvertStatModel.fromJson(e, e['advertId']))
//             .toList();
//         return right(models);
//       } else {
//         final errString = WbAdvertApiHelper.getFullStat.errResponse(
//           statusCode: response.statusCode,
//         );
//         return left(RewildError(
//           sendToTg: false,
//           errString,
//           source: "AdvertApiClient",
//           name: "getFullStatInBackground",
//           args: [, campaignIds],
//         ));
//       }
//     } catch (e) {
//       return left(RewildError(
//         sendToTg: false,
//         "Неизвестная ошибка $e",
//         source: "AdvertApiClient",
//         name: "getFullStatInBackground",
//         args: [, campaignIds],
//       ));
//     }
//   }

//  static Future<Either<RewildError, AdvertStatModel>> getSearchStatInBackground(
//       {required String token, required int campaignId}) async {
//     try {
//       final params = {'id': campaignId.toString()};
//       // final uri = Uri.https('advert-api.wb.ru', "/adv/v1/stat/words", params);

//       final wbApi = WbAdvertApiHelper.searchGetStatsWords;
//       final response = await wbApi.get(
//         token,
//         params,
//       );
//       if (response.statusCode == 200) {
//         final stats = json.decode(utf8.decode(response.bodyBytes));
//         final total = stats['stat'][0];
//         return right(AdvertStatModel.fromJson(total, campaignId));
//       } else {
//         final errString = wbApi.errResponse(
//           statusCode: response.statusCode,
//         );
//         return left(RewildError(
//           sendToTg: false,
//           errString,
//           source: "AdvertApiClient",
//           name: "getSearchStatInBackground",
//           args: [, campaignId],
//         ));
//       }
//     } catch (e) {
//       return left(RewildError(
//         sendToTg: false,
//         "Неизвестная ошибка $e",
//         source: "AdvertApiClient",
//         name: "getSearchStatInBackground",
//         args: [, campaignId],
//       ));
//     }
//   }
  // static Future<Either<RewildError, Map<int, List<int>>>> countInBackground(
  //     {required String token}) async {
  //   try {
  //     final wbApi = WbAdvertApiHelper.getCampaigns;

  //     final response = await wbApi.get(
  //       token,
  //     );

  //     if (response.statusCode == 200) {
  //       final stats = json.decode(utf8.decode(response.bodyBytes));

  //       final adverts = stats['adverts'];
  //       if (adverts == null) {
  //         return right({});
  //       }

  //       final typeIds = _filterAdvretsIds(adverts);

  //       return right(typeIds);
  //     } else {
  //       final errString = wbApi.errResponse(
  //         statusCode: response.statusCode,
  //       );
  //       return left(RewildError(
  //         sendToTg: false,
  //         errString,
  //         source: 'countInBackground',
  //         name: "count",
  //         args: [
  //           token,
  //         ],
  //       ));
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //         sendToTg: false,
  //         "Неизвестная ошибка: $e",
  //         source: 'countInBackground',
  //         name: "count",
  //         args: [
  //           token,
  //         ]));
  //   }
  // }

  // static Map<int, List<int>> _filterAdvretsIds(dynamic adverts) {
  //   Map<int, List<int>> typeIds = {};
  //   for (final advert in adverts) {
  //     List<int> ids = [];
  //     final advertList = advert['advert_list'];
  //     final st = advert['status'];

  //     // Add filter by status skip not useable
  //     if (!AdvertStatusConstants.useable.contains(st)) {
  //       continue;
  //     }
  //     final type = advert['type'];
  //     if (advertList == null) {
  //       continue;
  //     }
  //     for (final a in advertList) {
  //       final id = a['advertId'];
  //       if (id == null) {
  //         continue;
  //       }
  //       ids.add(id);
  //     }
  //     if (typeIds.containsKey(type)) {
  //       typeIds[type]!.addAll(ids);
  //     } else {
  //       typeIds[type] = ids;
  //     }
  //   }
  //   return typeIds;
  // }

  // static Future<Either<RewildError, List<AdvertInfoModel>>>
  //     getAdvertsInBackground(
  //         {required String token, required List<int> ids}) async {
  //   try {
  //     final body = ids;

  //     final wbApi = WbAdvertApiHelper.getCampaignsInfo;
  //     final response = await wbApi.post(token, body);

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(utf8.decode(response.bodyBytes));
  //       if (data == null || data.length == 0) {
  //         return right([]);
  //       }

  //       return right(
  //         List<AdvertInfoModel>.from(
  //           data.map((x) => AdvertInfoModel.fromJson(x)),
  //         ),
  //       );
  //     } else if (response.statusCode == 204) {
  //       return right([]);
  //     } else {
  //       final errString = wbApi.errResponse(
  //         statusCode: response.statusCode,
  //       );

  //       return left(RewildError(
  //         sendToTg: false,
  //         errString,
  //         source: "AdvertApiClient",
  //         name: "getAdvertsInBackground",
  //         args: [],
  //       ));
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: false,
  //       "Ошибка при обращении к WB продвижение список кампаний: $e",
  //       source: "AdvertApiClient",
  //       name: "getAdvertsInBackground",
  //       args: [],
  //     ));
  //   }
  // }

  // static Future<Either<RewildError, AdvertStatModel>> getAutoStatInBackground(
  //     {required String token, required int campaignId}) async {
  //   try {
  //     final params = {'id': campaignId.toString()};

  //     final wbApi = WbAdvertApiHelper.autoGetStat;
  //     final response = await wbApi.get(
  //       token,
  //       params,
  //     );
  //     if (response.statusCode == 200) {
  //       final stats = json.decode(utf8.decode(response.bodyBytes));
  //       return right(AdvertStatModel.fromJson(stats, campaignId));
  //     } else {
  //       final errString = wbApi.errResponse(
  //         statusCode: response.statusCode,
  //       );
  //       return left(RewildError(
  //         sendToTg: false,
  //         errString,
  //         source: "AdvertApiClient",
  //         name: "getAutoStatInBackground",
  //         args: [, campaignId],
  //       ));
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: false,
  //       "Неизвестная ошибка $e",
  //       source: "AdvertApiClient",
  //       name: "getAutoStatInBackground",
  //       args: [, campaignId],
  //     ));
  //   }
  // }
}