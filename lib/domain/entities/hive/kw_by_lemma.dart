import 'package:hive/hive.dart';

part 'kw_by_lemma.g.dart';

@HiveType(typeId: 0)
class KwByLemma extends HiveObject {
  @HiveField(0)
  final int lemmaID;

  @HiveField(1)
  final String lemma;

  @HiveField(2)
  final String keyword;

  @HiveField(3)
  final int freq;

  @HiveField(4)
  int? sku;

  @HiveField(5)
  int? _numberOfOccurrencesInTitle;

  @HiveField(6)
  int? _numberOfOccurrencesInDescription;

  KwByLemma({
    required this.lemmaID,
    required this.lemma,
    required this.keyword,
    required this.freq,
    this.sku,
  });

  factory KwByLemma.fromKwFreq({
    required String keyword,
    required int freq,
    required int sku,
  }) {
    return KwByLemma(
      freq: freq,
      lemmaID: 0,
      lemma: "",
      sku: sku,
      keyword: keyword,
    );
  }

  void setNumberOfOccurrencesInTitle(int numberOfOccurrences) {
    _numberOfOccurrencesInTitle = numberOfOccurrences;
  }

  int? get numberOfOccurrencesInTitle => _numberOfOccurrencesInTitle;

  void setNumberOfOccurrencesInDescription(int numberOfOccurrences) {
    _numberOfOccurrencesInDescription = numberOfOccurrences;
  }

  int? get numberOfOccurrencesInDescription =>
      _numberOfOccurrencesInDescription;
}
