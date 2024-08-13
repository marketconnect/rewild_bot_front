import 'package:hive/hive.dart';

part 'lemma_by_filter_id.g.dart';

@HiveType(typeId: 3)
class LemmaByFilterId extends HiveObject {
  @HiveField(0)
  final int lemmaId;

  @HiveField(1)
  final String lemma;

  @HiveField(2)
  final int totalFrequency;

  LemmaByFilterId({
    required this.lemmaId,
    required this.lemma,
    required this.totalFrequency,
  });
}
