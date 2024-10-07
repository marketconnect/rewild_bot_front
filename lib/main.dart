// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:convert'; // Для декодирования JSON
import 'dart:html'; // Для доступа к window.location

import 'package:rewild_bot_front/core/utils/telegram_web_apps_api.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:intl/date_symbol_data_local.dart';

// import 'package:rewild_bot_front/core/utils/database_helper.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/di/di.dart';

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

Future<String?> getChatId() async {
  await Future.delayed(const Duration(milliseconds: 100));

  String? initData;
  if (js.context['Telegram'] != null &&
      js.context['Telegram']['WebApp'] != null &&
      js.context['Telegram']['WebApp']['initData'] != null) {
    initData = js.context['Telegram']['WebApp']['initData'] as String?;
  }

  if (initData == null || initData.isEmpty) {
    initData = window.location.href.split('?').length > 1
        ? window.location.href.split('?')[1]
        : '';
  }

  if (initData.isEmpty) {
    return null;
  }

  try {
    final params = Uri.splitQueryString(initData);

    if (params.containsKey('user')) {
      final userJson = params['user'];
      if (userJson != null) {
        final userMap = json.decode(userJson);
        if (userMap is Map && userMap.containsKey('id')) {
          return userMap['id'].toString();
        }
      }
    }

    if (params.containsKey('chat')) {
      final chatJson = params['chat'];
      if (chatJson != null) {
        final chatMap = json.decode(chatJson);
        if (chatMap is Map && chatMap.containsKey('id')) {
          return chatMap['id'].toString();
        }
      }
    }

    return null;
  } catch (e) {
    return null;
  }
}
