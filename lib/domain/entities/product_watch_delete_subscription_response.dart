class ProductWatchDeleteSubscriptionResponse {
  final String message;

  ProductWatchDeleteSubscriptionResponse({
    required this.message,
  });

  // Метод для создания объекта из JSON
  factory ProductWatchDeleteSubscriptionResponse.fromJson(
      Map<String, dynamic> json) {
    return ProductWatchDeleteSubscriptionResponse(
      message: json['message'] as String,
    );
  }

  // Метод для преобразования объекта в JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
