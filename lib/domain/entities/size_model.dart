// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:rewild_bot_front/domain/entities/stocks_model.dart';

class SizeModel {
  int optionId;
  List<StocksModel> stocks;

  SizeModel({
    this.optionId = 0,
    required this.stocks,
  });

  @override
  String toString() => 'SizeModel(optionId: $optionId, stocks: $stocks)';
}
