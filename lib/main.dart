// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:rewild_bot_front/core/utils/telegram_web_apps_api.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:intl/date_symbol_data_local.dart';

// import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/di/di.dart';

import 'dart:js' as js;

import 'package:rewild_bot_front/env.dart';

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
  await initializeDateFormatting('ru', null);

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    setUrlStrategy(PathUrlStrategy());
    // final dbHelper = DatabaseHelper();

    // await dbHelper.database;
    // await dbHelper.clearTable('card_keywords');
    TelegramWebApp.setTelegramHeaderColor("#fef7ff");
    TelegramWebApp.expandTelegramWebApp();
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
