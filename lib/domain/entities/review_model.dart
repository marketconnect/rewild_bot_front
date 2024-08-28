// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

class ReviewModel {
  String id;
  String userName;
  String matchingSize;
  String text;
  int productValuation;
  DateTime createdDate;
  String state;
  ReviewAnswer? answer;
  ReviewProductDetails productDetails;
  bool wasViewed;

  List<PhotoLink> photoLinks;
  Video? video;
  bool isAbleSupplierFeedbackValuation;
  int? supplierFeedbackValuation;
  bool isAbleSupplierProductValuation;
  int? supplierProductValuation;
  bool isAbleReturnProductOrders;
  String? returnProductOrdersDate;
  List<String> bables;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.matchingSize,
    required this.text,
    required this.productValuation,
    required this.createdDate,
    required this.state,
    this.answer,
    required this.productDetails,
    required this.wasViewed,
    required this.photoLinks,
    this.video,
    required this.isAbleSupplierFeedbackValuation,
    this.supplierFeedbackValuation,
    required this.isAbleSupplierProductValuation,
    this.supplierProductValuation,
    required this.isAbleReturnProductOrders,
    this.returnProductOrdersDate,
    required this.bables,
  });

  ReviewModel copyWith({
    String? id,
    String? userName,
    String? matchingSize,
    String? text,
    int? productValuation,
    DateTime? createdDate,
    String? state,
    ReviewAnswer? answer,
    ReviewProductDetails? productDetails,
    bool? wasViewed,
    List<PhotoLink>? photoLinks,
    Video? video,
    bool? isAbleSupplierFeedbackValuation,
    int? supplierFeedbackValuation,
    bool? isAbleSupplierProductValuation,
    int? supplierProductValuation,
    bool? isAbleReturnProductOrders,
    String? returnProductOrdersDate,
    List<String>? bables,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      matchingSize: matchingSize ?? this.matchingSize,
      text: text ?? this.text,
      productValuation: productValuation ?? this.productValuation,
      createdDate: createdDate ?? this.createdDate,
      state: state ?? this.state,
      answer: answer ?? this.answer,
      productDetails: productDetails ?? this.productDetails,
      wasViewed: wasViewed ?? this.wasViewed,
      photoLinks: photoLinks ?? this.photoLinks,
      video: video ?? this.video,
      isAbleSupplierFeedbackValuation: isAbleSupplierFeedbackValuation ??
          this.isAbleSupplierFeedbackValuation,
      supplierFeedbackValuation:
          supplierFeedbackValuation ?? this.supplierFeedbackValuation,
      isAbleSupplierProductValuation:
          isAbleSupplierProductValuation ?? this.isAbleSupplierProductValuation,
      supplierProductValuation:
          supplierProductValuation ?? this.supplierProductValuation,
      isAbleReturnProductOrders:
          isAbleReturnProductOrders ?? this.isAbleReturnProductOrders,
      returnProductOrdersDate:
          returnProductOrdersDate ?? this.returnProductOrdersDate,
      bables: bables ?? this.bables,
    );
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String,
      userName: map['userName'] as String,
      matchingSize: map['matchingSize'] as String,
      text: map['text'] as String,
      productValuation: map['productValuation'] as int,
      createdDate:
          DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
      state: map['state'] as String,
      answer: ReviewAnswer.fromMap(map['answer'] as Map<String, dynamic>),
      productDetails: ReviewProductDetails.fromMap(
          map['productDetails'] as Map<String, dynamic>),
      wasViewed: map['wasViewed'] as bool,
      photoLinks: (map['photoLinks'] as List<dynamic>?)
              ?.map((link) => PhotoLink.fromMap(link))
              .toList() ??
          [],
      video: map['video'] != null ? Video.fromMap(map['video']) : null,
      isAbleSupplierFeedbackValuation:
          map['isAbleSupplierFeedbackValuation'] as bool,
      supplierFeedbackValuation: map['supplierFeedbackValuation'] as int?,
      isAbleSupplierProductValuation:
          map['isAbleSupplierProductValuation'] as bool,
      supplierProductValuation: map['supplierProductValuation'] as int?,
      isAbleReturnProductOrders: map['isAbleReturnProductOrders'] as bool,
      returnProductOrdersDate: map['returnProductOrdersDate'] as String?,
      bables: (map['bables'] as List<dynamic>?)
              ?.map((bable) => bable as String)
              .toList() ??
          [],
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? "",
      userName: json['userName'] ?? "",
      matchingSize: json['matchingSize'] ?? "",
      productValuation: json['productValuation'] ?? 0,
      text: json['text'] ?? "",
      createdDate: DateTime.tryParse(json['createdDate']) ?? DateTime.now(),
      state: json['state'] ?? "",
      answer:
          json['answer'] == null ? null : ReviewAnswer.fromJson(json['answer']),
      productDetails: ReviewProductDetails.fromJson(json['productDetails']),
      wasViewed: json['wasViewed'] ?? false,
      photoLinks: (json['photoLinks'] as List<dynamic>?)
              ?.map((link) => PhotoLink.fromJson(link))
              .toList() ??
          [],
      video: json['video'] != null ? Video.fromJson(json['video']) : null,
      isAbleSupplierFeedbackValuation:
          json['isAbleSupplierFeedbackValuation'] as bool,
      supplierFeedbackValuation: json['supplierFeedbackValuation'] as int?,
      isAbleSupplierProductValuation:
          json['isAbleSupplierProductValuation'] as bool,
      supplierProductValuation: json['supplierProductValuation'] as int?,
      isAbleReturnProductOrders: json['isAbleReturnProductOrders'] as bool,
      returnProductOrdersDate: json['returnProductOrdersDate'] as String?,
      bables: (json['bables'] as List<dynamic>?)
              ?.map((bable) => bable as String)
              .toList() ??
          [],
    );
  }
  String? reusedAnswerText;
  void setReusedAnswerText(String value) {
    reusedAnswerText = value;
  }

  void clearReusedAnswerText() {
    reusedAnswerText = null;
  }
}

