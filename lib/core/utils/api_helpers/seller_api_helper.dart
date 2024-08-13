import 'package:rewild_bot_front/core/utils/api_helpers/api_helper.dart';

class SellerApiHelper {
  static const String host = 'wildberries.ru';

  static ApiHelper get = ApiHelper(
    host: host,
    url: '/webapi/seller/data/short/',
    requestLimitPerMinute: 60,
    statusCodeDescriptions: {},
  );
}
