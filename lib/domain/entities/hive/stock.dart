import 'package:hive/hive.dart';

part 'stock.g.dart';

@HiveType(typeId: 5)
class Stock extends HiveObject {
  @HiveField(0)
  final int wh;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int sizeOptionId;

  @HiveField(3)
  final int qty;

  @HiveField(4)
  final int nmId;

  Stock({
    required this.wh,
    required this.name,
    required this.sizeOptionId,
    required this.qty,
    required this.nmId,
  });

  Map<String, dynamic> toMap() {
    return {
      'wh': wh,
      'name': name,
      'sizeOptionId': sizeOptionId,
      'qty': qty,
      'nmId': nmId,
    };
  }

  static Stock fromMap(Map<String, dynamic> map) {
    return Stock(
      wh: map['wh'] as int,
      name: map['name'] as String,
      sizeOptionId: map['sizeOptionId'] as int,
      qty: map['qty'] as int,
      nmId: map['nmId'] as int,
    );
  }
}
