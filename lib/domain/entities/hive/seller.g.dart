// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SellerAdapter extends TypeAdapter<Seller> {
  @override
  final int typeId = 4;

  @override
  Seller read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Seller(
      supplierId: fields[0] as int,
      name: fields[1] as String,
      fineName: fields[2] as String?,
      ogrn: fields[3] as String?,
      trademark: fields[4] as String?,
      legalAddress: fields[5] as String?,
      productsCards: (fields[6] as List).cast<CardOfProduct>(),
    )
      ..backgroundColor = fields[7] as Color?
      ..fontColor = fields[8] as Color?;
  }

  @override
  void write(BinaryWriter writer, Seller obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.supplierId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fineName)
      ..writeByte(3)
      ..write(obj.ogrn)
      ..writeByte(4)
      ..write(obj.trademark)
      ..writeByte(5)
      ..write(obj.legalAddress)
      ..writeByte(6)
      ..write(obj.productsCards)
      ..writeByte(7)
      ..write(obj.backgroundColor)
      ..writeByte(8)
      ..write(obj.fontColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
