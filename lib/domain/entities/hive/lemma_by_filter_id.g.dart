// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lemma_by_filter_id.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LemmaByFilterIdAdapter extends TypeAdapter<LemmaByFilterId> {
  @override
  final int typeId = 3;

  @override
  LemmaByFilterId read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LemmaByFilterId(
      lemmaId: fields[0] as int,
      lemma: fields[1] as String,
      totalFrequency: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LemmaByFilterId obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.lemmaId)
      ..writeByte(1)
      ..write(obj.lemma)
      ..writeByte(2)
      ..write(obj.totalFrequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LemmaByFilterIdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
