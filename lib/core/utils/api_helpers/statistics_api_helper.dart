import 'package:rewild_bot_front/core/utils/api_helpers/api_helper.dart';

class StatisticsApiHelper {
  static const String _host = 'statistics-api.wildberries.ru';

  static ApiHelper reportDetailByPeriod = ApiHelper(
    host: _host,
    url: '/api/v5/supplier/reportDetailByPeriod',
    requestLimitPerMinute: 1, // Maximum of 1 request per minute
    statusCodeDescriptions: {
      200: 'Список реализованных позиций',
      401: 'Не авторизован',
      429: 'Превышен лимит по запросам',
      400: 'Некорректный запрос',
      500: 'Внутренняя ошибка сервера',
    },
  );

  static ApiHelper incomes = ApiHelper(
    host: _host,
    url: '/api/v1/supplier/incomes',
    requestLimitPerMinute: 1, // Maximum of 1 request per minute
    statusCodeDescriptions: {
      200: 'Успешный ответ',
      401: 'Не авторизован',
      429: 'Слишком много запросов',
    },
  );
}
