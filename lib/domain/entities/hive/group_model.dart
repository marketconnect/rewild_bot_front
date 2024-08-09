import 'package:hive/hive.dart';
import 'card_of_product.dart';

part 'group_model.g.dart';

@HiveType(typeId: 1)
class GroupModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int bgColor;

  @HiveField(3)
  final int fontColor;

  @HiveField(4)
  final List<int> cardsNmIds;

  @HiveField(5)
  List<CardOfProduct> cards;

  @HiveField(6)
  Map<int, int> stocksSum = {};

  @HiveField(7)
  Map<int, int> initialStocksSum = {};

  @HiveField(8)
  int ordersSum = 0;

  GroupModel({
    this.id = 0,
    required this.name,
    required this.bgColor,
    required this.cardsNmIds,
    this.cards = const [],
    required this.fontColor,
  });

  void setCards(List<CardOfProduct> cards) {
    this.cards = cards;
  }

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

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] as int,
      name: map['name'] as String,
      bgColor: map['bgColor'] as int,
      cardsNmIds: List<int>.from(map['cardsNmIds']),
      fontColor: map['fontColor'] as int,
    );
  }

// copyWith
  GroupModel copyWith({
    int? id,
    String? name,
    int? bgColor,
    List<int>? cardsNmIds,
    List<CardOfProduct>? cards,
    int? fontColor,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bgColor: bgColor ?? this.bgColor,
      cardsNmIds: cardsNmIds ?? this.cardsNmIds,
      cards: cards ?? this.cards,
      fontColor: fontColor ?? this.fontColor,
    );
  }

  @override
  String toString() {
    return 'GroupModel(id: $id, name: $name, bgColor: $bgColor, fontColor: $fontColor, cardsNmIds: $cardsNmIds, cards: $cards, ordersSum: $ordersSum)';
  }
}
