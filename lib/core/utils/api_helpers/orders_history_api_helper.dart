import 'package:rewild_bot_front/core/utils/api_helpers/api_helper.dart';

class WbOrdersHistoryApiHelper {
  static const String host = 'product-order-qnt.wildberries.ru';

  static ApiHelper get = ApiHelper(
    host: host,
    url: '/v2/by-nm',
    requestLimitPerMinute: 120,
    statusCodeDescriptions: {},
  );
}
