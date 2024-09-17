import 'package:rewild_bot_front/domain/entities/product_watch_subscription_response.dart';

class GetAllSubscriptionsForUserAndProductResponse {
  final List<ProductSubscriptionServiceSubscription> subscriptions;

  GetAllSubscriptionsForUserAndProductResponse({required this.subscriptions});

  factory GetAllSubscriptionsForUserAndProductResponse.fromJson(
      Map<String, dynamic> json) {
    return GetAllSubscriptionsForUserAndProductResponse(
      subscriptions: (json['subscriptions'] as List<dynamic>)
          .map((item) => ProductSubscriptionServiceSubscription.fromJson(
              item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptions': subscriptions.map((item) => item.toJson()).toList(),
    };
  }
}
