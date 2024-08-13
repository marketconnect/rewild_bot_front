import 'package:hive/hive.dart';

part 'filter_value.g.dart';

@HiveType(typeId: 18)
class FilterValue extends HiveObject {
  @HiveField(0)
  late String filterName;

  @HiveField(1)
  late String value;

  @HiveField(2)
  late DateTime updatedAt;

  FilterValue({
    required this.filterName,
    required this.value,
    required this.updatedAt,
  });
}
