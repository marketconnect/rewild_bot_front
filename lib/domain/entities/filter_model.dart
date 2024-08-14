import 'dart:convert';

import 'package:flutter/foundation.dart';

class FilterModel {
  Map<int, String>? subjects;
  Map<int, String>? brands;
  Map<int, String>? suppliers;
  Map<int, String>? promos;
  bool? withSales;
  bool? withStocks;
  FilterModel(
      {this.subjects,
      this.brands,
      this.suppliers,
      this.promos,
      this.withSales,
      this.withStocks});

  FilterModel copyWith(
      {Map<int, String>? subjects,
      Map<int, String>? brands,
      Map<int, String>? suppliers,
      Map<int, String>? promos,
      bool? withSales,
      bool? withStocks}) {
    return FilterModel(
        subjects: subjects ?? this.subjects,
        brands: brands ?? this.brands,
        suppliers: suppliers ?? this.suppliers,
        promos: promos ?? this.promos,
        withSales: withSales == false ? null : withSales ?? this.withSales,
        withStocks: withStocks == false ? null : withStocks ?? this.withStocks);
  }

  factory FilterModel.empty() {
    return FilterModel();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'subjects': subjects,
      'brands': brands,
      'suppliers': suppliers,
      'promos': promos,
      'withSales': withSales,
      'withStocks': withStocks
    };
  }

  factory FilterModel.fromMap(Map<String, dynamic> map) {
    return FilterModel(
        subjects: map['subjects'] != null
            ? Map<int, String>.from(map['subjects'] as Map<int, String>)
            : null,
        brands: map['brands'] != null
            ? Map<int, String>.from(map['brands'] as Map<int, String>)
            : null,
        suppliers: map['suppliers'] != null
            ? Map<int, String>.from(map['suppliers'] as Map<int, String>)
            : null,
        promos: map['promos'] != null
            ? Map<int, String>.from(map['promos'] as Map<int, String>)
            : null,
        withSales: map['withSales'] != null ? map['withSales'] as bool : null,
        withStocks:
            map['withStocks'] != null ? map['withStocks'] as bool : null);
  }

  String toJson() => json.encode(toMap());

  factory FilterModel.fromJson(String source) =>
      FilterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FilterModel(subjects: $subjects, brands: $brands, suppliers: $suppliers, promos: $promos, withSales: $withSales, withStocks: $withStocks)';
  }

  @override
  bool operator ==(covariant FilterModel other) {
    if (identical(this, other)) return true;

    return mapEquals(
          other.subjects,
          subjects,
        ) &&
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
