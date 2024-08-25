// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class InitialStockModel {
  final DateTime date;
  final int nmId;
  final int wh;
  final int sizeOptionId;

  final int qty;

  InitialStockModel({
    required this.date,
    required this.nmId,
    required this.wh,
    required this.sizeOptionId,
    required this.qty,
  });

  InitialStockModel copyWith({
    DateTime? date,
    int? nmId,
    int? wh,
    int? sizeOptionId,
    int? qty,
  }) {
    return InitialStockModel(
      date: date ?? this.date,
      nmId: nmId ?? this.nmId,
      wh: wh ?? this.wh,
      sizeOptionId: sizeOptionId ?? this.sizeOptionId,
      qty: qty ?? this.qty,
    );
  }

  String get nmIdWhSizeOptionId => '${nmId}_${wh}_$sizeOptionId';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date.millisecondsSinceEpoch,
      'nmId': nmId,
      'sizeOptionId': sizeOptionId,
      'wh': wh,
      'qty': qty,
      'nmIdWhSizeOptionId': nmIdWhSizeOptionId
    };
  }

  factory InitialStockModel.fromMap(Map<String, dynamic> map) {
    return InitialStockModel(
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      nmId: map['nmId'] != null ? map['nmId'] as int : 0,
      sizeOptionId:
          map['sizeOptionId'] != null ? map['sizeOptionId'] as int : 0,
      wh: map['wh'] != null ? map['wh'] as int : 0,
      qty: map['qty'] != null ? map['qty'] as int : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory InitialStockModel.fromJson(String source) =>
      InitialStockModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'InitialStockModel( date: $date, nmId: $nmId, wh: $wh, sizeOptionId: $sizeOptionId,  qty: $qty)';
  }

  @override
  bool operator ==(covariant InitialStockModel other) {
    if (identical(this, other)) return true;

    return other.date == date &&
        other.nmId == nmId &&
        other.wh == wh &&
        other.sizeOptionId == sizeOptionId &&
        other.qty == qty;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        nmId.hashCode ^
        sizeOptionId.hashCode ^
        wh.hashCode ^
        qty.hashCode;
  }
}
