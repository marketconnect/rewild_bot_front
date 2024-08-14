class TrackingQuery {
  int? id;
  int nmId;
  final String query;
  final String geo;

  TrackingQuery(
      {this.id, required this.nmId, required this.query, required this.geo});

  Map<String, dynamic> toMap() {
    return {'id': id, 'query': query, 'geo': geo};
  }

  factory TrackingQuery.fromMap(Map<String, dynamic> map) {
    return TrackingQuery(
      id: map['id'] as int?,
      nmId: map['nmId'] as int,
      query: map['query'] as String,
      geo: map['geo'] as String,
    );
  }
}
