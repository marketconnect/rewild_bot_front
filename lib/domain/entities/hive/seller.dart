import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rewild_bot_front/core/color.dart';
import 'package:rewild_bot_front/domain/entities/hive/card_of_product.dart';

part 'seller.g.dart';

@HiveType(typeId: 4)
class Seller extends HiveObject {
  @HiveField(0)
  final int supplierId;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? fineName;

  @HiveField(3)
  String? ogrn;

  @HiveField(4)
  String? trademark;

  @HiveField(5)
  String? legalAddress;

  @HiveField(6)
  final List<CardOfProduct> productsCards;

  @HiveField(7)
  Color? backgroundColor;

  @HiveField(8)
  Color? fontColor;

  Seller({
    required this.supplierId,
    required this.name,
    this.fineName = "",
    this.ogrn = "",
    this.trademark = "",
    this.legalAddress = "",
    this.productsCards = const [],
  });

  void setColors(int index) {
    backgroundColor = ColorsConstants.getColorsPair(index).backgroundColor;
    fontColor = ColorsConstants.getColorsPair(index).fontColor;
  }

  Seller copyWith({
    int? supplierId,
    String? name,
    String? fineName,
    String? ogrn,
    String? trademark,
    String? legalAddress,
  }) {
    return Seller(
      supplierId: supplierId ?? this.supplierId,
      name: name ?? this.name,
      fineName: fineName ?? this.fineName,
      ogrn: ogrn ?? this.ogrn,
      trademark: trademark ?? this.trademark,
      legalAddress: legalAddress ?? this.legalAddress,
      productsCards: productsCards,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'supplierId': supplierId,
      'name': name,
      'fineName': fineName,
      'ogrn': ogrn,
      'trademark': trademark,
      'legalAddress': legalAddress,
    };
  }

  factory Seller.fromMap(Map<String, dynamic> map) {
    return Seller(
      supplierId: map['supplierId'] as int,
      name: map['name'] as String,
      fineName: map['fineName'] != null ? map['fineName'] as String : null,
      ogrn: map['ogrn'] != null ? map['ogrn'] as String : null,
      trademark: map['trademark'] != null ? map['trademark'] as String : null,
      legalAddress:
          map['legalAddress'] != null ? map['legalAddress'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Seller.fromJson(Map<String, dynamic> json) {
    final ogrn = json['ogrn'] ?? json['ogrnip'] ?? "";
    return Seller(
      supplierId: json['id'] as int,
      name: json['name'] as String,
      fineName: json['fineName'] ?? "",
      ogrn: ogrn,
      trademark: json['trademark'] ?? "",
      legalAddress: json['legalAddress'] ?? "",
    );
  }

  @override
  String toString() {
    return 'Seller(supplierId: $supplierId, name: $name, fineName: $fineName, ogrn: $ogrn, trademark: $trademark, legalAddress: $legalAddress, productsCards: $productsCards)';
  }

  @override
  bool operator ==(covariant Seller other) {
    if (identical(this, other)) return true;

    return other.supplierId == supplierId &&
        other.name == name &&
        other.fineName == fineName &&
        other.ogrn == ogrn &&
        other.trademark == trademark &&
        other.legalAddress == legalAddress;
  }

  @override
  int get hashCode {
    return supplierId.hashCode ^
        name.hashCode ^
        fineName.hashCode ^
        ogrn.hashCode ^
        trademark.hashCode ^
        legalAddress.hashCode;
  }
}
