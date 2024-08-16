import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/subscription_model.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:rewild_bot_front/domain/services/subscription_service.dart';

class SubscriptionApiClient
    implements SubscriptionServiceSubscriptionApiClient {
  const SubscriptionApiClient();

  @override
  Future<Either<RewildError, List<SubscriptionModel>>> getSubscription({
    required String token,
  }) async {
    final url = Uri.parse("https://rewild.website/api/getSubscriptions");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Handle empty response from server
        if (data.isEmpty) {
          return right([]);
        }

        List<SubscriptionModel> subscriptions = data.map((item) {
          return SubscriptionModel(
            cardId: item['cardId'],
            startDate: item['startDate'],
            endDate: item['endDate'],
            status: item['status'],
          );
        }).toList();

        return right(subscriptions);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении подписок: ${response.statusCode}",
          source: "SubscriptionApiClient",
          name: "getSubscriptions",
          args: [token],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SubscriptionApiClient",
        name: "getSubscriptions",
        args: [token],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubscriptionModel>>> addZeroSubscriptions({
    required String token,
    required int qty,
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse("https://rewild.website/api/addZeroSubscriptions");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'qty': qty,
          'startDate': startDate,
          'endDate': endDate,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<SubscriptionModel> subscriptions = data.map((item) {
          return SubscriptionModel(
            cardId: item['cardId'],
            startDate: item['startDate'],
            endDate: item['endDate'],
            status: item['status'],
          );
        }).toList();

        return right(subscriptions);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при добавлении подписок: ${response.statusCode}",
          source: "SubscriptionApiClient",
          name: "addZeroSubscriptions",
          args: [qty, startDate, endDate],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SubscriptionApiClient",
        name: "addZeroSubscriptions",
        args: [qty, startDate, endDate],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubscriptionModel>>> createSubscriptions({
    required String token,
    required List<int> cardIds,
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse("https://rewild.website/api/createSubscriptions");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cardIds': cardIds,
          'startDate': startDate,
          'endDate': endDate,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<SubscriptionModel> subscriptions = data.map((item) {
          return SubscriptionModel(
            cardId: item['cardId'],
            startDate: item['startDate'],
            endDate: item['endDate'],
            status: item['status'],
          );
        }).toList();

        return right(subscriptions);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при создании подписок: ${response.statusCode}",
          source: "SubscriptionApiClient",
          name: "createSubscriptions",
          args: [cardIds, startDate, endDate],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SubscriptionApiClient",
        name: "createSubscriptions",
        args: [cardIds, startDate, endDate],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubscriptionModel>>> clearSubscriptions({
    required String token,
    required List<int> cardIds,
  }) async {
    final url = Uri.parse("https://rewild.website/api/clearSubscriptions");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cardIds': cardIds,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<SubscriptionModel> subscriptions = data.map((item) {
          return SubscriptionModel(
            cardId: item['cardId'],
            startDate: item['startDate'],
            endDate: item['endDate'],
            status: item['status'],
          );
        }).toList();

        return right(subscriptions);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при очистке подписок: ${response.statusCode}",
          source: "SubscriptionApiClient",
          name: "clearSubscriptions",
          args: [cardIds],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SubscriptionApiClient",
        name: "clearSubscriptions",
        args: [cardIds],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<SubscriptionModel>>> deleteSubscriptions({
    required String token,
    required List<int> cardIds,
  }) async {
    final url = Uri.parse("https://rewild.website/api/deleteSubscriptions");
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cardIds': cardIds,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<SubscriptionModel> subscriptions = data.map((item) {
          return SubscriptionModel(
            cardId: item['cardId'],
            startDate: item['startDate'],
            endDate: item['endDate'],
            status: item['status'],
          );
        }).toList();

        return right(subscriptions);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при удалении подписок: ${response.statusCode}",
          source: "SubscriptionApiClient",
          name: "deleteSubscriptions",
          args: [cardIds],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "SubscriptionApiClient",
        name: "deleteSubscriptions",
        args: [cardIds],
      ));
    }
  }
}
