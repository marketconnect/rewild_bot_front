// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nm_id.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NmIdAdapter extends TypeAdapter<NmId> {
  @override
  final int typeId = 3;

  @override
  NmId read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NmId(
      nmId: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NmId obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.nmId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NmIdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
