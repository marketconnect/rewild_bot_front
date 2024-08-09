import 'package:jwt_decode/jwt_decode.dart';

Map<String, dynamic> decodeJWT(String token, String language) {
  try {
    // Декодирование токена без проверки подписи
    Map<String, dynamic> payload = Jwt.parseJwt(token);

    // Извлекаем scopes и время окончания токена
    final int? scopesMask = payload['s'];
    final int? exp = payload['exp'];
    final String? id = payload['id'];
    final String? sid = payload['sid'];

    final DateTime timeEnd = DateTime.fromMillisecondsSinceEpoch(exp! * 1000);
    final List<String> scopes = _decodeScopes(scopesMask!, language);

    return {
      'id': id,
      'sellerId': sid,
      'scopes': scopes,
      'timeEnd': timeEnd.toString(),
      'tokenReadOrWrite': scopes.last,
    };
  } catch (e) {
    return {};
  }
}

List<String> _decodeScopes(int s, String language) {
  final Map<String, Map<String, String>> languageDictionary = {
    'testContour': {'ru': 'Тестовый контур', 'en': 'Test contour'},
    'content': {'ru': 'Контент', 'en': 'Content'},
    'analytics': {'ru': 'Аналитика', 'en': 'Analytics'},
    'pricesDiscounts': {'ru': 'Цены и скидки', 'en': 'Prices and discounts'},
    'marketplace': {'ru': 'Маркетплейс', 'en': 'Marketplace'},
    'statistics': {'ru': 'Статистика', 'en': 'Statistics'},
    'promotion': {'ru': 'Продвижение', 'en': 'Promotion'},
    'questionsFeedbacks': {
      'ru': 'Вопросы и отзывы',
      'en': 'Questions and feedbacks'
    },
    'chat': {'ru': 'Чат с покупателями', 'en': 'Buyers chat'},
    'recommendations': {'ru': 'Рекомендации', 'en': 'Recommendations'},
    'tokenReadOnly': {
      'ru': 'Токен только на чтение',
      'en': 'Token with read only access'
    },
    'tokenReadWrite': {
      'ru': 'Токен на чтение и запись',
      'en': 'Token with read and write access'
    }
  };

  final List<String> scopes = [];

  if (s & 0x001 == 0x001) {
    scopes.add(languageDictionary['testContour']![language]!);
  }
  if (s & 0x002 == 0x002) scopes.add(languageDictionary['content']![language]!);
  if (s & 0x004 == 0x004) {
    scopes.add(languageDictionary['analytics']![language]!);
  }
  if (s & 0x008 == 0x008) {
    scopes.add(languageDictionary['pricesDiscounts']![language]!);
  }
  if (s & 0x010 == 0x010) {
    scopes.add(languageDictionary['marketplace']![language]!);
  }
  if (s & 0x020 == 0x020) {
    scopes.add(languageDictionary['statistics']![language]!);
  }
  if (s & 0x040 == 0x040) {
    scopes.add(languageDictionary['promotion']![language]!);
  }
  if (s & 0x080 == 0x080) {
    scopes.add(languageDictionary['questionsFeedbacks']![language]!);
  }
  if (s & 0x100 == 0x100) scopes.add(languageDictionary['chat']![language]!);
  if (s & 0x200 == 0x200) {
    scopes.add(languageDictionary['recommendations']![language]!);
  }

  // Определение типа доступа (чтение/запись)
  if (s & 0x40000000 == 0x40000000) {
    scopes.add(languageDictionary['tokenReadOnly']![language]!);
  } else {
    scopes.add(languageDictionary['tokenReadWrite']![language]!);
  }

  return scopes;
}
