// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupModelAdapter extends TypeAdapter<GroupModel> {
  @override
  final int typeId = 1;

  @override
  GroupModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupModel(
      id: fields[0] as int,
      name: fields[1] as String,
      bgColor: fields[2] as int,
      cardsNmIds: (fields[4] as List).cast<int>(),
      cards: (fields[5] as List).cast<CardOfProduct>(),
      fontColor: fields[3] as int,
    )
      ..stocksSum = (fields[6] as Map).cast<int, int>()
      ..initialStocksSum = (fields[7] as Map).cast<int, int>()
      ..ordersSum = fields[8] as int;
  }

  @override
  void write(BinaryWriter writer, GroupModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.bgColor)
      ..writeByte(3)
      ..write(obj.fontColor)
      ..writeByte(4)
      ..write(obj.cardsNmIds)
      ..writeByte(5)
      ..write(obj.cards)
      ..writeByte(6)
      ..write(obj.stocksSum)
      ..writeByte(7)
      ..write(obj.initialStocksSum)
      ..writeByte(8)
      ..write(obj.ordersSum);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
