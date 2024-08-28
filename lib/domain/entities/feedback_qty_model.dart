class UnAnsweredFeedbacksQtyModel {
  int nmId;
  int qty;
  int type;

  UnAnsweredFeedbacksQtyModel({
    required this.nmId,
    required this.qty,
    required this.type,
  });

  static const Map<String, int> feedbackType = {
    "question": 0,
    "review": 1,
    "allQuestions": 2,
    "allReviews": 3,
    "error": 4
  };

  static String getName(int type) {
    final res = feedbackType.keys.where((key) => feedbackType[key] == type);
    return res.isNotEmpty ? res.first : "error";
  }

  static int getType(String name) => feedbackType[name] ?? 4;

  Map<String, dynamic> toMap() {
    return {
      'nmId': nmId,
      'qty': qty,
      'type': type,
    };
  }

  factory UnAnsweredFeedbacksQtyModel.fromMap(Map<String, dynamic> map) {
    return UnAnsweredFeedbacksQtyModel(
      nmId: map['nmId'],
      qty: map['qty'],
      type: map['type'],
    );
  }
}
