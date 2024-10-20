import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/core/utils/telegram_web_apps_api.dart';
import 'package:rewild_bot_front/env.dart';

class ResourceChangeNotifier extends ChangeNotifier {
  final BuildContext context;

  late final Size _screenSize = MediaQuery.of(context).size;
  double get screenWidth => _screenSize.width;
  double get screenHeight => _screenSize.height;
  ResourceChangeNotifier({
    required this.context,
  });

  void notify() {
    if (context.mounted) {
      notifyListeners();
    }
  }

  Future<T?> fetch<T>(
    Future<Either<RewildError, T>> Function() callBack, {
    bool showError = false,
    String? message,
    //
    // String? note
  }) async {
    // Stopwatch? stopwatch;

    // if (note != null) {
    //   stopwatch = Stopwatch()..start();
    // }

    final resource = await callBack();

    // if (stopwatch != null) {
    //   stopwatch.stop();
    //   final timeElapsed = stopwatch.elapsed.inSeconds;
    //   print('Time elapsed ($note): $timeElapsed seconds.');
    // }

    return resource.fold((l) async {
      String chatId = await TelegramWebApp.getChatId();
      if (l.sendToTg) {
        sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
            '$chatId ${l.toString()}');
      }
      if (context.mounted && showError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message ?? l.message!),
        ));
      }
      return null;
    }, (r) {
      return r;
    });
  }
}
