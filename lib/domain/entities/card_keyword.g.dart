// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_keyword.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardKeywordAdapter extends TypeAdapter<CardKeyword> {
  @override
  final int typeId = 15;

  @override
  CardKeyword read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardKeyword(
      cardId: fields[0] as int,
      keyword: fields[1] as String,
      freq: fields[2] as int,
      updatedAt: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CardKeyword obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cardId)
      ..writeByte(1)
      ..write(obj.keyword)
      ..writeByte(2)
      ..write(obj.freq)
      ..writeByte(3)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardKeywordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
