import 'dart:convert';

import 'package:fpdart/fpdart.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import 'package:rewild_bot_front/core/utils/rewild_error.dart';

import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';

import 'package:rewild_bot_front/domain/entities/size_model.dart';
import 'package:rewild_bot_front/domain/entities/stocks_model.dart';
import 'package:rewild_bot_front/domain/services/update_service.dart';

class DetailsApiClient implements UpdateServiceDetailsApiClient {
  const DetailsApiClient();
  @override
  Future<Either<RewildError, List<CardOfProductModel>>> get(
      {required List<int> ids}) async {
    try {
      final params = {
        'appType': '1',
        'curr': 'rub',
        'dest': '-1257786',
        'regions':
            '80,38,83,4,64,33,68,70,30,40,86,75,69,1,31,66,110,48,22,71,114',
        'nm': ids.join(";")
      };

      // final uri = Uri.parse('https://card.wb.ru/cards/detail')
      //     .replace(queryParameters: params);

      final uri = Uri.parse('https://rewild.website/api/details')
          .replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {
          'Accept': '*/*',
          'Referer': 'https://web.telegram.org',
          'Origin': 'https://web.telegram.org', // Или укажите нужный домен
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'ru-RU,ru;q=0.9',
          'Connection': 'keep-alive',
          'Host': 'card.wb.ru',
          'sec-ch-ua':
              '"Chromium";v="110", "Not A(Brand";v="24", "Google Chrome";v="110"',
          'sec-ch-ua-mobile': '?0',
          'sec-ch-ua-platform': '"Linux"',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'cross-site',
          'User-Agent':
              'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36'
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final productCardsJson = data['data']['products'];
        List<CardOfProductModel> resultProductCardsList = [];
        // Mapping
        for (final json in productCardsJson) {
          // sizes
          List<SizeModel> fetchedSizes = [];
          final sizes = json['sizes'] ?? [];

          for (final size in sizes) {
            // newCardModel.sizes.add();
            List<StocksModel> stocks = [];
            final optionId = size['optionId'] ?? 0;
            if (size['stocks'].isEmpty) {
              stocks.add(StocksModel(
                nmId: json['id'],
                wh: 0,
                sizeOptionId: optionId,
                qty: 0,
                name: '',
              ));
            }

            for (final stock in size['stocks']) {
              final wh = stock['wh'];
              final qty = stock['qty'];
              stocks.add(StocksModel(
                nmId: json['id'],
                wh: wh,
                sizeOptionId: optionId,
                qty: qty,
                name: '',
              ));
            }
            SizeModel sizeModel = SizeModel(
              stocks: stocks,
            );
            fetchedSizes.add(sizeModel);
          }
          // sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
          //     "API ${fetchedSizes.toString()}");
          final basicPrice = json['salePriceU'] ??
              (json['extended'] != null ? json['extended']['basicPriceU'] : 0);

          final reviewRatingRaw = json['reviewRating'] ?? 0;
          final reviewRating = reviewRatingRaw is int
              ? reviewRatingRaw.toDouble()
              : reviewRatingRaw;

          CardOfProductModel newCardModel = CardOfProductModel(
              nmId: json['id'],
              name: json['name'] ?? "",
              sellerId: json['sellerId'] ?? 0,
              tradeMark: json['tradeMark'] ?? "-",
              subjectId: json['subjectId'] ?? 0,
              subjectParentId: json['subjectParentId'] ?? 0,
              brand: json['brand'] ?? "",
              supplierId: json['supplierId'] ?? 0,
              basicPriceU: basicPrice ?? 0,
              pics: json['pics'] ?? 0,
              rating: json['rating'] ?? 0,
              reviewRating: reviewRating,
              feedbacks: json['feedbacks'] ?? 0,
              volume: json['volume'] ?? 0,
              promoTextCard: json['promoTextCard'] ?? "",
              sizes: fetchedSizes);

          resultProductCardsList.add(newCardModel);
        }

        return right(resultProductCardsList);
      } else {
        return left(RewildError(
          sendToTg: true,
          "Ошибка при обращении к WB status code:${response.statusCode}",
          source: "DetailsApiClient",
          name: "get",
          args: [ids],
        ));
      }
    } catch (e) {
      return left(RewildError(
        sendToTg: true,
        "Ошибка при обращении к WB: $e",
        source: "DetailsApiClient",
        name: "get",
        args: [ids],
      ));
    }
  }
}
