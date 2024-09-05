import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/constants/subsciption_constants.dart';

import 'package:rewild_bot_front/core/utils/resource_change_notifier.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';

import 'package:rewild_bot_front/domain/entities/subscription_api_models.dart';

import 'package:rewild_bot_front/env.dart';

enum PaymentResult {
  success,
  refused,
  error,
  cardsIdsIsEmpty,
  getSubscriptionError,
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
  Future<Either<RewildError, SubscriptionV2Response?>> getSubscriptionLocal();
  Future<Either<RewildError, SubscriptionV2Response>> updateSubscription({
    required String token,
    required int subscriptionID,
    required String subscriptionType,
    required String startDate,
    required String endDate,
  });
}

// update
// abstract class PaymentWebViewUpdateService {
//   Future<Either<RewildError, void>> putOnServerNewCards(
//       {required String token,
//       required List<CardOfProductModel> cardOfProductsToPutOnServer});
// }

abstract class PaymentWebViewViewModelBalanceService {
  Future<Either<RewildError, void>> addBalance(double amountToAdd);
}

class PaymentWebViewModel extends ResourceChangeNotifier {
  PaymentWebViewModel({
    required super.context,
    required this.tokenService,
    required this.subService,
    required this.balanceService,
    // required this.updateService,
  }) {
    _asyncInit();
  }

  //
  final PaymentWebViewTokenService tokenService;
  final PaymentWebViewSubscriptionsService subService;
  // final PaymentWebViewUpdateService updateService;
  final PaymentWebViewViewModelBalanceService balanceService;

  late int _subscriptionId;
  late String _subscriptionType;
  late String _token;

  Future<void> _asyncInit() async {
    final values = await Future.wait([
      fetch(() => tokenService.getToken()),
      fetch(() => subService.getSubscriptionLocal())
    ]);

    final token = values[0] as String?;
    final subscription = values[1] as SubscriptionV2Response?;

    if (token == null ||
        subscription == null ||
        subscription.id == 0 ||
        subscription.subscriptionTypeName == '') {
      _sendPaymentInfo(
        'Оплата не прошла! Попробуйте позже. Токен: $token Подписка: ${subscription.toString()}',
        PaymentResult.error,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Оплата не прошла! Попробуйте позже.'),
          ),
        );
        Navigator.of(context).pop(false);
      }

      return;
    }

    _subscriptionId = subscription.id;
    _subscriptionType = subscription.subscriptionTypeName;
    _token = token;
  }

  Future<void> errorCallback(int amount) async {
    int subscriptionId = 0;
    String subscriptionType = '';
    final subscriptionOrNull =
        await fetch(() => subService.getSubscriptionLocal());
    if (subscriptionOrNull != null) {
      subscriptionId = subscriptionOrNull.id;
      subscriptionType = subscriptionOrNull.subscriptionTypeName;
    }
    _sendPaymentInfo(
      'Сумма пополнения: $amount руб. Тип подписки:$subscriptionType id: $subscriptionId',
      PaymentResult.refused,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Оплата не прошла! Попробуйте позже.'),
        ),
      );
    }

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

  Future<void> successCallback(
      {required int amount, required DateTime endDate}) async {
    final today = DateTime.now();
    String formattedToday = DateFormat('yyyy-MM-dd').format(today);
    String formatedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final responseOrNull = await fetch(() => subService.updateSubscription(
          token: _token,
          subscriptionID: _subscriptionId,
          subscriptionType: _subscriptionType,
          startDate: formattedToday,
          endDate: formatedEndDate,
        ));

    if (responseOrNull == null) {
      _sendPaymentInfo(
        'Сумма пополнения: $amount руб. Тип подписки: "$_subscriptionType", дата окончания: $endDate, id: $_subscriptionId',
        PaymentResult.creationSubscriptionError,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Что-то пошло не так, мы уже работаем над этой проблемой. Ваша подписка будет обновлена.'),
        ));
      }
      return;
    }

    _sendPaymentInfo(
      'Сумма пополнения: $amount руб. Тип подписки: "$_subscriptionType", дата окончания: $endDate, id: $_subscriptionId',
      PaymentResult.success,
    );

    // balance
    double sumToAdd =
        getSubscriptionBalance(subscriptionTypeName: _subscriptionType);
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
      case PaymentResult.getSubscriptionError:
        hashtag = "#ошибкаПриПолученииПодписки";
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
