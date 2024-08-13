import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 22)
class SubscriptionModel extends HiveObject {
  @HiveField(0)
  final int cardId;

  @HiveField(1)
  final String startDate;

  @HiveField(2)
  final String endDate;

  @HiveField(3)
  final String status;

  SubscriptionModel({
    required this.cardId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      cardId: map['card_id'] as int,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'card_id': cardId,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
    };
  }
}
