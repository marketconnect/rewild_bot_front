import 'dart:convert';
import 'package:fpdart/fpdart.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/domain/entities/user_auth_data.dart';
import 'package:rewild_bot_front/domain/services/auth_service.dart';
import 'package:rewild_bot_front/env.dart';

class AuthApiClient implements AuthServiceAuthApiClient {
  const AuthApiClient();

  @override
  Future<Either<RewildError, UserAuthData>> registerUser({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('https://rewild.website/api/register');
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': 'YOUR_API_KEY',
    };
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        sendMessageToTelegramBot(
          TBot.tBotErrorToken,
          TBot.tBotErrorChatId,
          'Пользователь $username зарегистрирован $data!',
        );
        final expiredAt = data['expiredAt'] is int
            ? data['expiredAt']
            : int.parse(data['expiredAt']);
        return right(UserAuthData(
          token: data['token'],
          expiredAt: expiredAt,
          freebie: true,
        ));
      } else {
        final errorString = 'HTTP Error: ${response.statusCode}';
        return left(RewildError(
          sendToTg: true,
          errorString,
          source: "AuthApiClient",
          name: 'registerUser',
          args: [username, password],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Неизвестная ошибка: ${e.toString()}',
        source: "AuthApiClient",
        name: 'registerUser',
        args: [username, password],
      ));
    }
  }

  @override
  Future<Either<RewildError, UserAuthData>> loginUser({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('https://rewild.website/api/login');
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': 'YOUR_API_KEY', // Replace with the actual API key
    };
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return right(UserAuthData(
          token: data['token'],
          expiredAt: int.parse(data['expiredAt']),
          freebie: true,
        ));
      } else {
        final errorString = 'HTTP Error: ${response.statusCode}';
        return left(RewildError(
          sendToTg: true,
          errorString,
          source: "AuthApiClient",
          name: 'loginUser',
          args: [username, password],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        'Неизвестная ошибка: ${e.toString()}',
        source: "AuthApiClient",
        name: 'loginUser',
        args: [username, password],
      ));
    }
  }
}
