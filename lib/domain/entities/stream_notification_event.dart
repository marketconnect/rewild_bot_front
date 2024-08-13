// ignore_for_file: public_member_api_docs, sort_constructors_first
enum ParentType { card, advert }

class StreamNotificationEvent {
  final int parentId;
  final ParentType parentType;
  final bool exists;

  StreamNotificationEvent(
      {required this.parentId, required this.parentType, required this.exists});

  @override
  String toString() =>
      'StreamNotificationEvent(parentId: $parentId, parentType: $parentType, exists: $exists)';
}