class ReviewAnswer {
  String text;
  String state;
  ReviewAnswer({
    required this.text,
    required this.state,
  });

  ReviewAnswer copyWith({
    String? text,
    String? state,
  }) {
    return ReviewAnswer(
      text: text ?? this.text,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'state': state,
    };
  }

  factory ReviewAnswer.fromMap(Map<String, dynamic> map) {
    return ReviewAnswer(
      text: map['text'] as String,
      state: map['state'] as String,
    );
  }

  String toJson() => json.encode(toMap());
//  factory QuestionProductDetails.fromJson(Map<String, dynamic> json) {
//     return QuestionProductDetails(
//       imtId: json['imtId'],
//       nmId: json['nmId'],
//       productName: json['productName'],
//       supplierArticle: json['supplierArticle'],
//       supplierName: json['supplierName'],
//       brandName: json['brandName'],
//     );
//   }
  factory ReviewAnswer.fromJson(Map<String, dynamic> json) {
    return ReviewAnswer(
      text: json['text'] ?? "",
      state: json['state'] ?? "",
    );
  }

  @override
  String toString() => 'ReviewAnswer(text: $text, state: $state)';

  @override
  bool operator ==(covariant ReviewAnswer other) {
    if (identical(this, other)) return true;

    return other.text == text && other.state == state;
  }

  @override
  int get hashCode => text.hashCode ^ state.hashCode;
}

class ReviewProductDetails {
  int nmId;
  int imtId;
  String productName;
  String supplierArticle;
  String supplierName;
  String brandName;
  String size;

  ReviewProductDetails({
    required this.nmId,
    required this.imtId,
    required this.productName,
    required this.supplierArticle,
    required this.supplierName,
    required this.brandName,
    required this.size,
  });

  ReviewProductDetails copyWith({
    int? nmId,
    int? imtId,
    String? productName,
    String? supplierArticle,
    String? supplierName,
    String? brandName,
    String? size,
  }) {
    return ReviewProductDetails(
      nmId: nmId ?? this.nmId,
      imtId: imtId ?? this.imtId,
      productName: productName ?? this.productName,
      supplierArticle: supplierArticle ?? this.supplierArticle,
      supplierName: supplierName ?? this.supplierName,
      brandName: brandName ?? this.brandName,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nmId': nmId,
      'imtId': imtId,
      'productName': productName,
      'supplierArticle': supplierArticle,
      'supplierName': supplierName,
      'brandName': brandName,
      'size': size,
    };
  }

  factory ReviewProductDetails.fromMap(Map<String, dynamic> map) {
    return ReviewProductDetails(
      nmId: map['nmId'] as int,
      imtId: map['imtId'] as int,
      productName: map['productName'] as String,
      supplierArticle: map['supplierArticle'] as String,
      supplierName: map['supplierName'] as String,
      brandName: map['brandName'] as String,
      size: map['size'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewProductDetails.fromJson(Map<String, dynamic> json) {
    return ReviewProductDetails(
      imtId: json['imtId'],
      nmId: json['nmId'],
      productName: json['productName'],
      supplierArticle: json['supplierArticle'],
      supplierName: json['supplierName'],
      brandName: json['brandName'],
      size: json['size'],
    );
  }

  @override
  String toString() {
    return 'ReviewProductDetails(nmId: $nmId, imtId: $imtId, productName: $productName, supplierArticle: $supplierArticle, supplierName: $supplierName, brandName: $brandName, size: $size)';
  }

  @override
  bool operator ==(covariant ReviewProductDetails other) {
    if (identical(this, other)) return true;

    return other.nmId == nmId &&
        other.imtId == imtId &&
        other.productName == productName &&
        other.supplierArticle == supplierArticle &&
        other.supplierName == supplierName &&
        other.brandName == brandName &&
        other.size == size;
  }

  @override
  int get hashCode {
    return nmId.hashCode ^
        imtId.hashCode ^
        productName.hashCode ^
        supplierArticle.hashCode ^
        supplierName.hashCode ^
        brandName.hashCode ^
        size.hashCode;
  }
}

class PhotoLink {
  String fullSize;
  String miniSize;

  PhotoLink({
    required this.fullSize,
    required this.miniSize,
  });

  factory PhotoLink.fromMap(Map<String, dynamic> map) {
    return PhotoLink(
      fullSize: map['fullSize'] as String,
      miniSize: map['miniSize'] as String,
    );
  }

  factory PhotoLink.fromJson(Map<String, dynamic> json) {
    return PhotoLink(
      fullSize: json['fullSize'] as String,
      miniSize: json['miniSize'] as String,
    );
  }
}

class Video {
  String previewImage;
  String link;
  int durationSec;

  Video({
    required this.previewImage,
    required this.link,
    required this.durationSec,
  });

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      previewImage: map['previewImage'] as String,
      link: map['link'] as String,
      durationSec: map['duration_sec'] as int,
    );
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      previewImage: json['previewImage'] as String,
      link: json['link'] as String,
      durationSec: json['duration_sec'] as int,
    );
  }
}
