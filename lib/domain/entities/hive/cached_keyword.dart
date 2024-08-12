import 'package:hive/hive.dart';

part 'cached_keyword.g.dart';

@HiveType(typeId: 16)
class CachedKeyword extends HiveObject {
  @HiveField(0)
  final String keyword;

  @HiveField(1)
  final int freq;

  CachedKeyword({
    required this.keyword,
    required this.freq,
  });
}
