import 'package:rewild_bot_front/core/utils/api_helpers/api_helper.dart';

class WbWarehousesHistoryApiHelper {
  static const String host = 'wildberries.ru';

  static ApiHelper get = ApiHelper(
    host: host,
    url: '/webapi/spa/product/deliveryinfo',
    requestLimitPerMinute: 300,
    statusCodeDescriptions: {},
  );
}
