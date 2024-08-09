import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

part 'filter_model.g.dart';

@HiveType(typeId: 9) // Уникальный идентификатор для каждого типа Hive
class FilterModel {
  @HiveField(0)
  Map<int, String>? subjects;

  @HiveField(1)
  Map<int, String>? brands;

  @HiveField(2)
  Map<int, String>? suppliers;

  @HiveField(3)
  Map<int, String>? promos;

  @HiveField(4)
  bool? withSales;

  @HiveField(5)
  bool? withStocks;

  FilterModel({
    this.subjects,
    this.brands,
    this.suppliers,
    this.promos,
    this.withSales,
    this.withStocks,
  });

  FilterModel copyWith({
    Map<int, String>? subjects,
    Map<int, String>? brands,
    Map<int, String>? suppliers,
    Map<int, String>? promos,
    bool? withSales,
    bool? withStocks,
  }) {
    return FilterModel(
      subjects: subjects ?? this.subjects,
      brands: brands ?? this.brands,
      suppliers: suppliers ?? this.suppliers,
      promos: promos ?? this.promos,
      withSales: withSales ?? this.withSales,
      withStocks: withStocks ?? this.withStocks,
    );
  }

  factory FilterModel.empty() {
    return FilterModel();
  }

  @override
  String toString() {
    return 'FilterModel(subjects: $subjects, brands: $brands, suppliers: $suppliers, promos: $promos, withSales: $withSales, withStocks: $withStocks)';
  }

  @override
  bool operator ==(covariant FilterModel other) {
    if (identical(this, other)) return true;

    return mapEquals(other.subjects, subjects) &&
        mapEquals(other.brands, brands) &&
        mapEquals(other.suppliers, suppliers) &&
        mapEquals(other.promos, promos);
  }

  @override
  int get hashCode {
    return subjects.hashCode ^
        brands.hashCode ^
        suppliers.hashCode ^
        promos.hashCode;
  }
}
