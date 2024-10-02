// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class TelegramWebApp {
  static final TelegramWebApp _instance = TelegramWebApp._internal();

  factory TelegramWebApp() {
    return _instance;
  }

  TelegramWebApp._internal();

  static Future<String> getChatId() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (js.context['Telegram'] == null) {
      return 'Telegram object is null';
    }
    if (js.context['Telegram']['WebApp'] == null) {
      return 'WebApp object is null';
    }
    if (js.context['Telegram']['WebApp']['initDataUnsafe'] == null) {
      return 'initDataUnsafe object is null';
    }

    final tgInitData = js.context['Telegram']['WebApp']['initDataUnsafe'];
    if (tgInitData != null && tgInitData['user'] != null) {
      return tgInitData['user']['id'].toString();
    } else {
      return 'Unknown chatId';
    }
  }

  static void expandTelegramWebApp() {
    final telegram = js.context['Telegram'];
    print('expandTelegramWebApp: $telegram');
    if (telegram != null) {
      print('expandTelegramWebApp not null: $telegram');
      final webApp = telegram['WebApp'];
      if (webApp != null) {
        print('expandTelegramWebApp webApp not null: $webApp');
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
