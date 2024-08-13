import 'package:hive/hive.dart';

part 'tracking_result.g.dart';

@HiveType(typeId: 1)
class TrackingResult extends HiveObject {
  @HiveField(0)
  late String keyword;

  @HiveField(1)
  late int productId;

  @HiveField(2)
  late String geo;

  @HiveField(3)
  late int position;

  @HiveField(4)
  late DateTime date;

  TrackingResult({
    required this.keyword,
    required this.productId,
    required this.geo,
    required this.position,
    required this.date,
  });
}
