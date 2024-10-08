import 'dart:js' as js;
import 'dart:convert';
import 'dart:html';

class TelegramWebApp {
  static final TelegramWebApp _instance = TelegramWebApp._internal();

  factory TelegramWebApp() {
    return _instance;
  }

  TelegramWebApp._internal();

  static Future<String> getChatId() async {
    String? initData;

    if (js.context['Telegram'] != null &&
        js.context['Telegram']['WebApp'] != null &&
        js.context['Telegram']['WebApp']['initData'] != null) {
      initData = js.context['Telegram']['WebApp']['initData'] as String?;
    } else {}

    if (initData == null || initData.isEmpty) {
      initData = window.location.href.split('?').length > 1
          ? window.location.href.split('?')[1]
          : '';
    }

    if (initData.isEmpty) {
      return '';
    }

    try {
      final params = Uri.splitQueryString(initData);

      if (params.containsKey('user')) {
        final userMap = json.decode(params['user']!);

        if (userMap is Map && userMap.containsKey('id')) {
          return userMap['id'].toString();
        }
      }

      if (params.containsKey('chat')) {
        final chatMap = json.decode(params['chat']!);

        if (chatMap is Map && chatMap.containsKey('id')) {
          return chatMap['id'].toString();
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
