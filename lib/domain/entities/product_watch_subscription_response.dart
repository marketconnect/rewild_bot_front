class ProductWatchSubscriptionResponse {
  final int qty;

  ProductWatchSubscriptionResponse({
    required this.qty,
  });

  factory ProductWatchSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return ProductWatchSubscriptionResponse(
      qty: json['qty'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qty': qty,
    };
  }
}

class ProductSubscriptionServiceCondition {
  final int warehouseID;
  final String warehouseName;
  final double threshold;
  final bool lessThan;

  ProductSubscriptionServiceCondition({
    required this.warehouseID,
    required this.warehouseName,
    required this.threshold,
    required this.lessThan,
  });

  factory ProductSubscriptionServiceCondition.fromJson(
      Map<String, dynamic> json) {
    return ProductSubscriptionServiceCondition(
      warehouseID: json['warehouse_id'] ?? 0,
      warehouseName: json['warehouse_name'] ?? '',
      threshold: json['threshold'] ?? 0,
      lessThan: json['less_than'] ?? false,
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'warehouse_id': warehouseID,
  //     'threshold': threshold,
  //     'less_than': lessThan,
  //   };
  // }
}

class ProductSubscriptionServiceSubscription {
  final int userID;
  final int chatID;
  final int productID;
  final String eventType;
  final ProductSubscriptionServiceCondition? condition;

  ProductSubscriptionServiceSubscription({
    required this.userID,
    required this.chatID,
    required this.productID,
    required this.eventType,
    this.condition,
  });

  factory ProductSubscriptionServiceSubscription.fromJson(
      Map<String, dynamic> json) {
    // Приводим json['condition'] к типу Map и проверяем, что оно не является пустым
    final conditionJson = json['condition'] as Map<String, dynamic>?;

    return ProductSubscriptionServiceSubscription(
      userID: json['user_id'] as int,
      chatID: json['chat_id'] ?? 0,
      productID: json['product_id'] as int,
      eventType: json['event_type'] as String,
      condition: (conditionJson != null && conditionJson.isNotEmpty)
          ? ProductSubscriptionServiceCondition.fromJson(conditionJson)
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user_id': userID,
      'chat_id': chatID,
      'product_id': productID,
      'event_type': eventType,
      if (condition != null) 'warehouse_id': condition!.warehouseID,
      if (condition != null) 'warehouse_name': condition!.warehouseName,
      if (condition != null) 'threshold': condition!.threshold,
      if (condition != null) 'less_than': condition!.lessThan,
    };
  }
}
