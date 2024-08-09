// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_of_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardOfProductAdapter extends TypeAdapter<CardOfProduct> {
  @override
  final int typeId = 0;

  @override
  CardOfProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardOfProduct(
      nmId: fields[0] as int,
      name: fields[1] as String,
      img: fields[2] as String?,
      sellerId: fields[3] as int?,
      tradeMark: fields[4] as String?,
      subjectId: fields[5] as int?,
      subjectParentId: fields[6] as int?,
      brand: fields[7] as String?,
      supplierId: fields[8] as int?,
      basicPriceU: fields[9] as int?,
      pics: fields[10] as int?,
      rating: fields[11] as int?,
      reviewRating: fields[12] as double?,
      feedbacks: fields[13] as int?,
      volume: fields[14] as int?,
      promoTextCard: fields[15] as String?,
      createdAt: fields[16] as int?,
      my: fields[17] as int?,
      sizes: (fields[18] as List).cast<SizeModel>(),
      initialStocks: (fields[19] as List).cast<InitialStock>(),
    );
  }

  @override
  void write(BinaryWriter writer, CardOfProduct obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.nmId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.img)
      ..writeByte(3)
      ..write(obj.sellerId)
      ..writeByte(4)
      ..write(obj.tradeMark)
      ..writeByte(5)
      ..write(obj.subjectId)
      ..writeByte(6)
      ..write(obj.subjectParentId)
      ..writeByte(7)
      ..write(obj.brand)
      ..writeByte(8)
      ..write(obj.supplierId)
      ..writeByte(9)
      ..write(obj.basicPriceU)
      ..writeByte(10)
      ..write(obj.pics)
      ..writeByte(11)
      ..write(obj.rating)
      ..writeByte(12)
      ..write(obj.reviewRating)
      ..writeByte(13)
      ..write(obj.feedbacks)
      ..writeByte(14)
      ..write(obj.volume)
      ..writeByte(15)
      ..write(obj.promoTextCard)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.my)
      ..writeByte(18)
      ..write(obj.sizes)
      ..writeByte(19)
      ..write(obj.initialStocks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardOfProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
