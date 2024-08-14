// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  Prices copyWith({
    int? price1,
    int? price2,
    int? price3,
    int? averageLogistics,
    int? logisticsCoef,
    int? gigaChatLitePerMillion,
    int? gigaChatLitePlusPerMillion,
    int? gigaChatProPerMillion,
    String? clienId,
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
      clienId: clienId ?? this.clienId,
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
      'clienId': clienId,
      'clientSecret': clientSecret,
    };
  }

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

  String toJson() => json.encode(toMap());

  factory Prices.fromJson(String source) =>
      Prices.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Prices(price1: $price1, price2: $price2, price3: $price3, averageLogistics: $averageLogistics, logisticsCoef: $logisticsCoef, gigaChatLitePerMillion: $gigaChatLitePerMillion, gigaChatLitePlusPerMillion: $gigaChatLitePlusPerMillion, gigaChatProPerMillion: $gigaChatProPerMillion, clienId: $clienId, clientSecret: $clientSecret)';
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
        other.clienId == clienId &&
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
        clienId.hashCode ^
        clientSecret.hashCode;
  }
}
