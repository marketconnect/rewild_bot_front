import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendMessageToTelegramBot(
    String botToken, String chatId, String message) async {
  final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');

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
