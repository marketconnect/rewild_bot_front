class WarehouseCoeffs {
  final int warehouseId;
  final int boxTypeId;
  final String boxTypeName;
  final String warehouseName;
  final double coefficient;
  String get whIdBoxTypeId => '${warehouseId}__$boxTypeId';
  WarehouseCoeffs(
      {required this.warehouseId,
      required this.boxTypeId,
      required this.boxTypeName,
      required this.warehouseName,
      required this.coefficient});

  factory WarehouseCoeffs.fromJson(Map<String, dynamic> json) {
    return WarehouseCoeffs(
      warehouseId: json['warehouse_id'],
      boxTypeId: json['box_type_id'],
      boxTypeName: json['box_type_name'],
      warehouseName: json['warehouse_name'],
      coefficient: json['coefficient'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'warehouse_id': warehouseId,
      'box_type_id': boxTypeId,
      'box_type_name': boxTypeName,
      'warehouse_name': warehouseName,
      'coefficient': coefficient,
      'whIdBoxTypeId': whIdBoxTypeId
    };
  }

  @override
  String toString() {
    return 'WarehouseCoeffs(warehouseId: $warehouseId, boxTypeId: $boxTypeId, boxTypeName: $boxTypeName, warehouseName: $warehouseName, coefficient: $coefficient)';
  }
}
