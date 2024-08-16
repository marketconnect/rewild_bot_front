// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CardItemDbItem {
  int? id;
  final int nmID;
  final int subjectID;
  final String? subjectName;
  final String? vendorCode;
  final String? brand;
  final String? title;
  final String? description;
  final int length;
  final int width;
  final int height;
  final String createdAt;

  CardItemDbItem(
      {this.id,
      required this.nmID,
      required this.subjectID,
      required this.subjectName,
      required this.vendorCode,
      required this.brand,
      required this.title,
      required this.description,
      required this.length,
      required this.width,
      required this.height,
      required this.createdAt});

  CardItemDbItem copyWith({
    int? id,
    int? nmID,
    int? subjectID,
    String? subjectName,
    String? vendorCode,
    String? brand,
    String? title,
    String? description,
    int? length,
    int? width,
    int? height,
    String? mediaFilesHash,
    String? createdAt,
  }) {
    return CardItemDbItem(
      id: id ?? this.id,
      nmID: nmID ?? this.nmID,
      subjectID: subjectID ?? this.subjectID,
      subjectName: subjectName ?? this.subjectName,
      vendorCode: vendorCode ?? this.vendorCode,
      brand: brand ?? this.brand,
      title: title ?? this.title,
      description: description ?? this.description,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nmID': nmID,
      'subjectID': subjectID,
      'subjectName': subjectName,
      'vendorCode': vendorCode,
      'brand': brand,
      'title': title,
      'description': description,
      'length': length,
      'width': width,
      'height': height,
      'createdAt': createdAt,
    };
  }

  factory CardItemDbItem.fromMap(Map<String, dynamic> map) {
    return CardItemDbItem(
      id: map['id'] as int,
      nmID: map['nmID'] as int,
      subjectID: map['subjectID'] as int,
      subjectName: map['subjectName'] as String,
      vendorCode: map['vendorCode'] as String?,
      brand: map['brand'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      length: map['length'] as int,
      width: map['width'] as int,
      height: map['height'] as int,
      createdAt: map['createdAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CardItemDbItem.fromJson(String source) =>
      CardItemDbItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CardItemDb(nmID: $nmID, subjectID: $subjectID, subjectName: $subjectName, vendorCode: $vendorCode, brand: $brand, title: $title, description: $description, length: $length, width: $width, height: $height, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant CardItemDbItem other) {
    if (identical(this, other)) return true;

    return other.nmID == nmID &&
        other.subjectID == subjectID &&
        other.subjectName == subjectName &&
        other.vendorCode == vendorCode &&
        other.brand == brand &&
        other.title == title &&
        other.description == description &&
        other.length == length &&
        other.width == width &&
        other.height == height &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return nmID.hashCode ^
        subjectID.hashCode ^
        subjectName.hashCode ^
        vendorCode.hashCode ^
        brand.hashCode ^
        title.hashCode ^
        description.hashCode ^
        length.hashCode ^
        width.hashCode ^
        height.hashCode ^
        createdAt.hashCode;
  }
}
