// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';

class GroupModel {
  int id;
  final String name;
  final int bgColor;
  final int fontColor;
  final List<int> cardsNmIds;
  List<CardOfProductModel> cards;
  void setCards(List<CardOfProductModel> cards) {
    this.cards = cards;
  }

  Map<int, int> stocksSum = {};
  void calculateStocksSum() {
    for (final card in cards) {
      for (final size in card.sizes) {
        for (final stock in size.stocks) {
          if (!stocksSum.containsKey(card.nmId)) {
            stocksSum[card.nmId] = stock.qty;
          } else {
            stocksSum[card.nmId] = stocksSum[card.nmId]! + stock.qty;
          }
        }
      }
    }
  }

  Map<int, int> initialStocksSum = {};
  void calculateInitialStocksSum(DateTime dateFrom, DateTime dateTo) {
    for (final card in cards) {
      for (final initialStock in card.initialStocks) {
        if (initialStock.date.isAfter(dateFrom) &&
            initialStock.date.isBefore(dateTo)) {
          if (!initialStocksSum.containsKey(card.nmId)) {
            initialStocksSum[card.nmId] = initialStock.qty;
          } else {
            initialStocksSum[card.nmId] =
                initialStocksSum[card.nmId]! + initialStock.qty;
          }
        }
      }
    }
  }

  int ordersSum = 0;
  void setOrdersSum(int value) {
    ordersSum = value;
  }

  void calculateOrdersSum() {
    for (final k in initialStocksSum.keys) {
      if (initialStocksSum[k]! > stocksSum[k]!) {
        ordersSum += initialStocksSum[k]! - stocksSum[k]!;
      }
    }
  }

  GroupModel(
      {this.id = 0,
      required this.name,
      required this.bgColor,
      required this.cardsNmIds,
      this.cards = const [],
      required this.fontColor});

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
        id: map['id'] as int,
        name: map['name'] as String,
        bgColor: map['bgColor'] as int,
        cardsNmIds: map['cardsNmIds'] as List<int>,
        fontColor: map['fontColor'] as int);
  }

  @override
  String toString() {
    return 'GroupModel(id: $id, name: $name, bgColor: $bgColor, fontColor: $fontColor, cardsNmIds: $cardsNmIds, cards: $cards, ordersSum: $ordersSum)';
  }
}
