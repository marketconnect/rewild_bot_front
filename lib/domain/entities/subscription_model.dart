// class SubscriptionModel {
//   final int cardId;

//   final String startDate;

//   final String endDate;

//   final String status;

//   SubscriptionModel({
//     required this.cardId,
//     required this.startDate,
//     required this.endDate,
//     required this.status,
//   });

//   factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
//     return SubscriptionModel(
//       cardId: map['card_id'] as int,
//       startDate: map['start_date'] as String,
//       endDate: map['end_date'] as String,
//       status: map['status'] as String,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'card_id': cardId,
//       'start_date': startDate,
//       'end_date': endDate,
//       'status': status,
//     };
//   }
// }
