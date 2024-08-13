import 'package:rewild_bot_front/core/utils/api_helpers/api_helper.dart';

class WbContentApiHelper {
  static const String _host = 'suppliers-api.wildberries.ru';

  static const String _path = '/content/v2/get/cards/list';
  static const String _cardsLimitsPath = '/content/v2/cards/limits';

  static ApiHelper getNomenclaturesList = ApiHelper(
    host: _host,
    url: _path,
    requestLimitPerMinute: 60,
    statusCodeDescriptions: {
      200: 'Успешный ответ',
      400: 'Неверная форма запроса',
      401: 'Не авторизован',
      403: 'Доступ запрещен',
    },
  );
  static ApiHelper getCardsLimits = ApiHelper(
    host: _host,
    url: _cardsLimitsPath,
    requestLimitPerMinute: 60,
    statusCodeDescriptions: {
      200: 'Successful response',
      401: 'Unauthorized',
      403: 'Access denied',
    },
  );
  static ApiHelper addMediaFile = ApiHelper(
    host: _host,
    url: '/content/v3/media/file',
    requestLimitPerMinute: 60, // Adjust according to API limits
    statusCodeDescriptions: {
      200: 'Media file successfully added',
      400: 'Invalid request format',
      401: 'Not authorized',
    },
  );
  static const String updateCardPath = '/content/v2/cards/update';

  static ApiHelper updateCard = ApiHelper(
    host: _host,
    url: updateCardPath,
    requestLimitPerMinute: 60, // Example limit
    statusCodeDescriptions: {
      200: 'Card updated successfully',
      400: 'Bad Request - Check your request parameters',
      401: 'Unauthorized - Missing or invalid API key',
      403: 'Forbidden - Access denied',
      // Add other relevant status codes as needed
    },
  );

  // Existing methods ...
  static ApiHelper updateMediaFiles = ApiHelper(
    host: _host,
    url: '/content/v3/media/save',
    requestLimitPerMinute: 60, // Example limit, adjust as needed
    statusCodeDescriptions: {
      200: 'Media files updated successfully',
      400: 'Invalid request format',
      401: 'Not authorized',
      403: 'Access forbidden',
      // Add any other relevant status codes as per API documentation
    },
  );
}
