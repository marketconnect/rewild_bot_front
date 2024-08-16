class SubjCharacteristic {
  final int charcID;
  final String subjectName;
  final int subjectID;
  final String name;
  final bool required;
  final String unitName;
  final int maxCount;
  final bool popular;
  final int charcType;

  SubjCharacteristic({
    required this.charcID,
    required this.subjectName,
    required this.subjectID,
    required this.name,
    required this.required,
    required this.unitName,
    required this.maxCount,
    required this.popular,
    required this.charcType,
  });

  factory SubjCharacteristic.fromJson(Map<String, dynamic> json) {
    return SubjCharacteristic(
      charcID: json['charcID'],
      subjectName: json['subjectName'],
      subjectID: json['subjectID'],
      name: json['name'],
      required: json['required'],
      unitName: json['unitName'],
      maxCount: json['maxCount'],
      popular: json['popular'],
      charcType: json['charcType'],
    );
  }
}
