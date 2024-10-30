// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rewild_bot_front/env.dart';

enum SystemMessageType { error, feedback }

Future<void> sendSystemMessage(String message, SystemMessageType type) async {
  switch (type) {
    case SystemMessageType.error:
      const chatId = TBot.tBotErrorChatId;
      final url = Uri.parse('${ServerConstants.apiUrl}/service');
      await _req(url, chatId, message);
      break;
    case SystemMessageType.feedback:
      const chatId = TBot.tBotFeedbackChatId;
      const botToken = TBot.tBotFeedbackToken;
      Uri url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');

      await _req(url, chatId, message);
      break;
    default:
      break;
  }
}

Future<void> _req(Uri url, String chatId, String message) async {
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
