// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackingResultAdapter extends TypeAdapter<TrackingResult> {
  @override
  final int typeId = 1;

  @override
  TrackingResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackingResult(
      keyword: fields[0] as String,
      productId: fields[1] as int,
      geo: fields[2] as String,
      position: fields[3] as int,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TrackingResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.keyword)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.geo)
      ..writeByte(3)
      ..write(obj.position)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
