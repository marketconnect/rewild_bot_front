class ABTest {
  int? id;
  int nmId;
  String metrics;
  String startDate;
  String endDate;
  String changesDescription;
  String status;

  ABTest({
    this.id,
    required this.nmId,
    required this.metrics,
    required this.startDate,
    required this.endDate,
    required this.changesDescription,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nm_id': nmId,
      'metrics': metrics,
      'start_date': startDate,
      'end_date': endDate,
      'changes_description': changesDescription,
      'status': status,
    };
  }

  factory ABTest.fromMap(Map<String, dynamic> map) {
    return ABTest(
      id: map['id'],
      nmId: map['nm_id'],
      metrics: map['metrics'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      changesDescription: map['changes_description'],
      status: map['status'],
    );
  }

  bool isCompleted() {
    final date = DateTime.parse(endDate);
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return true;
    }
    return false;
  }

  factory ABTest.empty() {
    return ABTest(
      nmId: 0,
      metrics: '',
      startDate: '',
      endDate: '',
      changesDescription: '',
      status: '',
    );
  }
}
