import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';
import 'package:rewild_bot_front/domain/services/card_of_product_service.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class CardOfProductApiClient
    implements
        UpdateServiceCardOfProductApiClient,
        CardOfProductServiceCardOfProductApiClient {
  const CardOfProductApiClient();

  // @override
  // Future<Either<RewildError, void>> save({
  //   required String token,
  //   required List<CardOfProductModel> productCards,
  // }) async {
  //   try {
  //     final url = Uri.parse('https://rewild.website/api/productCardsAdd');
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     };

  //     final body = jsonEncode({
  //       'productsCards': productCards
  //           .map((c) => {'nmId': c.nmId, 'name': c.name, 'img': c.img})
  //           .toList(),
  //     });

  //     final response = await http.post(url, headers: headers, body: body);

  //     if (response.statusCode == 200) {
  //       return right(null);
  //     } else {
  //       return left(RewildError(
  //         sendToTg: true,
  //         "Ошибка при сохранении карточек: ${response.statusCode}",
  //         source: "CardOfProductApiClient",
  //         name: "save",
  //         args: [productCards],
  //       ));
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: true,
  //       "Неизвестная ошибка: $e",
  //       source: "CardOfProductApiClient",
  //       name: "save",
  //       args: [productCards],
  //     ));
  //   }
  // }

  @override
  Future<Either<RewildError, List<CardOfProductModel>>> getAll({
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
        final responseData = jsonDecode(response.body);
        List<CardOfProductModel> cards = [];
        final productCards = responseData['productsCards'] as List<dynamic>;
        for (final c in productCards) {
          cards.add(CardOfProductModel(
            nmId: c['sku'],
            name: c['name'],
            img: c['image'],
          ));
        }

        return right(cards);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при получении карточек: ${response.statusCode}",
          source: "CardOfProductApiClient",
          name: "getAll",
          args: [],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Неизвестная ошибка: $e",
        source: "CardOfProductApiClient",
        name: "getAll",
        args: [],
      ));
    }
  }

  // @override
  // Future<Either<RewildError, void>> delete({
  //   required String token,
  //   required int id,
  // }) async {
  //   try {
  //     final url = Uri.parse('https://rewild.website/api/productCardsDelete');
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     };

  //     final body = jsonEncode({
  //       'nmId': id,
  //     });

  //     final response = await http.post(url, headers: headers, body: body);

  //     if (response.statusCode == 200) {
  //       return right(null);
  //     } else {
  //       return left(RewildError(
  //         sendToTg: true,
  //         "Ошибка при удалении карточки: ${response.statusCode}",
  //         source: "CardOfProductApiClient",
  //         name: "delete",
  //         args: [id],
  //       ));
  //     }
  //   } catch (e) {
  //     return left(RewildError(
  //       sendToTg: true,
  //       "Неизвестная ошибка: $e",
  //       source: "CardOfProductApiClient",
  //       name: "delete",
  //       args: [id],
  //     ));
  //   }
  // }
}
