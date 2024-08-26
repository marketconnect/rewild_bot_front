// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TariffModel {
  final double deliveryLiter;
  final double storageBase;
  final double deliveryBase;
  final double storageLiter;
  final int warehouseId;
  final String warehouseType;
  const TariffModel({
    required this.deliveryLiter,
    required this.storageBase,
    required this.deliveryBase,
    required this.storageLiter,
    required this.warehouseId,
    required this.warehouseType,
  });

  String get whIdwhType => '${warehouseId}_$warehouseType';

  bool isBoxes() {
    return warehouseType == 'b';
  }

  bool isMono() {
    return warehouseType == 'p';
  }

  TariffModel copyWith({
    double? deliveryLiter,
    double? storageBase,
    double? deliveryBase,
    double? storageLiter,
    int? warehouseId,
    String? warehouseType,
  }) {
    return TariffModel(
      deliveryLiter: deliveryLiter ?? this.deliveryLiter,
      storageBase: storageBase ?? this.storageBase,
      deliveryBase: deliveryBase ?? this.deliveryBase,
      storageLiter: storageLiter ?? this.storageLiter,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseType: warehouseType ?? this.warehouseType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'deliveryLiter': deliveryLiter,
      'storageBase': storageBase,
      'deliveryBase': deliveryBase,
      'storageLiter': storageLiter,
      'warehouseId': warehouseId,
      'warehouseType': warehouseType,
      'whIdwhType': whIdwhType
    };
  }

  factory TariffModel.fromMap(Map<String, dynamic> map) {
    return TariffModel(
      deliveryLiter: map['deliveryLiter'] as double,
      storageBase: map['storageBase'] as double,
      deliveryBase: map['deliveryBase'] as double,
      storageLiter: map['storageLiter'] as double,
      warehouseId: map['warehouseId'] as int,
      warehouseType: map['warehouseType'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TariffModel.fromJson(String source) =>
      TariffModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TariffModel(deliveryLiter: $deliveryLiter, storageBase: $storageBase, deliveryBase: $deliveryBase, storageLiter: $storageLiter, warehouseId: $warehouseId, warehouseType: $warehouseType)';
  }

  @override
  bool operator ==(covariant TariffModel other) {
    if (identical(this, other)) return true;

    return other.deliveryLiter == deliveryLiter &&
        other.storageBase == storageBase &&
        other.deliveryBase == deliveryBase &&
        other.storageLiter == storageLiter &&
        other.warehouseId == warehouseId &&
        other.warehouseType == warehouseType;
  }

  @override
  int get hashCode {
    return deliveryLiter.hashCode ^
        storageBase.hashCode ^
        deliveryBase.hashCode ^
        storageLiter.hashCode ^
        warehouseId.hashCode ^
        warehouseType.hashCode;
  }
}
