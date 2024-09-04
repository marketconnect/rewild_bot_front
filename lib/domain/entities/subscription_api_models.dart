class AddSubscriptionV2Response {
  final String? err;
  final int? subscriptionId;

  AddSubscriptionV2Response({this.err, this.subscriptionId});

  factory AddSubscriptionV2Response.fromJson(Map<String, dynamic> json) {
    return AddSubscriptionV2Response(
      err: json['err'],
      subscriptionId: json['subscription_id'],
    );
  }
}

class SubscriptionV2Response {
  final int id;
  final String subscriptionTypeName;
  final String startDate;
  final String endDate;

  SubscriptionV2Response({
    required this.id,
    required this.subscriptionTypeName,
    required this.startDate,
    required this.endDate,
  });

  factory SubscriptionV2Response.fromJson(Map<String, dynamic> json) {
    return SubscriptionV2Response(
      id: json['id'],
      subscriptionTypeName: json['subscription_type_name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscription_type_name': subscriptionTypeName,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  // fromMap
  factory SubscriptionV2Response.fromMap(Map<String, dynamic> map) {
    return SubscriptionV2Response(
      id: map['id'],
      subscriptionTypeName: map['subscription_type_name'],
      startDate: map['start_date'],
      endDate: map['end_date'],
    );
  }
}

class UpdateSubscriptionV2Response {
  final String? err;

  UpdateSubscriptionV2Response({this.err});

  factory UpdateSubscriptionV2Response.fromJson(Map<String, dynamic> json) {
    return UpdateSubscriptionV2Response(
      err: json['err'],
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
  final String? err;

  AddCardsToSubscriptionResponse({this.err});

  factory AddCardsToSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return AddCardsToSubscriptionResponse(
      err: json['err'],
    );
  }
}

class RemoveCardFromSubscriptionResponse {
  final String? err;

  RemoveCardFromSubscriptionResponse({this.err});

  factory RemoveCardFromSubscriptionResponse.fromJson(
      Map<String, dynamic> json) {
    return RemoveCardFromSubscriptionResponse(
      err: json['err'],
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
