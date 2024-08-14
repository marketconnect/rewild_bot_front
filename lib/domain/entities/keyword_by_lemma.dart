class KwByLemma {
  final int lemmaID;
  final String lemma;
  final String keyword;
  final int freq;
  int? sku;

  int? _numberOfOccurrencesInTitle;
  void setNumberOfOccurrencesInTitle(int numberOfOccurrences) {
    _numberOfOccurrencesInTitle = numberOfOccurrences;
  }

  int? get numberOfOccurrencesInTitle => _numberOfOccurrencesInTitle;

  int? _numberOfOccurrencesInDescription;
  void setNumberOfOccurrencesInDescription(int numberOfOccurrences) {
    _numberOfOccurrencesInDescription = numberOfOccurrences;
  }

  int? get numberOfOccurrencesInDescription =>
      _numberOfOccurrencesInDescription;

  KwByLemma(
      {required this.lemmaID,
      required this.lemma,
      required this.keyword,
      required this.freq,
      this.sku});

  factory KwByLemma.fromKwFreq(
      {required String keyword, required int freq, required int sku}) {
    return KwByLemma(
      freq: freq,
      lemmaID: 0,
      lemma: "",
      sku: sku,
      keyword: keyword,
    );
  }
}
