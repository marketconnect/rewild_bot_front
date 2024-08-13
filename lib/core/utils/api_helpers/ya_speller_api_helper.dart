import 'package:rewild_bot_front/core/utils/api_helpers/api_helper.dart';

class YandexSpellerApiHelper {
  static const String host = 'speller.yandex.net';
  static const String checkTextPath = '/services/spellservice.json/checkText';

  // Метод для проверки текста на наличие орфографических ошибок
  static ApiHelper checkText = ApiHelper(
    host: host,
    url: checkTextPath,
    requestLimitPerMinute: 60, // Установите соответствующий лимит
    statusCodeDescriptions: {
      200: 'Успешно',
      400: 'Ошибка переданных параметров',
      401: 'Не авторизован',
      403: 'Ошибка авторизации',
    },
  );

  // Вы можете добавить здесь дополнительные методы или логику, если это необходимо
}
