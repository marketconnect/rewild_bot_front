class PaymentInfo {
  final int amount;
  final String description;
  // final List<CardOfProductModel> cards;
  final String subscriptionType;

  final DateTime endDate;
  final bool onlyBalance;
  const PaymentInfo({
    required this.amount,
    required this.description,
    required this.subscriptionType,
    required this.endDate,
    this.onlyBalance = false,
  });

  factory PaymentInfo.empty() {
    return PaymentInfo(
      amount: 0,
      description: "",
      subscriptionType: "",
      endDate: DateTime.now(),
    );
  }
}
