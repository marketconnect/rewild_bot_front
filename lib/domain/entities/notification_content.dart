// ignore_for_file: public_member_api_docs, sort_constructors_first
class ReWildNotificationContent {
  final int id;
  // final String title;
  // final String body;
  final int? condition;
  final String? newValue;
  final int? wh;

  ReWildNotificationContent(
      {required this.id,
      // required this.title,
      // required this.body,
      this.condition,
      this.wh,
      this.newValue});

  @override
  String toString() =>
      'ReWildNotificationContent(id: $id, condition: $condition, newValue: $newValue)';
}
