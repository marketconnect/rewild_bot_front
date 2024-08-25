// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:rewild_bot_front/.env.dart';

import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/di/di.dart';

import 'dart:js' as js;

abstract class AppFactory {
  Widget makeApp();
}

final appFactory = makeAppFactory();

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    await sendMessageToTelegramBot(
        TBot.tBotErrorToken, TBot.tBotErrorChatId, details.toString());
    FlutterError.presentError(details);
  };

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    setUrlStrategy(PathUrlStrategy());
    final dbHelper = DatabaseHelper();

    // Дождитесь полной инициализации базы данных
    // await sendMessageToTelegramBot(
    //     TBot.tBotErrorToken, TBot.tBotErrorChatId, "started");
    await dbHelper.database;
    // await sendMessageToTelegramBot(
    //     TBot.tBotErrorToken, TBot.tBotErrorChatId, "finished");

    runApp(appFactory.makeApp());
  }, (Object error, StackTrace stack) async {
    await sendMessageToTelegramBot(
        TBot.tBotErrorToken, TBot.tBotErrorChatId, '$error\n$stack');
  });
}

void interceptConsoleErrors() {
  final originalConsoleError = js.context['console']['error'];

  js.context['console']['error'] =
      js.allowInterop((message, [source, lineno, colno, error]) {
    final logMessage = 'Console Error: $message at $source:$lineno:$colno';
    sendMessageToTelegramBot(
        TBot.tBotErrorToken, TBot.tBotErrorChatId, logMessage);

    originalConsoleError
        .apply(js.context['console'], [message, source, lineno, colno, error]);
  });
}
