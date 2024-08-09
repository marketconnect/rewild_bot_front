import 'package:hive/hive.dart';

part 'supply.g.dart';

@HiveType(typeId: 6)
class Supply extends HiveObject {
  @HiveField(0)
  final int wh;

  @HiveField(1)
  final int nmId;

  @HiveField(2)
  final int sizeOptionId;

  @HiveField(3)
  final int lastStocks;

  @HiveField(4)
  final int qty;

  Supply({
    required this.wh,
    required this.nmId,
    required this.sizeOptionId,
    required this.lastStocks,
    required this.qty,
  });

  // Метод fromMap не нужен в Hive, но можно оставить его для совместимости
  static Supply fromMap(Map<String, dynamic> map) {
    return Supply(
      wh: map['wh'],
      nmId: map['nmId'],
      sizeOptionId: map['sizeOptionId'],
      lastStocks: map['lastStocks'],
      qty: map['qty'],
    );
  }
}
