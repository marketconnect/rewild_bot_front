// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:rewild_bot_front/domain/entities/size_model.dart';

class StocksModel {
  final int wh;
  final int nmId;
  final int sizeOptionId;
  String? name;
  int qty;

  final List<SizeModel> sizes;
  StocksModel({
    required this.wh,
    required this.nmId,
    required this.sizeOptionId,
    this.sizes = const [],
    this.name,
    required this.qty,
  });

  StocksModel copyWith({
    int? wh,
    String? name,
    int? sizeOptionId,
    int? qty,
  }) {
    return StocksModel(
      nmId: nmId,
      wh: wh ?? this.wh,
      name: name ?? this.name,
      sizeOptionId: sizeOptionId ?? this.sizeOptionId,
      qty: qty ?? this.qty,
    );
  }

  String get nmIdWhSizeOptionId => '${nmId}_${wh}_$sizeOptionId';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nmId': nmId,
      'wh': wh,
      'name': name,
      'qty': qty,
      "nmIdWhSizeOptionId": nmIdWhSizeOptionId,
      'sizeOptionId': sizeOptionId,
    };
  }

  factory StocksModel.fromMap(Map<String, dynamic> map) {
    return StocksModel(
      nmId: map['nmId'] as int,
      wh: map['wh'] as int,
      sizeOptionId: map['sizeOptionId'] as int,
      name: map['name'] != null ? map['name'] as String : null,
      qty: map['qty'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory StocksModel.fromJson(String source) =>
      StocksModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StocksModel( wh: $wh, nmId: $nmId, sizeOptionId: $sizeOptionId, name: $name, qty: $qty, sizes: $sizes)';
  }

  @override
  bool operator ==(covariant StocksModel other) {
    if (identical(this, other)) return true;

    return other.wh == wh &&
        other.name == name &&
        other.qty == qty &&
        other.sizeOptionId == sizeOptionId;
  }

  @override
  int get hashCode {
    return wh.hashCode ^ name.hashCode ^ qty.hashCode ^ sizeOptionId.hashCode;
  }
}
