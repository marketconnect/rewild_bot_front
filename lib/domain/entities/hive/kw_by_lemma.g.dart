// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kw_by_lemma.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KwByLemmaAdapter extends TypeAdapter<KwByLemma> {
  @override
  final int typeId = 0;

  @override
  KwByLemma read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KwByLemma(
      lemmaID: fields[0] as int,
      lemma: fields[1] as String,
      keyword: fields[2] as String,
      freq: fields[3] as int,
      sku: fields[4] as int?,
    )
      .._numberOfOccurrencesInTitle = fields[5] as int?
      .._numberOfOccurrencesInDescription = fields[6] as int?;
  }

  @override
  void write(BinaryWriter writer, KwByLemma obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.lemmaID)
      ..writeByte(1)
      ..write(obj.lemma)
      ..writeByte(2)
      ..write(obj.keyword)
      ..writeByte(3)
      ..write(obj.freq)
      ..writeByte(4)
      ..write(obj.sku)
      ..writeByte(5)
      ..write(obj._numberOfOccurrencesInTitle)
      ..writeByte(6)
      ..write(obj._numberOfOccurrencesInDescription);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KwByLemmaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
