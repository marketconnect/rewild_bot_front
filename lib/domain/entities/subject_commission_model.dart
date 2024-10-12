// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:intl/intl.dart';

class SubjectCommissionModel {
  final int id;
  final bool isKiz;
  final String catName;
  final double commission;
  DateTime? createdAt;

  SubjectCommissionModel({
    required this.id,
    required this.isKiz,
    required this.catName,
    required this.commission,
    this.createdAt,
  });

  @override
  String toString() {
    return 'SubjectModel(id: $id, catName: $catName, commission: $commission, isKiz: $isKiz, createdAt: $createdAt)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'catName': catName,
      'isKiz': isKiz,
      'commission': commission,
      // 'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory SubjectCommissionModel.fromMap(Map<String, dynamic> map) {
    final dateStr = map['createdAt'] as String;
    final updatedAt = DateFormat('yyyy-MM-dd').parse(dateStr, true).toLocal();
    final izKiz = map['isKiz'] as int;
    return SubjectCommissionModel(
        id: map['id'] as int,
        catName: map['catName'] as String,
        isKiz: izKiz == 1,
        commission: map['commission'] as double,
        createdAt: updatedAt);
  }

  factory SubjectCommissionModel.fromJson(Map<String, dynamic> json) {
    return SubjectCommissionModel(
      id: json['id'] ?? 0,
      isKiz: json['isKiz'] ?? false,
      catName: json['catName'] ?? '',
      commission: (json['commission'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isKiz': isKiz,
      'catName': catName,
      'commission': commission,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
