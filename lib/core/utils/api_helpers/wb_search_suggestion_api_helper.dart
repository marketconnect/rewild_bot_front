class WBSearchSuggestionApiHelper {
  static const String baseUrl = "https://search.wb.ru/suggests/api/v5/hint";
  static const Map<String, String> headers = {
    "Accept": "*/*",
    "Accept-Language": "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7",
  };

  // Method to construct the Uri with query parameters
  static Uri buildUri(Map<String, dynamic> queryParams) {
    return Uri.parse(baseUrl).replace(queryParameters: queryParams);
  }
}
