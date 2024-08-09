import 'package:hive/hive.dart';

part 'initial_stock.g.dart';

@HiveType(typeId: 2)
class InitialStock extends HiveObject {
  @HiveField(0)
  final int? id; // Сделали id опциональным (nullable)

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int nmId;

  @HiveField(3)
  final int wh;

  @HiveField(4)
  final String? name;

  @HiveField(5)
  final int sizeOptionId;

  @HiveField(6)
  final int qty;

  InitialStock({
    this.id,
    this.name,
    required this.date,
    required this.nmId,
    required this.wh,
    required this.sizeOptionId,
    required this.qty,
  });
}
