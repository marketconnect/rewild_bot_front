import 'dart:convert';

class Prices {
  int price1;
  int price2;
  int price3;
  int averageLogistics;
  int logisticsCoef;
  int gigaChatLitePerMillion;
  int gigaChatLitePlusPerMillion;
  int gigaChatProPerMillion;
  String clientId; // Corrected typo here
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
    required this.clientId, // Corrected typo here
    required this.clientSecret,
  });

  // Copy with method should also be updated
  Prices copyWith({
    int? price1,
    int? price2,
    int? price3,
    int? averageLogistics,
    int? logisticsCoef,
    int? gigaChatLitePerMillion,
    int? gigaChatLitePlusPerMillion,
    int? gigaChatProPerMillion,
    String? clientId, // Corrected typo here
    String? clientSecret,
  }) {
    return Prices(
      price1: price1 ?? this.price1,
      price2: price2 ?? this.price2,
      price3: price3 ?? this.price3,
      averageLogistics: averageLogistics ?? this.averageLogistics,
      logisticsCoef: logisticsCoef ?? this.logisticsCoef,
      gigaChatLitePerMillion:
          gigaChatLitePerMillion ?? this.gigaChatLitePerMillion,
      gigaChatLitePlusPerMillion:
          gigaChatLitePlusPerMillion ?? this.gigaChatLitePlusPerMillion,
      gigaChatProPerMillion:
          gigaChatProPerMillion ?? this.gigaChatProPerMillion,
      clientId: clientId ?? this.clientId, // Corrected typo here
      clientSecret: clientSecret ?? this.clientSecret,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'price1': price1,
      'price2': price2,
      'price3': price3,
      'averageLogistics': averageLogistics,
      'logisticsCoef': logisticsCoef,
      'gigaChatLitePerMillion': gigaChatLitePerMillion,
      'gigaChatLitePlusPerMillion': gigaChatLitePlusPerMillion,
      'gigaChatProPerMillion': gigaChatProPerMillion,
      'clientId': clientId, // Corrected typo here
      'clientSecret': clientSecret,
    };
  }

  factory Prices.fromMap(Map<String, dynamic> map) {
    return Prices(
      price1: map['price1'] as int? ?? 0,
      price2: map['price2'] as int? ?? 0,
      price3: map['price3'] as int? ?? 0,
      averageLogistics: map['averageLogistics'] as int? ?? 0,
      logisticsCoef: map['logisticsCoef'] as int? ?? 0,
      gigaChatLitePerMillion: map['gigaChatLitePerMillion'] as int? ?? 0,
      gigaChatLitePlusPerMillion:
          map['gigaChatLitePlusPerMillion'] as int? ?? 0,
      gigaChatProPerMillion: map['gigaChatProPerMillion'] as int? ?? 0,
      clientId: map['clientId'] as String? ?? '', // Corrected typo here
      clientSecret: map['clientSecret'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Prices.fromJson(String source) =>
      Prices.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Prices(price1: $price1, price2: $price2, price3: $price3, averageLogistics: $averageLogistics, logisticsCoef: $logisticsCoef, gigaChatLitePerMillion: $gigaChatLitePerMillion, gigaChatLitePlusPerMillion: $gigaChatLitePlusPerMillion, gigaChatProPerMillion: $gigaChatProPerMillion, clientId: $clientId, clientSecret: $clientSecret)'; // Corrected typo here
  }

  @override
  bool operator ==(covariant Prices other) {
    if (identical(this, other)) return true;

    return other.price1 == price1 &&
        other.price2 == price2 &&
        other.price3 == price3 &&
        other.averageLogistics == averageLogistics &&
        other.logisticsCoef == logisticsCoef &&
        other.gigaChatLitePerMillion == gigaChatLitePerMillion &&
        other.gigaChatLitePlusPerMillion == gigaChatLitePlusPerMillion &&
        other.gigaChatProPerMillion == gigaChatProPerMillion &&
        other.clientId == clientId && // Corrected typo here
        other.clientSecret == clientSecret;
  }

  @override
  int get hashCode {
    return price1.hashCode ^
        price2.hashCode ^
        price3.hashCode ^
        averageLogistics.hashCode ^
        logisticsCoef.hashCode ^
        gigaChatLitePerMillion.hashCode ^
        gigaChatLitePlusPerMillion.hashCode ^
        gigaChatProPerMillion.hashCode ^
        clientId.hashCode ^ // Corrected typo here
        clientSecret.hashCode;
  }
}
