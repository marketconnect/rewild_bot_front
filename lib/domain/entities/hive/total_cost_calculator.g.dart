// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_cost_calculator.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TotalCostCalculatorAdapter extends TypeAdapter<TotalCostCalculator> {
  @override
  final int typeId = 14;

  @override
  TotalCostCalculator read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TotalCostCalculator(
      nmId: fields[0] as int,
    )..expenses = (fields[1] as Map).cast<String, double>();
  }

  @override
  void write(BinaryWriter writer, TotalCostCalculator obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nmId)
      ..writeByte(1)
      ..write(obj.expenses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TotalCostCalculatorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
