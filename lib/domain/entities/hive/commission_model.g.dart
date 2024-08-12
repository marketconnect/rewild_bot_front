// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommissionModelAdapter extends TypeAdapter<CommissionModel> {
  @override
  final int typeId = 11;

  @override
  CommissionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommissionModel(
      id: fields[0] as int,
      category: fields[1] as String,
      subject: fields[2] as String,
      commission: fields[3] as double,
      fbs: fields[4] as double,
      fbo: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CommissionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.subject)
      ..writeByte(3)
      ..write(obj.commission)
      ..writeByte(4)
      ..write(obj.fbs)
      ..writeByte(5)
      ..write(obj.fbo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommissionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
