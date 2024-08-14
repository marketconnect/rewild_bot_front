// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SupplyModel {
  final int wh;
  final int nmId;
  final int sizeOptionId;
  final int qty;
  final int lastStocks;

  SupplyModel({
    required this.wh,
    required this.nmId,
    required this.sizeOptionId,
    required this.qty,
    required this.lastStocks,
  });

  SupplyModel copyWith({
    int? wh,
    int? nmId,
    int? qty,
    DateTime? date,
    int? sizeOptionId,
    int? lastStocks,
  }) {
    return SupplyModel(
      wh: wh ?? this.wh,
      nmId: nmId ?? this.nmId,
      sizeOptionId: sizeOptionId ?? this.sizeOptionId,
      qty: qty ?? this.qty,
      lastStocks: lastStocks ?? this.lastStocks,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'wh': wh,
      'nmId': nmId,
      'sizeOptionId': sizeOptionId,
      'lastStocks': lastStocks,
      'qty': qty,
    };
  }

  factory SupplyModel.fromMap(Map<String, dynamic> map) {
    // print(map);
    return SupplyModel(
      wh: map['wh'] as int,
      nmId: map['nmId'] as int,
      sizeOptionId: map['sizeOptionId'] as int,
      lastStocks: map['lastStocks'] as int,
      qty: map['qty'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory SupplyModel.fromJson(String source) =>
      SupplyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SupplyModel(wh: $wh, nmId: $nmId, sizeOptionId: $sizeOptionId, qty: $qty, lastStocks: $lastStocks)';
  }

  @override
  bool operator ==(covariant SupplyModel other) {
    if (identical(this, other)) return true;

    return other.wh == wh &&
        other.nmId == nmId &&
        other.qty == qty &&
        other.lastStocks == lastStocks &&
        other.sizeOptionId == sizeOptionId;
  }

  @override
  int get hashCode =>
      wh.hashCode ^
      nmId.hashCode ^
      sizeOptionId.hashCode ^
      qty.hashCode ^
      lastStocks.hashCode;
}
