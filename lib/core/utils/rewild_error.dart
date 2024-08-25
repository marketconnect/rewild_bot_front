import 'package:flutter/material.dart';
import 'package:rewild_bot_front/.env.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';

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
    sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
        "Source: $source -> $name;\n message: $message;\n  err: $error;  $stackTrace $args");
  }
  @override
  String toString() {
    return 'RewildError: $message\nSource: $source\nName: $name\nError: $error\nArgs: $args\nStackTrace: $stackTrace';
  }
}
