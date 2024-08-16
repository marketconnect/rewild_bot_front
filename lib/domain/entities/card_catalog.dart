// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CardCatalog {
  final List<CardItem> cards;
  final Cursor cursor;

  CardCatalog({required this.cards, required this.cursor});

  factory CardCatalog.fromJson(Map<String, dynamic> json) {
    final cards = json['cards'] as List? ?? [];
    List<CardItem> items = cards
        .map((itemJson) => CardItem.fromJson(itemJson as Map<String, dynamic>))
        .toList();
    return CardCatalog(
      cards: items,
      cursor: Cursor.fromJson(json['cursor'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class CardItem {
  final int nmID;
  final int imtID;
  final int subjectID;
  final String vendorCode;
  final String subjectName;
  final String brand;
  final String title;
  final String? description;
  final List<Photo> photos;
  final String? video;
  final Dimension dimensions;
  final List<Characteristic> characteristics;
  final List<CardItemSize> sizes;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? videoPath;

  CardItem({
    required this.nmID,
    required this.imtID,
    required this.subjectID,
    required this.vendorCode,
    required this.subjectName,
    required this.brand,
    required this.title,
    this.description,
    required this.photos,
    this.video,
    required this.dimensions,
    required this.characteristics,
    required this.sizes,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      nmID: json['nmID'] as int? ?? 0,
      imtID: json['imtID'] as int? ?? 0,
      subjectID: json['subjectID'] as int? ?? 0,
      vendorCode: json['vendorCode'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      photos: (json['photos'] as List<dynamic>? ?? [])
          .map((e) => Photo.fromJson(e as Map<String, dynamic>))
          .toList(),
      video: json['video'] as String?,
      dimensions:
          Dimension.fromJson(json['dimensions'] as Map<String, dynamic>? ?? {}),
      characteristics: (json['characteristics'] as List<dynamic>? ?? [])
          .map((e) => Characteristic.fromJson(e as Map<String, dynamic>))
          .toList(),
      sizes: (json['sizes'] as List<dynamic>? ?? [])
          .map((e) => CardItemSize.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? '1970-01-01T00:00:00Z'),
      updatedAt: DateTime.parse(
          json['updatedAt'] as String? ?? '1970-01-01T00:00:00Z'),
    );
  }

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'nmID': nmID,
      'imtID': imtID,
      'subjectID': subjectID,
      'vendorCode': vendorCode,
      'subjectName': subjectName,
      'brand': brand,
      'title': title,
      'description': description,
      'characteristics': characteristics.map((e) => e.toMap()).toList(),
      'sizes': sizes.map((e) => e.toMap()).toList(),
      'photos': photos.map((e) => e.toMap()).toList(),
      'video': video,
      'dimensions': dimensions.toMap(),
      'tags': tags.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '$nmID $brand $title $subjectID $createdAt $updatedAt';
  }

  CardItem copyWith({
    int? nmID,
    int? imtID,
    int? subjectID,
    String? vendorCode,
    String? subjectName,
    String? brand,
    String? title,
    String? description,
    List<Photo>? photos,
    String? video,
    Dimension? dimensions,
    List<Characteristic>? characteristics,
    List<CardItemSize>? sizes,
    List<Tag>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CardItem(
      nmID: nmID ?? this.nmID,
      imtID: imtID ?? this.imtID,
      subjectID: subjectID ?? this.subjectID,
      vendorCode: vendorCode ?? this.vendorCode,
      subjectName: subjectName ?? this.subjectName,
      brand: brand ?? this.brand,
      title: title ?? this.title,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      video: video ?? this.video,
      dimensions: dimensions ?? this.dimensions,
      characteristics: characteristics ?? this.characteristics,
      sizes: sizes ?? this.sizes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CardItem &&
        nmID == other.nmID &&
        imtID == other.imtID &&
        subjectID == other.subjectID &&
        vendorCode == other.vendorCode &&
        subjectName == other.subjectName &&
        brand == other.brand &&
        title == other.title &&
        description == other.description &&
        listEquals(characteristics, other.characteristics) &&
        listEquals(sizes, other.sizes) &&
        listEquals(photos, other.photos) &&
        video == other.video &&
        dimensions == other.dimensions &&
        listEquals(tags, other.tags) &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        nmID,
        imtID,
        subjectID,
        vendorCode,
        subjectName,
        brand,
        title,
        description,
        Object.hashAll(characteristics),
        Object.hashAll(sizes),
        Object.hashAll(photos),
        video,
        dimensions,
        Object.hashAll(tags),
        createdAt,
        updatedAt,
      );

  // String get characteristicsHash {
  //   var bytes =
  //       utf8.encode(characteristics.map((e) => e.toJsonString()).join(','));
  //   var digest = sha256.convert(bytes);
  //   return digest.toString();
  // }

  // String get mediaFilesHash {
  //   var bytes = utf8.encode(photos.map((e) => e.hash.toString()).join(','));
  //   var digest = sha256.convert(bytes);
  //   return digest.toString();
  // }
}

class Photo {
  final String size516x288;
  final String big;
  final String small;
  String? filePathNewImage;
  String? filePathOldImage;
  // String? networkUrlOldBig;
  // File? oldBigFile;
  XFile? newFile;
  String? hash;
  String? currentpath;

  Photo(
      {required this.size516x288,
      required this.big,
      required this.small,
      this.filePathNewImage,
      this.hash,
      this.newFile,
      this.currentpath,
      this.filePathOldImage});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      size516x288: json['516x288'] as String? ?? '',
      big: json['big'] as String? ?? '',
      small: json['small'] as String? ?? '',
    );
  }
  // toMap method
  Map<String, dynamic> toMap() {
    return {
      '516x288': size516x288,
      'big': big,
      'small': small,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Photo &&
        size516x288 == other.size516x288 &&
        big == other.big &&
        small == other.small &&
        filePathNewImage == other.filePathNewImage &&
        filePathOldImage == other.filePathOldImage &&
        // oldBigFile == other.oldBigFile &&
        newFile?.path == other.newFile?.path;
  }

  @override
  int get hashCode => Object.hash(
        size516x288,
        big,
        small,
        filePathNewImage,
        filePathOldImage,
        // oldBigFile,
        newFile?.path,
      );

  Photo copyWith({
    String? size516x288,
    String? big,
    String? small,
    String? filePathNewBig,
    String? filePathOldBig,
    String? currentpath,
    File? oldBigFile,
    XFile? newBigFile,
  }) {
    return Photo(
      size516x288: size516x288 ?? this.size516x288,
      big: big ?? this.big,
      small: small ?? this.small,
      filePathNewImage: filePathNewBig,
      filePathOldImage: filePathOldBig,
      currentpath: currentpath ?? this.currentpath,
      // oldBigFile: oldBigFile,
      newFile: newBigFile,
    );
  }
}

class Dimension {
  final int length;
  final int width;
  final int height;

  Dimension({required this.length, required this.width, required this.height});

  factory Dimension.fromJson(Map<String, dynamic> json) {
    return Dimension(
      length: json['length'] as int? ?? 0,
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
    );
  }
  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'length': length,
      'width': width,
      'height': height,
    };
  }

  // toJson method
  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dimension &&
          runtimeType == other.runtimeType &&
          length == other.length &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => length.hashCode ^ width.hashCode ^ height.hashCode;

  Dimension copyWith({
    int? length,
    int? width,
    int? height,
  }) {
    return Dimension(
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

class Characteristic {
  final int id;
  final String name;
  final dynamic value;

  Characteristic({required this.id, required this.name, required this.value});

  factory Characteristic.fromJson(Map<String, dynamic> json) {
    return Characteristic(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      value: json['value'] ?? '',
    );
  }

  // toJson method
  String toJson() => json.encode(toMap());

  // fromMap
  factory Characteristic.fromMap(Map<String, dynamic> map) {
    return Characteristic(
      id: map['characteristicId'],
      name: map['name'],
      value: jsonDecode(map['value']),
    );
  }

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Characteristic) return false;

    if (id != other.id || name != other.name) return false;

    if (value is List && other.value is List) {
      List<dynamic> valueList = value as List<dynamic>;
      List<dynamic> otherValueList = other.value as List<dynamic>;

      if (valueList.length != otherValueList.length) return false;

      for (int i = 0; i < valueList.length; i++) {
        if (valueList[i] != otherValueList[i]) {
          return false;
        }
      }

      return true;
    }

    return value == other.value;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ value.hashCode;

  Characteristic copyWith({
    dynamic value,
  }) {
    return Characteristic(
      id: id,
      name: name,
      value: value ?? this.value,
    );
  }

  String toJsonString() {
    // Converting the entire object or its unique parts to a JSON string
    return jsonEncode({'id': id, 'name': name, 'value': value});
  }

  // String generateHash() {
  //   var bytes = utf8.encode(toJsonString()); // data being hashed
  //   var digest = sha256.convert(bytes);
  //   return digest.toString();
  // }
}

class CardItemSize {
  final int chrtID;
  final String techSize;
  final String wbSize;
  final List<String> skus;

  CardItemSize(
      {required this.chrtID,
      required this.techSize,
      required this.skus,
      required this.wbSize});

  factory CardItemSize.fromJson(Map<String, dynamic> json) {
    return CardItemSize(
      chrtID: json['chrtID'] as int? ?? 0,
      techSize: json['techSize'] as String? ?? '',
      wbSize: json['wbSize'] as String? ?? '',
      skus: List<String>.from(json['skus'] as List<dynamic>? ?? []),
    );
  }

  get width => null;

  get height => null;

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'chrtID': chrtID,
      'techSize': techSize,
      'skus': skus,
      'wbSize': wbSize
    };
  }

  // toJson
  String toJson() => json.encode(toMap());

  // fromMap
  factory CardItemSize.fromMap(Map<String, dynamic> map) {
    return CardItemSize(
      chrtID: map['chrtID'] as int,
      techSize: map['techSize'] as String,
      wbSize: map['wbSize'] as String,
      skus: (map['skus'] as String).split(','),
    );
  }

  // copyWith
  CardItemSize copyWith({
    int? chrtID,
    String? techSize,
    List<String>? skus,
  }) {
    return CardItemSize(
        chrtID: chrtID ?? this.chrtID,
        techSize: techSize ?? this.techSize,
        skus: skus ?? this.skus,
        wbSize: wbSize);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardItemSize &&
          runtimeType == other.runtimeType &&
          chrtID == other.chrtID &&
          techSize == other.techSize &&
          skus == other.skus;

  @override
  int get hashCode => chrtID.hashCode ^ techSize.hashCode ^ skus.hashCode;
}

class Tag {
  final int id;
  final String name;
  final String color;

  Tag({required this.id, required this.name, required this.color});
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '',
    );
  }

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          color == other.color;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ color.hashCode;

  Tag copyWith({
    int? id,
    String? name,
    String? color,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}

class Cursor {
  final DateTime updatedAt;
  final int nmID;
  final int total;

  Cursor({required this.updatedAt, required this.nmID, required this.total});

  factory Cursor.fromJson(Map<String, dynamic> json) {
    return Cursor(
      updatedAt: DateTime.parse(
          json['updatedAt'] as String? ?? '1970-01-01T00:00:00Z'),
      nmID: json['nmID'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}
