// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class InitialStockModel {
  final int id;

  final DateTime date;
  final int nmId;
  final int wh;
  final int sizeOptionId;
  final String? name;
  final int qty;

  InitialStockModel({
    this.id = 0,
    required this.date,
    required this.nmId,
    required this.wh,
    required this.sizeOptionId,
    this.name,
    required this.qty,
  });

  InitialStockModel copyWith({
    int? id,
    DateTime? date,
    int? nmId,
    int? wh,
    int? sizeOptionId,
    String? name,
    int? qty,
  }) {
    return InitialStockModel(
      id: id ?? this.id,
      date: date ?? this.date,
      nmId: nmId ?? this.nmId,
      wh: wh ?? this.wh,
      sizeOptionId: sizeOptionId ?? this.sizeOptionId,
      name: name ?? this.name,
      qty: qty ?? this.qty,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'nmId': nmId,
      'wh': wh,
      'name': name,
      'qty': qty,
    };
  }

  factory InitialStockModel.fromMap(Map<String, dynamic> map) {
    return InitialStockModel(
      id: map['id'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      nmId: map['nmId'] as int,
      sizeOptionId: map['sizeOptionId'] as int,
      wh: map['wh'] as int,
      name: map['name'] != null ? map['name'] as String : null,
      qty: map['qty'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory InitialStockModel.fromJson(String source) =>
      InitialStockModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'InitialStockModel(id: $id, date: $date, nmId: $nmId, wh: $wh, sizeOptionId: $sizeOptionId, name: $name, qty: $qty)';
  }

  @override
  bool operator ==(covariant InitialStockModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.date == date &&
        other.nmId == nmId &&
        other.wh == wh &&
        other.sizeOptionId == sizeOptionId &&
        other.name == name &&
        other.qty == qty;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        nmId.hashCode ^
        sizeOptionId.hashCode ^
        wh.hashCode ^
        name.hashCode ^
        qty.hashCode;
  }
}
