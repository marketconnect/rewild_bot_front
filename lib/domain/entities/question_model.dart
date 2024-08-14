class QuestionModel {
  String id;
  String text;
  DateTime createdDate;
  String state;
  QuestionAnswer? answer;
  QuestionProductDetails productDetails;
  bool wasViewed;
  bool isOverdue;

  QuestionModel({
    required this.id,
    required this.text,
    required this.createdDate,
    required this.state,
    required this.answer,
    required this.productDetails,
    required this.wasViewed,
    required this.isOverdue,
  });

  factory QuestionModel.empty() {
    return QuestionModel(
      id: "",
      text: "",
      createdDate: DateTime.now(),
      state: "",
      answer: null,
      productDetails: QuestionProductDetails.empty(),
      wasViewed: false,
      isOverdue: false,
    );
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? "",
      text: json['text'] ?? "",
      createdDate: DateTime.tryParse(json['createdDate']) ?? DateTime.now(),
      state: json['state'] ?? "",
      answer: json['answer'] == null
          ? null
          : QuestionAnswer.fromJson(json['answer']),
      productDetails: QuestionProductDetails.fromJson(json['productDetails']),
      wasViewed: json['wasViewed'] ?? false,
      isOverdue: json['isOverdue'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdDate': createdDate.toIso8601String(),
      'state': state,
      'answer': answer,
      'productDetails': productDetails.toJson(),
      'wasViewed': wasViewed,
      'isOverdue': isOverdue,
    };
  }

  String? reusedAnswerText;
  void setReusedAnswerText(String value) {
    reusedAnswerText = value;
  }

  void clearReusedAnswerText() {
    reusedAnswerText = null;
  }
}

class QuestionAnswer {
  final String text;

  final bool editable;

  final String createDate;

  QuestionAnswer(
      {required this.text, required this.editable, required this.createDate});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'editable': editable,
      'createDate': createDate,
    };
  }

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(
      text: json['text'] ?? "",
      editable: json['editable'] ?? false,
      createDate: json['createDate'] ?? "",
    );
  }
}

class QuestionProductDetails {
  int imtId;
  int nmId;
  String productName;
  String supplierArticle;
  String supplierName;
  String brandName;

  QuestionProductDetails({
    required this.imtId,
    required this.nmId,
    required this.productName,
    required this.supplierArticle,
    required this.supplierName,
    required this.brandName,
  });

  factory QuestionProductDetails.fromJson(Map<String, dynamic> json) {
    return QuestionProductDetails(
      imtId: json['imtId'],
      nmId: json['nmId'],
      productName: json['productName'],
      supplierArticle: json['supplierArticle'],
      supplierName: json['supplierName'],
      brandName: json['brandName'],
    );
  }

  factory QuestionProductDetails.empty() {
    return QuestionProductDetails(
      imtId: 0,
      nmId: 0,
      productName: "",
      supplierArticle: "",
      supplierName: "",
      brandName: "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imtId': imtId,
      'nmId': nmId,
      'productName': productName,
      'supplierArticle': supplierArticle,
      'supplierName': supplierName,
      'brandName': brandName,
    };
  }
}
