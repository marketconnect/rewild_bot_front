// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Keyword {
  int campaignId;
  String keyword;
  String normquery;
  int count;
  int todayViews;
  int todayClicks;
  double todayCtr;
  double todaySum;
  String get campaignIdKeyword => '${campaignId}_$keyword';
  int diff = 0;
  void setDiff(int oldValue) {
    diff = count - oldValue;
  }

  bool _isNew = true;
  bool get isNew => _isNew;
  void setNotNew() {
    _isNew = false;
  }

  Keyword({
    required this.campaignId,
    required this.keyword,
    required this.count,
    this.normquery = '',
    this.todayViews = 0,
    this.todayClicks = 0,
    this.todayCtr = 0.0,
    this.todaySum = 0.0,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'campaignId': campaignId,
      'keyword': keyword,
      'count': count,
      'diff': diff,
      '_isNew': _isNew,
      'campaignIdKeyword': campaignIdKeyword,
    };
  }

  factory Keyword.fromMap(Map<String, dynamic> map, int campaignId) {
    return Keyword(
      campaignId: campaignId,
      keyword: map['keyword'],
      count: map['count'],
    );
  }

  factory Keyword.fromString(String kw, int campaignId) {
    return Keyword(
      campaignId: campaignId,
      keyword: kw,
      count: 0,
    );
  }

  factory Keyword.fromDailyWordsStatsJson(
      Map<String, dynamic> json, int campaignId) {
    return Keyword(
        campaignId: campaignId,
        keyword:
            json['keyword'] as String? ?? '', // Default to empty string if null
        todayViews: json['views'] as int? ?? 0, // Default to 0 if null
        todayClicks: json['clicks'] as int? ?? 0, // Default to 0 if null
        todayCtr: (json['ctr'] as num?)?.toDouble() ??
            0.0, // Convert to double, default to 0.0 if null
        todaySum: (json['sum'] as num?)?.toDouble() ??
            0.0, // Convert to double, default to 0.0 if null
        normquery: '',
        count: 0);
  }

  String toJson() => json.encode(toMap());

  factory Keyword.fromJson(String source, int campaignId) =>
      Keyword.fromMap(json.decode(source) as Map<String, dynamic>, campaignId);

  @override
  String toString() {
    return 'Keyword(campaignId: $campaignId, keyword: $keyword, count: $count, diff: $diff, _isNew: $_isNew)';
  }

  @override
  bool operator ==(covariant Keyword other) {
    if (identical(this, other)) return true;

    return other.campaignId == campaignId &&
        other.keyword == keyword &&
        other.normquery == normquery &&
        other.count == count &&
        other.todayViews == todayViews &&
        other.todayClicks == todayClicks &&
        other.todayCtr == todayCtr &&
        other.todaySum == todaySum &&
        other.diff == diff &&
        other._isNew == _isNew;
  }

  @override
  int get hashCode {
    return campaignId.hashCode ^
        keyword.hashCode ^
        normquery.hashCode ^
        count.hashCode ^
        todayViews.hashCode ^
        todayClicks.hashCode ^
        todayCtr.hashCode ^
        todaySum.hashCode ^
        diff.hashCode ^
        _isNew.hashCode;
  }
}
