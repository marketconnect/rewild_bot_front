class GetAllWarehousesResp {
  final List<WarehouseCoeffs> warehouses;
  final List<UserSubscription> userSubscriptions;

  GetAllWarehousesResp(
      {required this.warehouses, required this.userSubscriptions});

  factory GetAllWarehousesResp.fromJson(Map<String, dynamic> json) {
    return GetAllWarehousesResp(
      warehouses: (json['warehouses'] as List)
          .map((w) => WarehouseCoeffs.fromJson(w))
          .toList(),
      userSubscriptions: (json['user_subscriptions'] as List?)
              ?.map((w) => UserSubscription.fromJson(w))
              .toList() ??
          [],
    );
  }
}

class WarehouseCoeffs {
  final int warehouseId;
  final String warehouseName;
  List<BoxType> boxTypes;

  WarehouseCoeffs(
      {required this.warehouseId,
      required this.warehouseName,
      required this.boxTypes});

  factory WarehouseCoeffs.fromJson(Map<String, dynamic> json) {
    return WarehouseCoeffs(
      warehouseId: json['warehouse_id'],
      warehouseName: json['warehouse_name'],
      boxTypes: (json['box_types'] as List?)
              ?.map((w) => BoxType.fromJson(w))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'WarehouseCoeffs(warehouseId: $warehouseId, warehouseName: $warehouseName, boxType: $boxTypes)';
  }
}

class BoxType {
  final int boxTypeId;
  final String boxTypeName;
  final double coefficient;
  final String date;

  BoxType(
      {required this.boxTypeId,
      required this.boxTypeName,
      required this.coefficient,
      required this.date});

  factory BoxType.fromJson(Map<String, dynamic> json) {
    return BoxType(
      boxTypeId: json['box_type_id'] ?? 0,
      boxTypeName: json['box_type_name'],
      coefficient: json['coefficient'] ?? 0.0,
      date: json['date'],
    );
  }

  @override
  String toString() {
    return 'BoxType(boxTypeid: $boxTypeId, boxTypeName: $boxTypeName, coefficient: $coefficient, date: $date)';
  }
}

class UserSubscription {
  final int warehouseId;
  final int boxTypeId;
  final double threshold;
  final String warehouseName;
  final String fromDate;
  final String toDate;

  UserSubscription(
      {required this.warehouseId,
      required this.boxTypeId,
      required this.threshold,
      required this.warehouseName,
      required this.fromDate,
      required this.toDate});

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      warehouseId: json['warehouse_id'],
      boxTypeId: json['box_type_id'] ?? 0,
      threshold: json['threshold'],
      warehouseName: json['warehouse_name'],
      fromDate: json['from_date'],
      toDate: json['to_date'],
    );
  }
}
