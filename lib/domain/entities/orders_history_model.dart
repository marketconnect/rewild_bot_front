// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OrdersHistoryModel {
  final int nmId;
  final int qty;
  final bool highBuyout;
  final DateTime updatetAt;

  OrdersHistoryModel({
    required this.nmId,
    required this.qty,
    required this.highBuyout,
    required this.updatetAt,
  });

  factory OrdersHistoryModel.empty() {
    return OrdersHistoryModel(
      nmId: 0,
      qty: 0,
      highBuyout: false,
      updatetAt: DateTime.now(),
    );
  }

  OrdersHistoryModel copyWith({
    int? nmId,
    int? qty,
    bool? highBuyout,
    DateTime? updatetAt,
  }) {
    return OrdersHistoryModel(
      nmId: nmId ?? this.nmId,
      qty: qty ?? this.qty,
      highBuyout: highBuyout ?? this.highBuyout,
      updatetAt: updatetAt ?? this.updatetAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nmId': nmId,
      'qty': qty,
      'highBuyout': highBuyout,
      'updatetAt': updatetAt.millisecondsSinceEpoch,
    };
  }

  factory OrdersHistoryModel.fromMap(Map<String, dynamic> map) {
    final highBuyout = map['highBuyout'] as int;
    return OrdersHistoryModel(
      nmId: map['nmId'] as int,
      qty: map['qty'] as int,
      highBuyout: highBuyout > 0,
      updatetAt: DateTime.fromMillisecondsSinceEpoch(map['updatetAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrdersHistoryModel.fromJson(String source) =>
      OrdersHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrdersHistoryModel(nmId: $nmId, qty: $qty, highBuyout: $highBuyout, updatetAt: $updatetAt)';
  }

  @override
  bool operator ==(covariant OrdersHistoryModel other) {
    if (identical(this, other)) return true;

    return other.nmId == nmId &&
        other.qty == qty &&
        other.highBuyout == highBuyout &&
        other.updatetAt == updatetAt;
  }

  @override
  int get hashCode {
    return nmId.hashCode ^
        qty.hashCode ^
        highBuyout.hashCode ^
        updatetAt.hashCode;
  }
}
