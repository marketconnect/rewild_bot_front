import 'dart:convert';
import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/api_helpers/wb_questions_seller_api_helper.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/question_model.dart';
import 'package:rewild_bot_front/domain/services/question_service.dart';
import 'package:rewild_bot_front/domain/services/unanswered_feedback_qty_service.dart';

class QuestionsApiClient
    implements
        QuestionServiceQuestionApiClient,
        UnansweredFeedbackQtyServiceQuestionsApiClient {
  const QuestionsApiClient();

  @override
  Future<Either<RewildError, int>> getCountUnansweredQuestions(
      {required String token}) async {
    try {
      final wbApiHelper = WbQuestionsApiHelper.getUnansweredQuestionsCount;
      final response = await wbApiHelper.get(token);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final countUnanswered = responseData['data']['countUnanswered'] ?? 0;
        return right(countUnanswered);
      } else {
        final errString =
            wbApiHelper.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          sendToTg: true,
          errString,
          source: 'QuestionServiceQuestionApiClient',
          name: "getCountUnansweredQuestions",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Ошибка при получении количества неотвеченных вопросов: $e",
        source: 'QuestionServiceQuestionApiClient',
        name: "getCountUnansweredQuestions",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<QuestionModel>>> getUnansweredQuestions(
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
        'order': 'dateAsc',
      };

      if (nmId != null) {
        params['nmId'] = nmId.toString();
      }

      final wbApiHelper = WbQuestionsApiHelper.getQuestionsList;
      final response = await wbApiHelper.get(token, params);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        final List<QuestionModel> questions = [];
        final responseQuestions = (responseData['data']['questions']);
        for (var question in responseQuestions) {
          if (nmId != null) {}
          questions.add(QuestionModel.fromJson(question));
        }
        return right(questions);
      } else {
        final errString =
            wbApiHelper.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          sendToTg: true,
          errString,
          source: "QuestionsApiClient",
          name: "getUnansweredQuestions",
          args: [
            token,
          ],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Ошибка при получении списка вопросов: $e",
        source: "QuestionsApiClient",
        name: "getUnansweredQuestions",
        args: [
          token,
        ],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<QuestionModel>>> getAnsweredQuestions(
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
        'order': 'dateAsc',
      };

      if (nmId != null) {
        params['nmId'] = nmId.toString();
      }

      final wbApiHelper = WbQuestionsApiHelper.getQuestionsList;
      final response = await wbApiHelper.get(token, params);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        final List<QuestionModel> questions = [];
        final responseQuestions = (responseData['data']['questions']);
        for (var question in responseQuestions) {
          if (nmId != null) {}
          questions.add(QuestionModel.fromJson(question));
        }
        return right(questions);
      } else {
        final errString =
            wbApiHelper.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          sendToTg: true,
          errString,
          source: "QuestionsApiClient",
          name: "getAnsweredQuestions",
          args: [
            token,
          ],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Ошибка при получении списка вопросов: $e",
        source: "QuestionsApiClient",
        name: "getAnsweredQuestions",
        args: [
          token,
        ],
      ));
    }
  }

  @override
  Future<Either<RewildError, bool>> handleQuestion(
      {required String token,
      required String id,
      required String answer}) async {
    try {
      final body = {
        'id': id,
        'state': 'wbRu',
        'answer': {'text': answer},
      };

      final wbApiHelper = WbQuestionsApiHelper.patchQuestions;
      final response = await wbApiHelper.patch(token, body);

      if (response.statusCode == 200) {
        return right(true);
      } else {
        final errString =
            wbApiHelper.errResponse(statusCode: response.statusCode);
        return left(RewildError(
          sendToTg: true,
          errString,
          source: "QuestionsApiClient",
          name: "handleQuestion",
          args: [id, answer],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Ошибка при обработке вопроса: $e",
        source: "QuestionsApiClient",
        name: "handleQuestion",
        args: [id, answer],
      ));
    }
  }

  // Future<Either<RewildErrbool>> hasNewFeedbacksAndQuestions(String token) async {
  //   try {
  //     final wbApi = WbQuestionsApiHelper.getNewFeedbacksQuestions;
  //     final response = await wbApi.get(token);

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       final hasNewQuestions =
  //           responseData['data']['hasNewQuestions'] ?? false;
  //       final hasNewFeedbacks =
  //           responseData['data']['hasNewFeedbacks'] ?? false;
  //       return right(hasNewQuestions || hasNewFeedbacks);
  //     } else {
  //       final errString = wbApi.errResponse(statusCode: response.statusCode);
  //       return left(RewildError(
  // sendToTg: true,
  //         errString,
  //         source: "QuestionsApiClient",,
  //         name: "hasNewFeedbacksAndQuestions",
  //         args: [],
  //       );
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  // sendToTg: true,
  //       "Ошибка при проверке наличия новых отзывов и вопросов: $e",
  //       source: "QuestionsApiClient",,
  //       name: "hasNewFeedbacksAndQuestions",
  //       args: [],
  //     );
  //   }
  // }

  // Future<Either<RewildErrList<String>>> getFrequentlyAskedProducts(
  //     String token, int size) async {
  //   try {
  //     final params = {'size': size.toString()};
  //     final wbApi = WbQuestionsApiHelper.getFrequentlyAskedProducts;
  //     final response = await wbApi.get(token, params);

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       final List<String> products =
  //           List<String>.from(responseData['data']['products']);
  //       return right(products);
  //     } else {
  //       final errString = wbApi.errResponse(statusCode: response.statusCode);
  //       return left(RewildError(
  // sendToTg: true,
  //         errString,
  //         source: "QuestionsApiClient",,
  //         name: "getFrequentlyAskedProducts",
  //         args: [, size],
  //       );
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  // sendToTg: true,
  //       "Ошибка при получении часто задаваемых товаров: $e",
  //       source: "QuestionsApiClient",,
  //       name: "getFrequentlyAskedProducts",
  //       args: [, size],
  //     );
  //   }
  // }
}
