// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_query.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackingQueryAdapter extends TypeAdapter<TrackingQuery> {
  @override
  final int typeId = 20;

  @override
  TrackingQuery read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackingQuery(
      nmId: fields[0] as int,
      query: fields[1] as String,
      geo: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TrackingQuery obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.nmId)
      ..writeByte(1)
      ..write(obj.query)
      ..writeByte(2)
      ..write(obj.geo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingQueryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
