class SubjectHistory {
  final String id;
  final int subjectId;
  final int totalRevenue;
  final int totalOrders;
  final int totalSkus;
  final int percentageSkusWithoutOrders;
  final String date;

  SubjectHistory({
    required this.subjectId,
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalSkus,
    required this.percentageSkusWithoutOrders,
    required this.date,
  }) : id = '${subjectId}_$date';

  factory SubjectHistory.fromJson(Map<String, dynamic> json) {
    return SubjectHistory(
      subjectId:
          json['subjectId'] as int, // ATTENTION! server returns subjectId !!!
      totalRevenue: json['total_revenue'] as int,
      totalOrders: json['total_orders'] as int,
      totalSkus: json['total_skus'] as int,
      percentageSkusWithoutOrders:
          json['percentage_skus_without_orders'] as int,
      date: json['date'] as String,
    );
  }

  factory SubjectHistory.fromMap(Map<String, dynamic> map) {
    return SubjectHistory(
      subjectId: map['subject_id']
          as int, // ATTENTION! server returns subjectId but here it is subject_id
      totalRevenue: map['total_revenue'] as int,
      totalOrders: map['total_orders'] as int,
      totalSkus: map['total_skus'] as int,
      percentageSkusWithoutOrders: map['percentage_skus_without_orders'] as int,
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id':
          subjectId, // ATTENTION! server returns subjectId but here it is subject_id
      'total_revenue': totalRevenue,
      'total_orders': totalOrders,
      'total_skus': totalSkus,
      'percentage_skus_without_orders': percentageSkusWithoutOrders,
      'date': date,
    };
  }
}
