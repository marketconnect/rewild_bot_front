// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rewild_bot_front/domain/entities/keyword.dart';

class AutoCampaignStatWord {
  final List<Keyword> keywords;
  final List<Keyword> excluded;
  AutoCampaignStatWord({
    required this.keywords,
    required this.excluded,
  });

  AutoCampaignStatWord copyWith({
    List<Keyword>? keywords,
    List<Keyword>? excluded,
  }) {
    return AutoCampaignStatWord(
      keywords: keywords ?? this.keywords,
      excluded: excluded ?? this.excluded,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'keywords': keywords.map((x) => x.toMap()).toList(),
      'excluded': excluded.map((x) => x.toMap()).toList(),
    };
  }

  factory AutoCampaignStatWord.fromMap(
      Map<String, dynamic> map, int campaignId) {
    List<Keyword> keywords = List<Keyword>.from(
      map['keywords']?.map((x) => Keyword.fromMap(x, campaignId)),
    );
    List<Keyword> excluded = List<Keyword>.from(
      map['excluded']?.map((x) => Keyword.fromString(x, campaignId)),
    );

    return AutoCampaignStatWord(
      keywords: keywords,
      excluded: excluded,
    );
  }

  String toJson() => json.encode(toMap());

  factory AutoCampaignStatWord.fromJson(String source, int campaignId) =>
      AutoCampaignStatWord.fromMap(
          json.decode(source) as Map<String, dynamic>, campaignId);

  @override
  String toString() =>
      'AutoCampaignStatWord(keywords: ${keywords.first}, excluded: ${excluded.first})';

  @override
  bool operator ==(covariant AutoCampaignStatWord other) {
    if (identical(this, other)) return true;

    return listEquals(other.keywords, keywords) &&
        listEquals(other.excluded, excluded);
  }

  @override
  int get hashCode => keywords.hashCode ^ excluded.hashCode;
}
