// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FilterModelAdapter extends TypeAdapter<FilterModel> {
  @override
  final int typeId = 9;

  @override
  FilterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FilterModel(
      subjects: (fields[0] as Map?)?.cast<int, String>(),
      brands: (fields[1] as Map?)?.cast<int, String>(),
      suppliers: (fields[2] as Map?)?.cast<int, String>(),
      promos: (fields[3] as Map?)?.cast<int, String>(),
      withSales: fields[4] as bool?,
      withStocks: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, FilterModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.subjects)
      ..writeByte(1)
      ..write(obj.brands)
      ..writeByte(2)
      ..write(obj.suppliers)
      ..writeByte(3)
      ..write(obj.promos)
      ..writeByte(4)
      ..write(obj.withSales)
      ..writeByte(5)
      ..write(obj.withStocks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
