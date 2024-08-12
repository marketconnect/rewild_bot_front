class Prices {
  int price1;
  int price2;
  int price3;
  int averageLogistics;
  int logisticsCoef;
  int gigaChatLitePerMillion;
  int gigaChatLitePlusPerMillion;
  int gigaChatProPerMillion;
  String clienId;
  String clientSecret;
  Prices({
    required this.price1,
    required this.price2,
    required this.price3,
    required this.averageLogistics,
    required this.logisticsCoef,
    required this.gigaChatLitePerMillion,
    required this.gigaChatLitePlusPerMillion,
    required this.gigaChatProPerMillion,
    required this.clienId,
    required this.clientSecret,
  });

  // fromMap
  factory Prices.fromMap(Map<String, dynamic> map) {
    return Prices(
      price1: map['price1'] as int,
      price2: map['price2'] as int,
      price3: map['price3'] as int,
      averageLogistics: map['averageLogistics'] as int,
      logisticsCoef: map['logisticsCoef'] as int,
      gigaChatLitePerMillion: map['gigaChatLitePerMillion'] as int,
      gigaChatLitePlusPerMillion: map['gigaChatLitePlusPerMillion'] as int,
      gigaChatProPerMillion: map['gigaChatProPerMillion'] as int,
      clienId: map['clienId'] as String,
      clientSecret: map['clientSecret'] as String,
    );
  }
}
