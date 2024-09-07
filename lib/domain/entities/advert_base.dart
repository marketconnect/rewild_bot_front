class Advert {
  int campaignId;
  String name;
  DateTime endTime;
  DateTime createTime;
  DateTime changeTime;
  DateTime startTime;
  int dailyBudget;
  int status;
  int type;
  int? subjectId;

  Advert({
    required this.campaignId,
    required this.name,
    required this.endTime,
    required this.createTime,
    required this.changeTime,
    required this.startTime,
    required this.dailyBudget,
    required this.status,
    required this.type,
    this.subjectId,
  });

  Advert copyWith({
    int? campaignId,
    String? name,
    DateTime? endTime,
    DateTime? createTime,
    DateTime? changeTime,
    DateTime? startTime,
    int? dailyBudget,
    int? status,
    int? type,
    int? subjectId,
  }) {
    return Advert(
      campaignId: campaignId ?? this.campaignId,
      name: name ?? this.name,
      endTime: endTime ?? this.endTime,
      createTime: createTime ?? this.createTime,
      changeTime: changeTime ?? this.changeTime,
      startTime: startTime ?? this.startTime,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      status: status ?? this.status,
      type: type ?? this.type,
      subjectId: subjectId ?? this.subjectId,
    );
  }

  @override
  String toString() {
    return 'Advert(campaignId: $campaignId, name: $name, endTime: $endTime, createTime: $createTime, changeTime: $changeTime, startTime: $startTime, dailyBudget: $dailyBudget, status: $status, type: $type, subjectId: $subjectId)';
  }
}
