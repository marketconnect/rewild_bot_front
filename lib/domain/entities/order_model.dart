// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:rewild_bot_front/core/utils/rewild_error.dart';

class OrderModel {
  final int sku;
  final int warehouse;
  // final int sizeOption;
  final int qty;
  final int price;
  final String period;
  // final String createdAt;

  OrderModel({
    required this.sku,
    required this.warehouse,
    required this.qty,
    required this.price,
    required this.period,
  });

  OrderModel copyWith({
    int? sku,
    int? warehouse,
    int? qty,
    int? price,
    String? period,
  }) {
    return OrderModel(
      sku: sku ?? this.sku,
      warehouse: warehouse ?? this.warehouse,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      period: period ?? this.period,
    );
  }

  String get skuWarehousePeriod => '${sku}_${warehouse}_$period';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sku': sku,
      'warehouse': warehouse,
      'qty': qty,
      'price': price,
      'period': period,
      'skuWarehousePeriod': skuWarehousePeriod
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    try {
      return OrderModel(
        sku: map['sku'] as int,
        warehouse: map['warehouse'] as int,
        qty: map['qty'] as int,
        price: map['price'] as int,
        period: map['period'] as String,
      );
    } catch (e) {
      throw Exception(RewildError(
        "Failed to parse OrderModel from map: ${e.toString()}",
        name: "OrderModel.fromMap",
        source: "OrderModel",
        args: [map],
        sendToTg: true,
      ));
    }
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderModel(sku: $sku, warehouse: $warehouse, qty: $qty, price: $price, period: $period)';
  }

  @override
  bool operator ==(covariant OrderModel other) {
    if (identical(this, other)) return true;

    return other.sku == sku &&
        other.warehouse == warehouse &&
        other.qty == qty &&
        other.price == price &&
        other.period == period;
  }

  @override
  int get hashCode {
    return sku.hashCode ^
        warehouse.hashCode ^
        qty.hashCode ^
        price.hashCode ^
        period.hashCode;
  }
}
