// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_value.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FilterValueAdapter extends TypeAdapter<FilterValue> {
  @override
  final int typeId = 18;

  @override
  FilterValue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FilterValue(
      filterName: fields[0] as String,
      value: fields[1] as String,
      updatedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FilterValue obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.filterName)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterValueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
