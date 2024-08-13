import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';
import 'package:rewild_bot_front/domain/entities/hive/card_of_product.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CardOfProductApiClient
    implements
        UpdateServiceCardOfProductApiClient,
        CardOfProductServiceCardOfProductApiClient {
  const CardOfProductApiClient();

  @override
  Future<Either<RewildError, void>> save({
    required String token,
    required List<CardOfProduct> productCards,
  }) async {
    try {
      final url = Uri.parse('https://rewild.website/api/productCardsAdd');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'productsCards': productCards
            .map((c) => {'nmId': c.nmId, 'name': c.name, 'img': c.img})
            .toList(),
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return right(null);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при сохранении карточек: ${response.statusCode}",
          source: runtimeType.toString(),
          name: "save",
          args: [productCards],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "save",
        args: [productCards],
      ));
    }
  }

  @override
  Future<Either<RewildError, List<CardOfProduct>>> getAll({
    required String token,
  }) async {
    try {
      final url = Uri.parse('https://rewild.website/api/productCardsGet');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final productCards = responseData.map((c) {
          return CardOfProduct(
            nmId: c['nmId'],
            name: c['name'],
            img: c['img'],
          );
        }).toList();

        return right(productCards);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении карточек: ${response.statusCode}",
          source: runtimeType.toString(),
          name: "getAll",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "getAll",
        args: [],
      ));
    }
  }

  @override
  Future<Either<RewildError, void>> delete({
    required String token,
    required int id,
  }) async {
    try {
      final url = Uri.parse('https://rewild.website/api/productCardsDelete');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'nmId': id,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return right(null);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при удалении карточки: ${response.statusCode}",
          source: runtimeType.toString(),
          name: "delete",
          args: [id],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: runtimeType.toString(),
        name: "delete",
        args: [id],
      ));
    }
  }
}
