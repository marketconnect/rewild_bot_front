import 'package:hive/hive.dart';

part 'nm_id.g.dart';

@HiveType(typeId: 3)
class NmId {
  @HiveField(0)
  final int nmId;

  NmId({
    required this.nmId,
  });
}
