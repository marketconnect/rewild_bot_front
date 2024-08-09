// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tariff.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TariffAdapter extends TypeAdapter<Tariff> {
  @override
  final int typeId = 7;

  @override
  Tariff read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tariff(
      storeId: fields[0] as int,
      wh: fields[1] as String,
      coef: fields[2] as int,
      type: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Tariff obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.storeId)
      ..writeByte(1)
      ..write(obj.wh)
      ..writeByte(2)
      ..write(obj.coef)
      ..writeByte(3)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TariffAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
