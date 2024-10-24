import 'package:flutter/material.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/core/utils/telegram_web_apps_api.dart';
import 'package:rewild_bot_front/env.dart';

class RewildError {
  final List<dynamic>? args;
  final String? message;
  final String? source;
  final String? error;
  final String name;
  final String? stackTrace;
  final bool sendToTg;

  RewildError(this.message,
      {required this.name,
      required this.sendToTg,
      this.args,
      this.source,
      this.error,
      this.stackTrace}) {
    debugPrint(toString());
    if (sendToTg) {
      _asyncError();
    }
  }

  _asyncError() async {
    String chatId = await TelegramWebApp.getChatId();
    sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
        'ChatId: $chatId Error: $message\nSource: $source\nName: $name\nError: $error\nArgs: $args\nStackTrace: $stackTrace');
  }

  @override
  String toString() {
    return 'RewildError: $message\nSource: $source\nName: $name\nError: $error\nArgs: $args\nStackTrace: $stackTrace';
  }
}
