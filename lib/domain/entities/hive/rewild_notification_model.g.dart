// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewild_notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReWildNotificationModelAdapter
    extends TypeAdapter<ReWildNotificationModel> {
  @override
  final int typeId = 10;

  @override
  ReWildNotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReWildNotificationModel(
      parentId: fields[0] as int,
      condition: fields[1] as int,
      value: fields[2] as String,
      sizeId: fields[3] as int?,
      wh: fields[4] as int?,
      reusable: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReWildNotificationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.parentId)
      ..writeByte(1)
      ..write(obj.condition)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.sizeId)
      ..writeByte(4)
      ..write(obj.wh)
      ..writeByte(5)
      ..write(obj.reusable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReWildNotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
