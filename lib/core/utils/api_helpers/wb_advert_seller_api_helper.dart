import 'package:rewild_bot_front/core/utils/api_helpers/api_helper.dart';

class WbAdvertApiHelper {
  static const String host = 'advert-api.wb.ru';

  // General =========================================================== General
  // Изменение ставки у кампании
  static ApiHelper setCpm = ApiHelper(
    host: host,
    url: '/adv/v0/cpm',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректное значение параметра param',
      401: 'Пустой авторизационный заголовок',
      422: 'Ошибка обработки тела запроса'
    },
  );

  // Пауза кампании
  static ApiHelper pauseCampaign = ApiHelper(
    host: host,
    url: '/adv/v0/pause',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор РК',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Запуск кампании
  static ApiHelper startCampaign = ApiHelper(
    host: host,
    url: '/adv/v0/start',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор РК',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Бюджет кампании
  static ApiHelper getCompanyBudget = ApiHelper(
    host: host,
    url: '/adv/v1/budget',
    requestLimitPerMinute:
        120, // 240 per minute, but it's not enough in practice
    statusCodeDescriptions: {
      400: 'кампания не принадлежит продавцу',
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Списки кампаний
  static ApiHelper getCampaigns = ApiHelper(
    host: host,
    url: '/adv/v1/promotion/count',
    requestLimitPerMinute: 300, // 300 per minute
    statusCodeDescriptions: {
      401: 'Пустой авторизационный заголовок',
    },
  );

  static ApiHelper depositBudget = ApiHelper(
    host: host,
    url: '/adv/v1/budget/deposit',
    requestLimitPerMinute:
        60, // Так как допускается 1 запрос в секунду, это равно 60 запросов в минуту.
    statusCodeDescriptions: {
      200: 'Бюджет пополнен',
      400:
          'Бюджет не пополнен - некорректный запрос или проблема с параметрами',
      401: 'Не авторизован - Отсутствует или неверный API ключ',
      429: 'Превышен лимит по запросам - Слишком много запросов',
      // Дополнительные коды ошибок могут быть добавлены здесь.
    },
  );

  // Информация о кампаниях
  static ApiHelper getCampaignsInfo = ApiHelper(
    host: host,
    url: '/adv/v1/promotion/adverts',
    requestLimitPerMinute: 250, // 300 per minute
    statusCodeDescriptions: {
      400: 'Некорректное значение параметра type',
      401: 'Пустой авторизационный заголовок',
      422: 'Ошибка обработки параметров запроса',
    },
  );
  // static ApiHelper autDailyWords = ApiHelper(
  //   host: host,
  //   url: '/adv/v2/auto/daily-words',
  //   requestLimitPerMinute:
  //       240, // 4 requests per second translates to 240 requests per minute
  //   statusCodeDescriptions: {
  //     200: 'Successful response with daily keyword statistics',
  //     400: 'Bad request - Check your request parameters',
  //     401: 'Unauthorized - Missing or invalid API key',
  //     429: 'Rate limit exceeded - Too many requests in a short period',
  //   },
  // );

  // Информация о кампании
  // static ApiHelper getCampaignInfo = ApiHelper(
  //   host: host,
  //   url: '/adv/v1/promotion/adverts',
  //   requestLimitPerMinute: 300, // 300 per minute
  //   statusCodeDescriptions: {
  //     204: 'Кампания не найдена',
  //     400: 'Некорректное значение параметра type',
  //     401: 'Пустой авторизационный заголовок',
  //     422: 'Ошибка обработки параметров запроса',
  //   },
  // );

  // Баланс
  static ApiHelper getBalance = ApiHelper(
    host: host,
    url: '/adv/v1/balance',
    requestLimitPerMinute: 60, // 60 per minute
    statusCodeDescriptions: {
      400: 'Некорректный идентификатор продавца',
      401: 'Пустой авторизационный заголовок',
    },
  );

  // Полная статистика кампании
  static ApiHelper getFullStat = ApiHelper(
    host: host,
    url: '/adv/v2/fullstats',
    requestLimitPerMinute: 1, // 1 per minute
    statusCodeDescriptions: {
      400: 'Bad Request',
      401: 'Unauthorized',
      429: 'Too Many Requests',
    },
  );

  static ApiHelper getExpensesHistory = ApiHelper(
    host: host,
    url: '/adv/v1/upd',
    requestLimitPerMinute: 60, // 1 per minute
    statusCodeDescriptions: {
      200: 'Успешно',
      400: 'Некорректный запрос',
      401: 'Не авторизован',
      429: 'Превышен лимит по запросам',
      // Добавьте другие коды состояния и их описания, если это необходимо
    },
  );

  // Auto ================================================================= Auto
  // Статистика автоматической кампании
  // static ApiHelper autoGetStat = ApiHelper(
  //   host: host,
  //   url: '/adv/v1/auto/stat',
  //   requestLimitPerMinute: 10, // 10 per minute
  //   statusCodeDescriptions: {
  //     400: 'Кампания не найдена',
  //     401: 'Пустой авторизационный заголовок',
  //     429: 'Превышен лимит запросов в минуту',
  //   },
  // );

  static ApiHelper searchCatalogueGetStat = ApiHelper(
    host: host,
    url: '/adv/v1/seacat/stat',
    requestLimitPerMinute: 10, // 10 per minute
    statusCodeDescriptions: {
      400: 'Кампания не найдена',
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Статистика автоматической кампании по ключевым фразам
  static ApiHelper autoGetStatsWords = ApiHelper(
    host: host,
    url: '/adv/v1/auto/stat-words',
    requestLimitPerMinute: 10, // 10 per minute
    statusCodeDescriptions: {
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Search ============================================================= Search
  // Статистика поисковой кампании по ключевым фразам
  static ApiHelper searchGetStatsWords = ApiHelper(
    host: host,
    url: '/adv/v1/stat/words',
    requestLimitPerMinute: 240, // 240 per minute
    statusCodeDescriptions: {
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );

  // Установка/удаление минус-фраз из поиска для кампании в поиске
  static ApiHelper searchSetExcludedKeywords = ApiHelper(
    host: host,
    url: '/adv/v1/search/set-excluded',
    requestLimitPerMinute: 60, //
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление минус-фраз фразового соответствия для кампании в поиске
  static ApiHelper searchSetPhraseKeywords = ApiHelper(
    host: host,
    url: '/adv/v1/search/set-phrase',
    requestLimitPerMinute: 60, //
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление минус-фраз точного соответствия для кампании в поиске
  static ApiHelper searchSetStrongKeywords = ApiHelper(
    host: host,
    url: '/adv/v1/search/set-strong',
    requestLimitPerMinute: 60, //
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок'
    },
  );

  // Установка/удаление фиксированных фраз у кампании в поиске
  static ApiHelper searchSetPlusKeywords = ApiHelper(
    host: host,
    url: '/adv/v1/search/set-plus',
    requestLimitPerMinute: 120, // 2 per second
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
    },
  );

  // Установка/удаление минус-фраз для автоматической кампаний
  static ApiHelper autoSetExcludedKeywords = ApiHelper(
    host: host,
    url: '/adv/v1/auto/set-excluded',
    requestLimitPerMinute: 10, // 10 per min
    statusCodeDescriptions: {
      400: 'Некорректный запрос',
      401: 'Пустой авторизационный заголовок',
      429: 'Превышен лимит запросов в минуту',
    },
  );
}
