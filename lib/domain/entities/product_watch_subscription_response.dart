class ProductWatchSubscriptionResponse {
  final int subscriptionId;
  final String message;

  ProductWatchSubscriptionResponse({
    required this.subscriptionId,
    required this.message,
  });

  factory ProductWatchSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return ProductWatchSubscriptionResponse(
      subscriptionId: json['subscription_id'] as int,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'message': message,
    };
  }
}
