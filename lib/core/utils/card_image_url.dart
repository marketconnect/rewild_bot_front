// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

Future<String?> findValidImageUrl(int sku) async {
  // Основные части URL
  String baseUrl = 'https://basket-';
  String middleUrl =
      '.wbbasket.ru/vol${sku.toString().substring(0, 4)}/part${sku.toString().substring(0, 6)}/$sku/images/big/1.webp';

  // Check all URL from basket-01 to basket-15
  for (int i = 1; i <= 15; i++) {
    String basketUrl = baseUrl + i.toString().padLeft(2, '0') + middleUrl;
    http.Response response = await http.get(Uri.parse(basketUrl));

    if (response.statusCode == 200) {
      return basketUrl; // if URL is valid, return it
    }
  }

  return null; // if no valid URL was found
}
