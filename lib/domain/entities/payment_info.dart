import 'package:rewild_bot_front/domain/entities/card_of_product_model.dart';

class PaymentInfo {
  final int amount;
  final String description;
  final List<CardOfProductModel> cards;
  final DateTime endDate;
  final bool onlyBalance;
  const PaymentInfo({
    required this.amount,
    required this.description,
    required this.cards,
    required this.endDate,
    this.onlyBalance = false,
  });

  factory PaymentInfo.empty() {
    return PaymentInfo(
      amount: 0,
      description: "",
      cards: [],
      endDate: DateTime.now(),
    );
  }
}
