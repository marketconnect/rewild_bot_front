// ignore_for_file: public_member_api_docs, sort_constructors_first
class StreamAdvertEvent {
  final int campaignId;
  int? cpm;
  int? status;

  StreamAdvertEvent(
      {required this.campaignId, required this.cpm, required this.status});

  @override
  String toString() =>
      'StreamAdvertEvent(campaignId: $campaignId, cpm: $cpm, status: $status)';
}
