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
}