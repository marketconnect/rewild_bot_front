// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockAdapter extends TypeAdapter<Stock> {
  @override
  final int typeId = 5;

  @override
  Stock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Stock(
      wh: fields[0] as int,
      name: fields[1] as String,
      sizeOptionId: fields[2] as int,
      qty: fields[3] as int,
      nmId: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Stock obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.wh)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.sizeOptionId)
      ..writeByte(3)
      ..write(obj.qty)
      ..writeByte(4)
      ..write(obj.nmId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
