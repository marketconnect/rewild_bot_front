import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/.env.dart';
import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/entities/subscription_model.dart';

enum PaymentResult {
  success,
  refused,
  error,
  cardsIdsIsEmpty,
  getTokenError,
  creationSubscriptionError,
  putCardsOnServerError,
}

// Token
abstract class PaymentWebViewTokenService {
  Future<Either<RewildError, String>> getToken();
  Future<Either<RewildError, String?>> getUsername();
}

// Subscriptions
abstract class PaymentWebViewSubscriptionsService {
  Future<Either<RewildError, List<SubscriptionModel>>> addZeroSubscriptions({
    required String token,
    required int qty,
    required String startDate,
    required String endDate,
  });
  Future<Either<RewildError, List<SubscriptionModel>>> createSubscriptions({
    required String token,
    required List<int> cardIds,
    required String startDate,
    required String endDate,
  });
}

// update
abstract class PaymentWebViewUpdateService {
  Future<Either<RewildError, void>> putOnServerNewCards(
      {required String token,
      required List<CardOfProductModel> cardOfProductsToPutOnServer});
}

abstract class PaymentWebViewViewModelBalanceService {
  Future<Either<RewildError, void>> addBalance(double amountToAdd);
}

class PaymentWebViewModel extends ResourceChangeNotifier {
  final PaymentWebViewTokenService tokenService;
  final PaymentWebViewSubscriptionsService subService;
  final PaymentWebViewUpdateService updateService;
  final PaymentWebViewViewModelBalanceService balanceService;

  PaymentWebViewModel({
    required super.context,
    required this.tokenService,
    required this.subService,
    required this.balanceService,
    required this.updateService,
  });

  Future<void> errorCallback(
      int amount, List<CardOfProductModel> cardModels) async {
    final cardsIds = cardModels.map((e) => e.nmId).toList().join(',');
    _sendPaymentInfo(
      'Сумма пополнения: $amount руб. [$cardsIds]',
      PaymentResult.refused,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Оплата не прошла! Попробуйте позже.'),
      ),
    );

    await Future.delayed(const Duration(seconds: 3), () {});
    if (context.mounted) {
      Navigator.of(context).pop(false);
    }
  }

  Future<void> balanceSuccess({required double amount}) async {
    await fetch(() => balanceService.addBalance(amount));
    _sendPaymentInfo(
      'Пополнение баланса: $amount руб. ',
      PaymentResult.cardsIdsIsEmpty,
    );

    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  //
  Future<void> successCallback(
      {required int amount,
      required List<CardOfProductModel> cardModels,
      required DateTime endDate}) async {
    final cardsIds = cardModels.map((e) => e.nmId).toList().join(',');

    if (cardsIds.isEmpty) {
      _sendPaymentInfo(
        'Сумма пополнения: $amount руб. [$cardsIds]',
        PaymentResult.cardsIdsIsEmpty,
      );
      return;
    }
    // prepare date
    DateTime today = DateTime.now();
    // DateTime endDate = DateTime(today.year, today.month + 1, today.day);
    String formattedToday = DateFormat('yyyy-MM-dd').format(today);
    String formatedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    // Token
    final token = await fetch(() => tokenService.getToken());
    if (token == null) {
      _sendPaymentInfo(
        'Сумма пополнения: $amount руб. [$cardsIds]',
        PaymentResult.getTokenError,
      );
      return;
    }
    // get zero subs
    final zeroSubs = cardModels.where((element) => element.nmId == 0);
    // get non zero subs
    // Add subscriptions on a server and local storage with the _syncSubscriptions
    // inside the subService createSubscriptions
    if (zeroSubs.isNotEmpty) {
      final subsResult = await fetch(() => subService.addZeroSubscriptions(
            token: token,
            qty: zeroSubs.length,
            startDate: formattedToday,
            endDate: formatedEndDate,
          ));

      if (subsResult == null) {
        _sendPaymentInfo(
          'Сумма пополнения: $amount руб. [$cardsIds]',
          PaymentResult.creationSubscriptionError,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Что-то пошло не так, пожалуйста, попробуйте позже!'),
          ));
        }
        return;
      }
    }

    // get non zero subs
    final nonZeroSubs = cardModels.where((element) => element.nmId != 0);

    if (nonZeroSubs.isEmpty) {
      return;
    }

    // Attention that we do not add cards only update subscriptions
    // because if sku is zero it is not neccessary
    // if sku is not zero means that card is already tracked
    final nonZeroSubsResult = await fetch(() => subService.createSubscriptions(
          token: token,
          cardIds: nonZeroSubs.map((e) => e.nmId).toList(),
          startDate: formattedToday,
          endDate: formatedEndDate,
        ));

    if (nonZeroSubsResult == null) {
      _sendPaymentInfo(
        'Сумма пополнения: $amount руб. [$cardsIds]',
        PaymentResult.creationSubscriptionError,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Что-то пошло не так, пожалуйста, попробуйте позже!'),
        ));
      }
      return;
    }

    _sendPaymentInfo(
      'Сумма пополнения: $amount руб. [$cardsIds]',
      PaymentResult.success,
    );

    // balance
    double sumToAdd = cardModels.length == 20
        ? 50
        : cardModels.length == 50
            ? 100
            : 150;
    await fetch(() => balanceService.addBalance(sumToAdd));

    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _sendPaymentInfo(String mes, PaymentResult eventType) async {
    var userName = await fetch(() => tokenService.getUsername());
    userName ??= "anonymous";

    String hashtag;
    switch (eventType) {
      case PaymentResult.success:
        hashtag = "#успешнаяОплата";
        break;
      case PaymentResult.refused:
        hashtag = "#ошибкаОплаты";
        break;
      case PaymentResult.error:
        hashtag = "#ошибкаНаСервере";
        break;
      case PaymentResult.creationSubscriptionError:
        hashtag = "#ошибкаПриСозданииПодпискиНаСервере";
        break;
      case PaymentResult.cardsIdsIsEmpty:
        hashtag = "#пустойСписокКарт";
        break;
      case PaymentResult.getTokenError:
        hashtag = "#пустойТокен";
        break;
      case PaymentResult.putCardsOnServerError:
        hashtag = "#ошибкаПриОтправкеКартНаСервер";
        break;
      default:
        hashtag = "#неопределенноеСобытие";
        break;
    }

    // Формирование сообщения с хэштегом и структурированной информацией
    String message = "$hashtag\nПользователь: $userName\nСобытие: $mes";

    return sendMessageToTelegramBot(
        TBot.tBotPaymentToken, TBot.tBotPaymentChatId, message);
  }
}
