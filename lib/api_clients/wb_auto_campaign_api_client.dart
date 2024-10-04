import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/api_helpers/auto_campaign_api_helper.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/keyword.dart';
import 'package:rewild_bot_front/domain/services/keywords_service.dart';

class AutoCampaignApiClient implements KeywordsServiceAutoAdvertApiClient {
  const AutoCampaignApiClient();
  @override
  Future<Either<RewildError, List<Keyword>>> fetchAutoCampaignClusterStats(
      {required String token, required int campaignId}) async {
    try {
      final params = {
        "id": campaignId.toString()
      }; // Prepare request body as needed
      final apiHelper = AutoCampaignApiHelper.getStatWords;
      final response = await apiHelper.get(token, params);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        List<Keyword> result = [];
        final clusters = data['clusters'] ?? [];

        // Assuming 'clusters' is a key in the response body that contains an array of keyword clusters
        for (var cluster in clusters) {
          final clusterName = cluster['cluster'];
          final keywords = cluster['keywords'];
          if (clusterName == null || keywords == null) continue;

          for (final keyword in keywords) {
            final kw = Keyword(
                campaignId: campaignId,
                keyword: keyword,
                count: 0,
                normquery: clusterName);
            result.add(kw);
          }
        }

        return Right(result);
      } else {
        final errString =
            apiHelper.errResponse(statusCode: response.statusCode);
        return Left(RewildError(
          sendToTg: true,
          errString,
          source: "AutoCampaignApiClient",
          name: "fetchAutoCampaignStats",
          args: [campaignId],
        ));
      }
    } catch (e) {
      return Left(RewildError(
        sendToTg: true,
        "Unknown error: $e",
        source: "AutoCampaignApiClient",
        name: "fetchAutoCampaignStats",
        args: [campaignId],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<Keyword>>> fetchAutoCampaignDailyWordsStats(
      {required String token, required int campaignId}) async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = DateTime(now.year, now.month, now.day + 1);
    final Map<String, String> params = {
      "advert_id": campaignId.toString(),
      'from': formatDateForAutoCampaignDailyWordsStats(from),
      'to': formatDateForAutoCampaignDailyWordsStats(to),
    };

    final apiHelper = AutoCampaignApiHelper.getDailyWords;
    final response = await apiHelper.get(token, params);

    try {
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        List<Keyword> dailyKeywords = [];

        for (var dateData in data['keywords']) {
          for (var entry in dateData['stats']) {
            final keyword = Keyword.fromDailyWordsStatsJson(entry, campaignId);
            dailyKeywords.add(keyword);
          }
        }

        return Right(dailyKeywords);
      } else {
        final errString =
            apiHelper.errResponse(statusCode: response.statusCode);
        return Left(RewildError(
          sendToTg: true,
          errString,
          source: "AutoCampaignApiClient",
          name: "fetchAutoCampaignDailyWordsStats",
          args: [campaignId],
        ));
      }
    } catch (e) {
      return Left(RewildError(
        sendToTg: true,
        "Unknown error: $e",
        source: "AutoCampaignApiClient",
        name: "fetchAutoCampaignDailyWordsStats",
        args: [campaignId],
      ));
    }
  }
}
