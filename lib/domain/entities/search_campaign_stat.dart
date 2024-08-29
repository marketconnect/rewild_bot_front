// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:rewild_bot_front/domain/entities/keyword.dart';

class SearchCampaignStat {
  final int campaignId;
  Words words;
  List<Stat> stat;

  SearchCampaignStat(
      {required this.campaignId, required this.words, required this.stat});

  factory SearchCampaignStat.fromJson(
      Map<String, dynamic> json, int campaignId) {
    return SearchCampaignStat(
      campaignId: campaignId,
      words: Words.fromJson(json['words'], campaignId),
      stat: List<Stat>.from(json['stat'].map((stat) => Stat.fromJson(stat))),
    );
  }

  SearchCampaignStat copyWith({
    int? campaignId,
    Words? words,
    List<Stat>? stat,
  }) {
    return SearchCampaignStat(
      campaignId: campaignId ?? this.campaignId,
      words: words ?? this.words,
      stat: stat ?? this.stat,
    );
  }

  @override
  String toString() =>
      'SearchCampaignStat(campaignId: $campaignId, words: ${words.toString()}, stat: $stat)';
}

class Words {
  List<String> phrase;
  List<String> strong;
  List<String> excluded;
  List<String> pluse;
  List<Keyword> keywords;
  bool fixed;

  Words({
    required this.phrase,
    required this.strong,
    required this.excluded,
    required this.pluse,
    required this.keywords,
    required this.fixed,
  });

  factory Words.fromJson(Map<String, dynamic> json, int campaignId) {
    return Words(
      phrase: List<String>.from(json['phrase']),
      strong: List<String>.from(json['strong']),
      excluded: List<String>.from(json['excluded']),
      pluse: List<String>.from(json['pluse']),
      keywords: List<Keyword>.from(
        json['keywords'].map(
          (keyword) =>
              Keyword.fromMap(keyword as Map<String, dynamic>, campaignId),
        ),
      ),
      fixed: json['fixed'],
    );
  }

  Words copyWith({
    List<String>? phrase,
    List<String>? strong,
    List<String>? excluded,
    List<String>? pluse,
    List<Keyword>? keywords,
    bool? fixed,
  }) {
    return Words(
      phrase: phrase ?? this.phrase,
      strong: strong ?? this.strong,
      excluded: excluded ?? this.excluded,
      pluse: pluse ?? this.pluse,
      keywords: keywords ?? this.keywords,
      fixed: fixed ?? this.fixed,
    );
  }
}

class Stat {
  int advertId;
  String keyword;
  String advertName;
  String campaignName;
  String begin;
  String end;
  int views;
  int clicks;
  double frq;
  double ctr;
  double cpc;
  int duration;
  double sum;

  Stat({
    required this.advertId,
    required this.keyword,
    required this.advertName,
    required this.campaignName,
    required this.begin,
    required this.end,
    required this.views,
    required this.clicks,
    required this.frq,
    required this.ctr,
    required this.cpc,
    required this.duration,
    required this.sum,
  });

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      advertId: json['advertId'] as int,
      keyword: json['keyword'] as String,
      advertName: json['advertName'] as String,
      campaignName: json['campaignName'] as String,
      begin: json['begin'] as String,
      end: json['end'] as String,
      views: json['views'] as int,
      clicks: json['clicks'] as int,
      frq: (json['frq'] as num).toDouble(),
      ctr: (json['ctr'] as num).toDouble(),
      cpc: (json['cpc'] as num).toDouble(),
      duration: json['duration'] as int,
      sum: (json['sum'] as num).toDouble(),
    );
  }
}
