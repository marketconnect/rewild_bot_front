class TopProduct {
  final int sku;
  final int totalOrders;
  final int totalRevenue;
  final int subjectId;
  final String name;
  final String supplier;
  final double reviewRating;
  final int feedbacks;
  final String img;

  TopProduct({
    required this.sku,
    required this.totalOrders,
    required this.totalRevenue,
    required this.subjectId,
    required this.name,
    required this.supplier,
    required this.reviewRating,
    required this.feedbacks,
    required this.img,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      sku: json['sku'],
      totalOrders: json['total_orders'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      name: json['name'],
      supplier: json['supplier'],
      reviewRating: (json['review_rating'] ?? 0 as num).toDouble(),
      feedbacks: json['feedbacks'] ?? 0,
      img: json['img'],
    );
  }

  // Метод для преобразования объекта TopProduct в JSON
  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'total_orders': totalOrders,
      'total_revenue': totalRevenue,
      'subject_id': subjectId,
      'name': name,
      'supplier': supplier,
      'review_rating': reviewRating,
      'feedbacks': feedbacks,
      'img': img,
    };
  }
}
