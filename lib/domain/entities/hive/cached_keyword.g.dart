// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_keyword.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedKeywordAdapter extends TypeAdapter<CachedKeyword> {
  @override
  final int typeId = 16;

  @override
  CachedKeyword read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedKeyword(
      keyword: fields[0] as String,
      freq: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedKeyword obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.keyword)
      ..writeByte(1)
      ..write(obj.freq);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedKeywordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
