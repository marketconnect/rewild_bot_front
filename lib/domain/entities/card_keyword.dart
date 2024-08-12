import 'package:hive/hive.dart';

part 'card_keyword.g.dart';

@HiveType(typeId: 15)
class CardKeyword extends HiveObject {
  @HiveField(0)
  final int cardId;

  @HiveField(1)
  final String keyword;

  @HiveField(2)
  final int freq;

  @HiveField(3)
  final String updatedAt;

  CardKeyword({
    required this.cardId,
    required this.keyword,
    required this.freq,
    required this.updatedAt,
  });
}
