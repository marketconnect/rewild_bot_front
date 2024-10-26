import 'dart:convert';
import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/api_helpers/wb_review_seller_api_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/domain/entities/review_model.dart';
import 'package:rewild_bot_front/domain/services/review_service.dart';
import 'package:rewild_bot_front/domain/services/unanswered_feedback_qty_service.dart';
import 'package:rewild_bot_front/env.dart';

class ReviewApiClient
    implements
        UnansweredFeedbackQtyServiceReviewsApiClient,
        ReviewServiceReviewApiClient {
  const ReviewApiClient();

  @override
  Future<Either<RewildError, int>> getCountUnansweredReviews(
      {required String token}) async {
    try {
      final wbApi = WbReviewApiHelper.countUnansweredFeedbacks;
      final response = await wbApi.get(
        token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int countUnanswered = responseData['data']['countUnanswered'];
        return right(countUnanswered); // Use 'right' for successful result
      } else {
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return left(RewildError(
            sendToTg: true,
            errString,
            source: "reviewsApiClint",
            name: "getCountUnansweredQuestions",
            args: [])); // Use 'left' for error
      }
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          "Error: $e",
          source: "reviewsApiClint",
          name: "getCountUnansweredQuestions",
          args: []));
    }
  }

  static Future<Either<RewildError, int>> getCountUnansweredReviewsInBackground(
      {required String token}) async {
    try {
      final wbApi = WbReviewApiHelper.countUnansweredFeedbacks;
      final response = await wbApi.get(
        token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int countUnanswered = responseData['data']['countUnanswered'];
        return right(countUnanswered); // Use 'right' for successful result
      } else {
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return left(RewildError(
            sendToTg: true,
            errString,
            source: 'getCountUnansweredReviewsInBackground',
            name: "getCountUnansweredReviews",
            args: [])); // Use 'left' for error
      }
    } catch (e) {
      return left(RewildError(
          sendToTg: true,
          "Error: $e",
          source: "getCountUnansweredReviewsInBackground",
          name: "getCountUnansweredReviews",
          args: []));
    }
  }

  @override
  Future<Either<RewildError, List<ReviewModel>>> getUnansweredReviews(
      {required String token,
      required int take,
      required int skip,
      required int dateFrom,
      required int dateTo,
      int? nmId}) async {
    try {
      final params = {
        'isAnswered': false.toString(),
        'take': take.toString(),
        'skip': skip.toString(),
        'dateFrom': dateFrom.toString(),
        'dateTo': dateTo.toString(),
        'order': 'dateDesc',
      };

      if (nmId != null) {
        params['nmId'] = nmId.toString();
      }

      final wbApi = WbReviewApiHelper.getFeedbacks;
      final response = await wbApi.get(token, params);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        final List<ReviewModel> reviews = [];
        final responseReviews = (responseData['data']['feedbacks']);

        for (final review in responseReviews) {
          reviews.add(ReviewModel.fromJson(review));
        }
        return right(reviews);
      } else {
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          sendToTg: true,
          errString,
          source: "reviewsApiClint",
          name: "getUnAnsweredReviews",
          args: [take, skip, nmId],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Ошибка при получении списка отзывов: $e",
        source: "reviewsApiClint",
        name: "getFeedbacks",
        args: [take, skip, nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<ReviewModel>>> getAnsweredReviews(
      {required String token,
      required int take,
      required int skip,
      required int dateFrom,
      required int dateTo,
      int? nmId}) async {
    try {
      final params = {
        'isAnswered': true.toString(),
        'take': take.toString(),
        'skip': skip.toString(),
        'dateFrom': dateFrom.toString(),
        'dateTo': dateTo.toString(),
        'order': 'dateDesc',
      };
      if (nmId != null) {
        params['nmId'] = nmId.toString();
      }

      final wbApi = WbReviewApiHelper.getFeedbacks;
      final response = await wbApi.get(token, params);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));

        final List<ReviewModel> reviews = [];
        final responseReviews = (responseData['data']['feedbacks']);

        for (final review in responseReviews) {
          reviews.add(ReviewModel.fromJson(review));
        }
        return right(reviews);
      } else {
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          sendToTg: true,
          errString,
          source: "reviewsApiClint",
          name: "getAnsweredReviews",
          args: [take, skip, nmId],
        ));
      }
    } catch (e) {
      sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
          'reviewsApiClient getAnsweredReviews ${e.toString()}');
      return left(RewildError(
        sendToTg: true,
        "Ошибка при получении списка отзывов: $e",
        source: "reviewsApiClint",
        name: "getAnsweredReviews",
        args: [take, skip, nmId],
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> handleReview(
      {required String token,
      required String id,
      required bool wasViewed,
      required bool wasRejected,
      required String answer}) async {
    try {
      final body = {
        'id': id,
        'text': answer,
      };

      final wbApi = WbReviewApiHelper.patchFeedbacks;
      final response = await wbApi.patch(token, body);

      if (response.statusCode == 200) {
        return right(true);
      } else {
        final errString = wbApi.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          sendToTg: true,
          errString,
          source: "reviewsApiClint",
          name: "handleReview",
          args: [id, wasViewed, wasRejected, answer],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Ошибка при обработке отзыва: $e",
        source: "reviewsApiClint",
        name: "handleReview",
        args: [id, wasViewed, wasRejected, answer],
      ));
    }
  }
}
