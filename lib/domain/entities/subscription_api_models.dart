class SubscriptionV2Response {
  final int id;
  final String subscriptionTypeName;
  final int cardLimit;
  final String startDate;
  final String endDate;
  final String token;
  final int expiredAt;

  SubscriptionV2Response({
    required this.id,
    required this.subscriptionTypeName,
    required this.cardLimit,
    required this.startDate,
    required this.endDate,
    required this.token,
    required this.expiredAt,
  });

  factory SubscriptionV2Response.fromJson(Map<String, dynamic> json) {
    return SubscriptionV2Response(
      id: json['id'],
      subscriptionTypeName: json['subscription_type_name'],
      cardLimit: json['card_limit'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      token: json['token'],
      expiredAt: json['expired_at'],
    );
  }

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscription_type_name': subscriptionTypeName,
      'card_limit': cardLimit,
      'start_date': startDate,
      'end_date': endDate,
      'token': token,
      'expired_at': expiredAt,
    };
  }

  // fromMap
  factory SubscriptionV2Response.fromMap(Map<String, dynamic> map) {
    return SubscriptionV2Response(
      id: map['id'],
      subscriptionTypeName: map['subscription_type_name'],
      cardLimit: map['card_limit'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      token: map['token'],
      expiredAt: map['expired_at'],
    );
  }
}

class ExtendSubscriptionV2Response {
  final String? err;

  ExtendSubscriptionV2Response({this.err});

  factory ExtendSubscriptionV2Response.fromJson(Map<String, dynamic> json) {
    return ExtendSubscriptionV2Response(
      err: json['err'],
    );
  }
}

class AddCardsToSubscriptionResponse {
  final List<int> subscriptionCardIds;

  AddCardsToSubscriptionResponse({required this.subscriptionCardIds});

  factory AddCardsToSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return AddCardsToSubscriptionResponse(
      subscriptionCardIds: json['subscription_card_ids'],
    );
  }
}

class RemoveCardFromSubscriptionResponse {
  final List<int> subscriptionCardIds;

  RemoveCardFromSubscriptionResponse({required this.subscriptionCardIds});

  factory RemoveCardFromSubscriptionResponse.fromJson(
      Map<String, dynamic> json) {
    return RemoveCardFromSubscriptionResponse(
      subscriptionCardIds: json['subscription_card_ids'],
    );
  }
}

class CardToSubscription {
  final int sku;
  final String name;
  final String image;

  CardToSubscription({
    required this.sku,
    required this.name,
    required this.image,
  });

  factory CardToSubscription.fromJson(Map<String, dynamic> json) {
    return CardToSubscription(
      sku: json['sku'],
      name: json['name'],
      image: json['image'],
    );
  }
}
