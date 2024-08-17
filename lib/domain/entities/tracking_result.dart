class TrackingResult {
  int? id;
  String keyword;
  int productId;
  String geo;
  int position;
  DateTime date;

  TrackingResult({
    this.id,
    required this.keyword,
    required this.productId,
    required this.geo,
    required this.position,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'keyword': keyword,
      'product_id': productId,
      'position': position,
      'geo': geo,
      'date': date
          .toIso8601String()
          .split('T')[0], // Format DateTime to a DATE string
    };
  }

  // Convert a map into a TrackingResult instance
  factory TrackingResult.fromMap(Map<String, dynamic> map) {
    return TrackingResult(
      id: map['id'],
      keyword: map['keyword'],
      productId: map['product_id'],
      position: map['position'],
      date: DateTime.parse(map['date']),
      geo: map['geo'],
    );
  }
}
