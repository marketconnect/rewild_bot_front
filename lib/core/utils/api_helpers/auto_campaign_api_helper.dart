import 'package:rewild_bot_front/core/utils/api_helpers/api_helper.dart';

class AutoCampaignApiHelper {
  static const String host = 'advert-api.wb.ru';

  static ApiHelper getStatWords = ApiHelper(
    host: host,
    url: '/adv/v2/auto/stat-words',
    requestLimitPerMinute: 240, // Derived from 4 requests per second
    statusCodeDescriptions: {
      200: 'Successful Response',
      400: 'Bad Request - Проверьте параметры запроса',
      401: 'Не авторизован - Отсутствует или неверный API ключ',
      429:
          'Превышен лимит по запросам - Слишком много запросов в единицу времени',
      // Additional status codes as needed
    },
  );

  // Adding new API for daily keywords statistics
  static ApiHelper getDailyWords = ApiHelper(
    host: host,
    url: '/adv/v2/auto/daily-words',
    requestLimitPerMinute:
        240, // 4 requests per second translates to 240 requests per minute
    statusCodeDescriptions: {
      200: 'Successful Response',
      400: 'Bad Request - Проверьте параметры запроса',
      401: 'Не авторизован - Отсутствует или неверный API ключ',
      429:
          'Превышен лимит по запросам - Слишком много запросов в единицу времени',
      // Additional status codes as needed
    },
  );
}
