// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rewild_bot_front/env.dart';

Future<void> sendMessageToTelegramBot(
    String botToken, String chatId, String message) async {
  Uri url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');

  // all errors will be sent to server otherwise to telegram
  if (chatId == TBot.tBotErrorChatId && message.isNotEmpty) {
    url = Uri.parse('${ServerConstants.apiUrl}/service');
  }

  try {
    final _ = await http.post(
      url,
      body: json.encode({
        'chat_id': chatId,
        'text': message,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return;
  }
}
