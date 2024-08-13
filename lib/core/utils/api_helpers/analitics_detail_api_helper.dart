import 'package:rewild_bot_front/core/utils/api_helpers/api_helper.dart';

class AnalyticsApiHelper {
  static const String _host = 'suppliers-api.wildberries.ru';
  static const String _path = '/content/v1/analytics/nm-report/detail';
  static const String exciseReportHost = 'seller-analytics-api.wildberries.ru';
  static const String exciseReportPath = '/api/v1/analytics/excise-report';

  static ApiHelper detail = ApiHelper(
    host: _host,
    url: _path,
    requestLimitPerMinute: 3, // Limit as per the endpoint's specification
    statusCodeDescriptions: {
      200: 'Успешно',
      400: 'Некорректный формат запроса',
      403: 'Доступ запрещен',
      500: 'Внутренняя ошибка сервера',
    },
  );

  static ApiHelper exciseReport = ApiHelper(
    host: exciseReportHost,
    url: exciseReportPath,
    requestLimitPerMinute:
        2, // Maximum of 10 requests per 5 hours translates to roughly 2 requests per hour
    statusCodeDescriptions: {
      200: 'Отчет',
      400: 'Неправильный запрос',
      401: 'Пользователь не авторизован',
      403: 'Доступ запрещён',
      404: 'Такой адрес не найден',
      500: 'Внутренняя ошибка сервиса',
    },
  );
}
