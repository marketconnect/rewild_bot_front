// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_seller.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSellerAdapter extends TypeAdapter<UserSeller> {
  @override
  final int typeId = 8;

  @override
  UserSeller read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSeller(
      sellerId: fields[0] as String,
      sellerName: fields[1] as String,
      isActive: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserSeller obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.sellerId)
      ..writeByte(1)
      ..write(obj.sellerName)
      ..writeByte(2)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSellerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
