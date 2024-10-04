import 'dart:convert';
import 'package:fpdart/fpdart.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:rewild_bot_front/core/constants/messages_constants.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/services/gpt_service.dart';

class GptApiClient implements GptServiceGptApiClient {
  const GptApiClient();

  // Chat completion request
  @override
  Future<Either<RewildError, String>> chatCompletion({
    required String token,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    double topP = 0.9,
    int maxTokens = 150,
    int n = 1,
  }) async {
    try {
      final uri = Uri.parse('https://rewild.website/api/chat');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'messages': messages,
          'temperature': temperature,
          'top_p': topP,
          'max_tokens': maxTokens,
          'n': n,
        }),
      );
      if (response.statusCode == 402) {
        return right(MessagesConstants.chatGptNotEnoughTokens);
      }

      // Check if the server responded with success
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode((response.bodyBytes)));
        return right(data['choices'][0]['content'] as String);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка HTTP: ${response.statusCode}",
          source: "GptApiClient",
          name: "chatCompletion",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: ${e.toString()}",
        source: "GptApiClient",
        name: "chatCompletion",
        args: [],
      ));
    }
  }
}
