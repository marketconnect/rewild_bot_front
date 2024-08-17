import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/.env.dart';

class ResourceChangeNotifier extends ChangeNotifier {
  final BuildContext context;

  late final Size _screenSize = MediaQuery.of(context).size;
  double get screenWidth => _screenSize.width;
  double get screenHeight => _screenSize.height;
  ResourceChangeNotifier({
    required this.context,
  });

  bool isConnected = false;

  bool _external = false;
  late bool _loading = true;
  void setLoading(bool value) {
    if (!context.mounted) {
      return;
    }
    _external = true;
    _loading = value;
    notifyListeners();
  }

  bool get loading => _loading;

  void notify() {
    if (context.mounted) {
      if (!_external) {
        _loading = false;
      }
      notifyListeners();
    }
  }

  Future<T?> fetch<T>(Future<Either<RewildError, T>> Function() callBack,
      {bool showError = false, String? message}) async {
    final resource = await callBack();

    return resource.fold((l) {
      // sendMessageToTelegramBot(
      //     TBot.tBotErrorToken, TBot.tBotErrorChatId, l.toString());
      if (l.sendToTg) {
        sendMessageToTelegramBot(
            TBot.tBotErrorToken, TBot.tBotErrorChatId, l.toString());
      }
      if (context.mounted && showError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message ?? l.message!),
        ));
      }
      return null;
    }, (r) => r);
  }
}
