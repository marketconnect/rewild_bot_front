import 'package:rewild_bot_front/core/utils/api_helpers/api_helper.dart';

class NormQueryApiHelper {
  static const String _host = 'search.wb.ru';
  static const String _path = '/exactmatch/ru/common/v4/search';

  static ApiHelper search = ApiHelper(
    host: _host,
    url: _path,
    requestLimitPerMinute: 360, // Example limit
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок',
    },
  );
}
