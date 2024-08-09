import 'package:rewild_bot_front/domain/entities/hive/stock.dart';

class SizeModel {
  int optionId;
  List<Stock> stocks;

  SizeModel({
    this.optionId = 0,
    required this.stocks,
  });

  @override
  String toString() => 'SizeModel(optionId: $optionId, stocks: $stocks)';
}
