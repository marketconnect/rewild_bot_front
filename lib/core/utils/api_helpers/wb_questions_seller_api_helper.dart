import 'package:rewild_bot_front/core/utils/api_helpers/api_helper.dart';

class WbQuestionsApiHelper {
  static const String host = 'feedbacks-api.wildberries.ru';

  // Получение количества неотвеченных вопросов за сегодня и всё время
  static ApiHelper getUnansweredQuestionsCount = ApiHelper(
    host: host,
    url: '/api/v1/questions/count-unanswered',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Ошибка переданных параметров',
      401: 'Не авторизован',
    },
  );

  // Информация о наличии непросмотренных отзывов и вопросов
  static ApiHelper getNewFeedbacksQuestions = ApiHelper(
    host: host,
    url: '/api/v1/new-feedbacks-questions',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      401: 'Не авторизован',
      403: 'Ошибка авторизации',
    },
  );

  // Получение товаров, про которые чаще всего спрашивают
  static ApiHelper getFrequentlyAskedProducts = ApiHelper(
    host: host,
    url: '/api/v1/questions/products/rating',
    requestLimitPerMinute: 240, // 240 per minute
    statusCodeDescriptions: {
      400: 'Ошибка переданных параметров',
      401: 'Не авторизован',
      403: 'Ошибка авторизации',
    },
  );

  // Получение списка вопросов
  static ApiHelper getQuestionsList = ApiHelper(
    host: host,
    url: '/api/v1/questions',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Ошибка переданных параметров',
      401: 'Не авторизован',
      403: 'Ошибка авторизации',
    },
  );

  // Работа с вопросами
  static ApiHelper patchQuestions = ApiHelper(
    host: host,
    url: '/api/v1/questions',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Ошибка переданных параметров',
      401: 'Не авторизован',
      403: 'Ошибка авторизации',
      404: 'Ошибка - не найдено',
    },
  );
  // Метод позволяет получить вопрос по его Id.
  static ApiHelper getQuestionById = ApiHelper(
    host: host,
    url: '/api/v1/question',
    requestLimitPerMinute: 60, // unknown
    statusCodeDescriptions: {
      401: 'Не авторизован',
    },
  );
}
