// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:rewild_bot_front/core/constants/notification_constants.dart';
import 'package:rewild_bot_front/domain/entities/product_watch_subscription_response.dart';

class ReWildNotificationModel {
  int parentId;
  String condition;
  String value;
  int? sizeId;
  int? wh;
  bool reusable;
  ReWildNotificationModel({
    required this.parentId,
    required this.condition,
    required this.value,
    this.reusable = false,
    this.sizeId,
    this.wh,
  });

  ReWildNotificationModel copyWith({
    int? parentId,
    String? condition,
    String? value,
    int? sizeId,
    int? wh,
  }) {
    return ReWildNotificationModel(
      parentId: parentId ?? this.parentId,
      condition: condition ?? this.condition,
      value: value ?? this.value,
      sizeId: sizeId ?? this.sizeId,
      wh: wh ?? this.wh,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'parentId': parentId,
      'condition': condition,
      'value': value,
      'sizeId': sizeId,
      'wh': wh,
    };
  }

  factory ReWildNotificationModel.fromMap(Map<String, dynamic> map) {
    return ReWildNotificationModel(
      parentId: map['parentId'] as int,
      condition: map['condition'] as String,
      value: map['value'] as String,
      sizeId: map['sizeId'] != null ? map['sizeId'] as int : null,
      wh: map['wh'] != null ? map['wh'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReWildNotificationModel.fromJson(String source) =>
      ReWildNotificationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  factory ReWildNotificationModel.fromServerSubscription(
      ProductSubscriptionServiceSubscription subscription) {
    return ReWildNotificationModel(
      parentId: subscription.productID,
      condition: subscription.eventType,
      value: subscription.condition != null
          ? subscription.condition!.threshold.toString()
          : "",
      sizeId: null,
      wh: subscription.condition?.warehouseID,
      reusable: false,
    );
  }

  ProductSubscriptionServiceSubscription toServerSubscription(int userId) {
    return ProductSubscriptionServiceSubscription(
      userID: userId,
      productID: parentId,
      eventType: condition,
      condition: ProductSubscriptionServiceCondition(
        warehouseID: wh ?? 0,
        threshold: int.tryParse(value) ?? 0,
        lessThan: condition == NotificationConditionConstants.stocksLessThan ||
            condition == NotificationConditionConstants.totalStocksLessThan,
      ),
    );
  }

  @override
  String toString() {
    return 'ReWildNotificationModel(parentId: $parentId, condition: $condition, value: $value, sizeId: $sizeId, wh: $wh, reusable: $reusable)';
  }

  @override
  bool operator ==(covariant ReWildNotificationModel other) {
    if (identical(this, other)) return true;

    return other.parentId == parentId &&
        other.condition == condition &&
        other.value == value &&
        other.sizeId == sizeId &&
        other.wh == wh;
  }

  @override
  int get hashCode {
    return parentId.hashCode ^
        condition.hashCode ^
        value.hashCode ^
        sizeId.hashCode ^
        wh.hashCode;
  }
}
