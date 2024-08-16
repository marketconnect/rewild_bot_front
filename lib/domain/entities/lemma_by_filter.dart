class LemmaByFilterId {
  final int lemmaId;
  final String lemma;
  final int totalFrequency;

  LemmaByFilterId(
      {required this.lemmaId,
      required this.lemma,
      required this.totalFrequency});

  // fromMap

  factory LemmaByFilterId.fromMap(Map<String, dynamic> json) {
    return LemmaByFilterId(
      lemmaId: json['lemma_id'],
      lemma: json['lemma'],
      totalFrequency: json['total_frequency'],
    );
  }
  // fromJson

  factory LemmaByFilterId.fromJson(Map<String, dynamic> json) {
    return LemmaByFilterId(
      lemmaId: json['lemma_id'],
      lemma: json['lemma'],
      totalFrequency: json['total_frequency'],
    );
  }
}
