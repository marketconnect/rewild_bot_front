class SubjectModel {
  final int subjectId;
  final String name;
  final int totalRevenue;
  final int totalOrders;
  final int totalSkus;
  final int cpmAverage;
  final int percentageSkusWithoutOrders;
  final int totalVolume;
  DateTime? updatedAt;

  SubjectModel({
    required this.subjectId,
    required this.name,
    required this.totalRevenue,
    required this.cpmAverage,
    required this.totalOrders,
    required this.totalSkus,
    required this.percentageSkusWithoutOrders,
    required this.totalVolume,
    this.updatedAt,
  });

  int averageCheck() {
    if (totalOrders == 0) {
      return 0;
    }
    return totalRevenue ~/ totalOrders;
  }

  double conversionInOrder() {
    final totalSkusOrTwoHundred = totalSkus > 200 ? 200 : totalSkus;

    final conversionInOrder =
        ((totalOrders / totalVolume) * 100) / totalSkusOrTwoHundred;
    return conversionInOrder;
  }

  // Method to create a SubjectModel from JSON
  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: json['subjectId'] ?? 0,
      name: json['name'] ?? '',
      totalRevenue: json['total_revenue'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      cpmAverage: json['cpm_average'] ?? 0,
      totalSkus: json['total_skus'] ?? 0,
      percentageSkusWithoutOrders: json['percentage_skus_without_orders'] ?? 0,
      totalVolume: json['total_volume'] ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }

  // Method to convert a SubjectModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'name': name,
      'total_revenue': totalRevenue,
      'total_orders': totalOrders,
      'total_skus': totalSkus,
      'percentage_skus_without_orders': percentageSkusWithoutOrders,
      'total_volume': totalVolume,
    };
  }

  // Method to create a SubjectModel from a proto
}
