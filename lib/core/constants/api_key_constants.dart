enum ApiKeyType {
  stat,
  promo,
  question,
  analytics,
  content,
}

class ApiKeyConstants {
  static const Map<ApiKeyType, String> apiKeyTypes = {
    ApiKeyType.stat: "Статистика",
    ApiKeyType.promo: "Продвижение",
    ApiKeyType.analytics: "Аналитика",
    ApiKeyType.question: "Вопросы/Отз.",
    ApiKeyType.content: "Контент",
  };
}
