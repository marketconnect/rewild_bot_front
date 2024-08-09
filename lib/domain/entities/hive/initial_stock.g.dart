// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initial_stock.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InitialStockAdapter extends TypeAdapter<InitialStock> {
  @override
  final int typeId = 2;

  @override
  InitialStock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InitialStock(
      id: fields[0] as int?,
      name: fields[4] as String?,
      date: fields[1] as DateTime,
      nmId: fields[2] as int,
      wh: fields[3] as int,
      sizeOptionId: fields[5] as int,
      qty: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, InitialStock obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.nmId)
      ..writeByte(3)
      ..write(obj.wh)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.sizeOptionId)
      ..writeByte(6)
      ..write(obj.qty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InitialStockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
