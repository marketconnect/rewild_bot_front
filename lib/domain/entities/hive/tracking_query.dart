import 'package:hive/hive.dart';

part 'tracking_query.g.dart';

@HiveType(typeId: 20)
class TrackingQuery extends HiveObject {
  @HiveField(0)
  int nmId;

  @HiveField(1)
  String query;

  @HiveField(2)
  String geo;

  TrackingQuery({
    required this.nmId,
    required this.query,
    required this.geo,
  });

  factory TrackingQuery.fromMap(Map<String, dynamic> map) {
    return TrackingQuery(
      nmId: map['nmId'] as int,
      query: map['query'] as String,
      geo: map['geo'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nmId': nmId,
      'query': query,
      'geo': geo,
    };
  }
}
