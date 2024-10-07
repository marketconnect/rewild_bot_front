// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:convert'; // Для декодирования JSON
import 'dart:html'; // Для доступа к window.location

class TelegramWebApp {
  static final TelegramWebApp _instance = TelegramWebApp._internal();

  factory TelegramWebApp() {
    return _instance;
  }

  TelegramWebApp._internal();

  static Future<String> getChatId() async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Попытка получить initData из js.context
    String? initData;
    if (js.context['Telegram'] != null &&
        js.context['Telegram']['WebApp'] != null &&
        js.context['Telegram']['WebApp']['initData'] != null) {
      initData = js.context['Telegram']['WebApp']['initData'] as String?;
    }

    // Если не удалось получить initData из js.context, попробуем из URL
    if (initData == null || initData.isEmpty) {
      initData = window.location.href.split('?').length > 1
          ? window.location.href.split('?')[1]
          : '';
    }

    if (initData.isEmpty) {
      return '';
    }

    try {
      // Парсим initData как строку параметров запроса
      final params = Uri.splitQueryString(initData);

      // Проверяем наличие параметра 'user' и декодируем его
      if (params.containsKey('user')) {
        final userJson = params['user'];
        if (userJson != null) {
          final userMap = json.decode(userJson);
          if (userMap is Map && userMap.containsKey('id')) {
            return userMap['id'].toString();
          }
        }
      }

      // Если 'user' отсутствует, проверяем 'chat'
      if (params.containsKey('chat')) {
        final chatJson = params['chat'];
        if (chatJson != null) {
          final chatMap = json.decode(chatJson);
          if (chatMap is Map && chatMap.containsKey('id')) {
            return chatMap['id'].toString();
          }
        }
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  static void expandTelegramWebApp() {
    final telegram = js.context['Telegram'];
    if (telegram != null) {
      final webApp = telegram['WebApp'];
      if (webApp != null) {
        webApp.callMethod('expand');
      }
    }
  }

  static void setTelegramHeaderColor(String color) {
    final telegram = js.context['Telegram'];
    if (telegram != null) {
      final webApp = telegram['WebApp'];
      if (webApp != null) {
        webApp.callMethod('setHeaderColor', [color]);
      }
    }
  }
}
