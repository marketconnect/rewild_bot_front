import 'package:hive/hive.dart';

part 'tariff.g.dart'; // Убедитесь, что вы сгенерировали адаптер

@HiveType(typeId: 7)
class Tariff extends HiveObject {
  @HiveField(0)
  final int storeId;

  @HiveField(1)
  final String wh;

  @HiveField(2)
  final int coef;

  @HiveField(3)
  final String type;

  Tariff({
    required this.storeId,
    required this.wh,
    required this.coef,
    required this.type,
  });

  bool isBoxes() {
    return type == 'b';
  }

  bool isMono() {
    return type == 'm';
  }
}
