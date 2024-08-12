// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 12;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      sku: fields[0] as int,
      warehouse: fields[1] as int,
      qty: fields[2] as int,
      price: fields[3] as int,
      period: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.sku)
      ..writeByte(1)
      ..write(obj.warehouse)
      ..writeByte(2)
      ..write(obj.qty)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.period);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
