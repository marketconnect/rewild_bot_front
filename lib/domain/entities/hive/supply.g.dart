// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supply.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplyAdapter extends TypeAdapter<Supply> {
  @override
  final int typeId = 6;

  @override
  Supply read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Supply(
      wh: fields[0] as int,
      nmId: fields[1] as int,
      sizeOptionId: fields[2] as int,
      lastStocks: fields[3] as int,
      qty: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Supply obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.wh)
      ..writeByte(1)
      ..write(obj.nmId)
      ..writeByte(2)
      ..write(obj.sizeOptionId)
      ..writeByte(3)
      ..write(obj.lastStocks)
      ..writeByte(4)
      ..write(obj.qty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
